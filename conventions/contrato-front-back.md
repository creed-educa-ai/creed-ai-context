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

Hoje têm contrato de verdade **três** domínios:

| Domínio | Rotas | Tarefa |
|---|---|---|
| `authentication` | `POST /authentication/login`, `POST /authentication/renew`, `GET /authentication/session` | CREED-23 |
| `users` | `POST /users`, `DELETE /users/{id}` | CREED-23 |
| `responses` | `POST /form-responses` (abre), `PATCH /form-responses/{id}` (finaliza). A tabela `answer` existe, mas ainda **sem rota** | CREED-31 · CREED-34 |

`organizacoes`, `prismas`, `prognosticos`, `relatorios` e `dashboards` são stubs
registrados no `main.py` — a rota responde, e responde 404. Descobrir isso por tentativa
custa uma tarde. No banco, `alembic/versions/` tem só as tabelas `user`,
`form_responses` e `answer`; o resto do modelo existe apenas no `.dbml`.

### O molde é forma, não campo

O molde é `users` no back e `authentication` no front: é deles que se copia a forma de
router, service, repository, schemas, slice e view. Então:

- copie dele a **forma**: nomes de camada, formato de resposta e de erro, a separação
  entre `<feature>Api.ts`, slice e View;
- **não** copie os **campos** para um domínio novo — os de `users` valem para usuário,
  não para o que você está construindo.

**`respondentes` é resíduo do scaffold, não contrato.** O domínio do backend foi removido
em 2026-09-21; no front sobram a feature `respondentes` (as telas de demográficos), o
`respondentesApi.ts` e o `Respondente` em `types/api.ts`. A API que eles chamam responde
404, e ninguém decidiu que respondente tem `regiao` e `pais`. Não use como contrato nem
como molde.

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
