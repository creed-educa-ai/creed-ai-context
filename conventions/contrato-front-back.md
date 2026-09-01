# Contrato entre front e back

O front consome o backend por um contrato que **já existe em código** — ou que ainda não
existe, e aí o caminho é outro. Confundir os dois casos é a origem do bug mais caro desta
fase: front pronto contra campo que o backend nunca teve.

## A fonte da verdade

Nesta ordem, sempre:

1. `creed-backend/app/domains/<dominio>/schemas.py` — os Pydantic são o contrato.
2. `creed-backend/app/domains/<dominio>/router.py` — rota, método, query params,
   `response_model` e códigos de status.
3. OpenAPI em `http://localhost:8000/api/v1/docs`, com o backend rodando — útil para
   conferir, não para adivinhar.

`src/types/api.ts` é **espelho manual** desses schemas (a geração por OpenAPI está
adiada até os contratos estabilizarem — nota no próprio arquivo). Espelho manual só
funciona se for transcrição, não interpretação.

## Portão: o domínio existe mesmo?

Antes de escrever uma linha de integração, abra `app/domains/<dominio>/router.py`:

| O que você encontra | O que fazer |
|---|---|
| Endpoints de verdade, escritos para uma tarefa | transcreva o contrato real e siga |
| Docstring **"STUB"** e um `APIRouter` sem rota | **PARE.** O domínio não existe |
| O diretório não existe | **PARE.** O domínio não existe |
| `respondentes` | **é scaffold**: forma para copiar, não contrato para consumir — ver abaixo |

Hoje, na prática, **nenhum domínio tem contrato acordado**. `organizacoes`, `prismas`,
`prognosticos`, `relatorios` e `dashboards` são stubs registrados no `main.py` — a rota
responde, e responde 404. Descobrir isso por tentativa custa uma tarde. E não há migration
nenhuma: `alembic/versions/` está vazio.

### `respondentes` é exemplo, não contrato

O domínio `respondentes` (e a feature de mesmo nome no front, e o `Respondente` em
`types/api.ts`) nasceu do **scaffold dos projetos**. Ele é o molde — a forma de router,
service, repository, schemas, slice e view que todo mundo copia — e continua valendo
para isso.

O que ele **não** é: contrato negociado com a cliente. Ninguém decidiu que respondente
tem `regiao` e `pais`. Então:

- copie dele a **forma**: nomes de camada, paginação `ListaPaginada<T>`, formato de
  resposta, máquina de status;
- **não** copie os **campos** para um domínio novo, e não trate os dele como acordados;
- feature que mexa de fato em respondentes precisa de contrato acordado como qualquer
  outra — o código existente é ponto de partida, não decisão registrada.

Na dúvida entre "isto é padrão do projeto" e "isto é resíduo do scaffold": padrão é o que
está escrito neste harness; o resto é exemplo.

### Quando o contrato não existe (o caso comum hoje)

1. Diga, em uma linha, que o contrato não existe e cite o arquivo que você abriu.
2. O contrato passa a ser **decisão de produto registrada**: sai na spec (seção
   "Contrato"), vira premissa no ledger (`premissas-e-duvidas.md`) e **tarefa de backend
   no ClickUp**.
3. O front codifica contra o `types/api.ts` escrito **a partir da spec**, com um
   comentário apontando a premissa.
4. Quando o backend chegar e divergir, **o backend ganha** — o front se ajusta
   (`../context/frontend.md`). É por isso que a premissa fica registrada: para a
   divergência ser conversa de cinco minutos, e não arqueologia.

## Transcrever, não interpretar

- **`snake_case` do backend permanece `snake_case`** no `types/api.ts` (`data_nascimento`,
  `tamanho_pagina`). Não "arrume" para camelCase: o que chega no JSON é o que o Pydantic
  serializa.
- **Opcional e nulo não são a mesma coisa.** `str | None` no schema vira `string | null`;
  campo com `default` que pode ser omitido no POST vira `campo?:`.
- **Campo calculado no response** (como `idade`, montado no router) existe na leitura e
  **não** existe no create.
- **Paginação** já tem forma: `ListaPaginada<T>` com `itens`, `total`, `pagina`,
  `tamanho_pagina`. Não crie uma segunda.

## A camada de integração

Toda chamada passa pelo `src/lib/apiClient.ts`, que já resolve base URL (`/api/v1`),
cabeçalho, 204 sem corpo e erro. Nunca `fetch` direto, nunca URL absoluta — o Vite faz
proxy.

```ts
export const <feature>Api = {
  listar: (params) => apiClient.get<ListaPaginada<X>>(`/<recurso>?${query}`),
  obter: (id: string) => apiClient.get<X>(`/<recurso>/${id}`),
  criar: (dados: XCreate) => apiClient.post<X>('/<recurso>', dados),
  remover: (id: string) => apiClient.delete(`/<recurso>/${id}`),
};
```

Funções puras: recebem parâmetro, devolvem promessa. Sem Redux, sem React, sem
`try/catch` — quem trata erro é o slice.

## Erro

O `apiClient` lança `ApiError` com `status`. Quem decide o que fazer com o status é o
**slice**, e a View recebe mensagem pronta:

| Status | Significado prático |
|---|---|
| 404 | recurso não existe — mensagem de vazio, não de falha |
| 409 | conflito de regra (e-mail duplicado, por exemplo) — mensagem do backend vale |
| 422 | payload não bate com o schema — **é bug do front**, o contrato foi transcrito errado |
| 5xx | falha do servidor — mensagem genérica e "tente recarregar" |

422 em desenvolvimento não é para virar tratamento bonito na tela: é para voltar ao
`schemas.py` e corrigir a transcrição.
