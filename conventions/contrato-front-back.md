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
| Endpoints de verdade (como `respondentes`) | transcreva o contrato real e siga |
| Docstring **"STUB"** e um `APIRouter` sem rota | **PARE.** O domínio não existe |
| O diretório não existe | **PARE.** O domínio não existe |

Hoje **só `respondentes` está implementado**. `organizacoes`, `prismas`, `prognosticos`,
`relatorios` e `dashboards` são stubs registrados no `main.py` — a rota responde, e
responde 404. Descobrir isso por tentativa custa uma tarde.

### Quando o domínio é stub

1. Diga, em uma linha, que o contrato não existe e cite o arquivo stub.
2. O contrato passa a ser **decisão de produto registrada**: sai na spec (seção
   "Contrato"), vira premissa no ledger (`premissas-e-duvidas.md`) e **tarefa de backend
   no ClickUp**.
3. O front codifica contra o `types/api.ts` escrito **a partir da spec**, com um
   comentário apontando a premissa.
4. Quando o backend chegar e divergir, **o backend ganha** — o front se ajusta
   (`../context/frontend.md`). É por isso que a premissa fica registrada: para a
   divergência ser conversa de cinco minutos, e não arqueologia.

Nunca invente campo em silêncio. Nome de campo inventado vira migration depois.

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
