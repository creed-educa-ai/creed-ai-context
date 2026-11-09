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

Hoje, na `dev` do back (2026-11-02, `cc8dc61`), têm contrato de verdade **dez**
domínios. Todas as rotas exigem token, menos o login e a renovação. A lista completa de
rotas, e a feature do front que espelha cada domínio, está no
[`catalogo.md`](../catalogo.md); o espelho dos schemas é o `src/types/api.ts`, uma
seção por domínio.

| Domínio | Quem pode | Feature do front |
|---|---|---|
| `authentication` | todos | `authentication` |
| `users` | admin | `users` |
| `links` | admin cria o vínculo; admin e gestor trocam o setor dos membros (o gestor só na própria organização, P-066) | `links` |
| `participants` | admin | `participants` |
| `organizacoes` | admin; o gestor lê a própria | `organizations` |
| `department` | admin cria; leitura autenticada | `departments` |
| `forms` | admin e gestor criam; qualquer papel lê na própria organização | `forms` |
| `questions` | idem | `questions` |
| `responses` | quem abriu a resposta | `responses` |

Em **branches abertas** do back, já transcritas no front porque as telas dependem
delas: `POST /organizations/{id}/members` (convite de membro),
`POST /users/{id}/invitation` (reenvio) e `POST /authentication/password-reset`
(`feat/86e35vhxm-*`).

Com tabela e schema, **sem rota**: `demographics`, `insights`, `dashboards` (router
stub) e `documents` (só tabela). `prismas`, `prognosticos` e `relatorios` são stubs
registrados no `main.py` — a rota responde, e responde 404. Descobrir isso por
tentativa custa uma tarde.

**Contrato ainda provisório, escrito no front antes do back:** o campo `options` em
`QuestionResponse`. O back já cria alternativas (`POST /questions/{id}/options`) e já
aceita `option_id` na resposta, mas o `GET /forms/{id}/questions` não as devolve
(P-039). A escala segue como objetiva de 1 a 5 (P-040).

### Onde a tela diverge do back

Decidido em 2026-11-02 (refatoração do front para espelhar o back): onde a tela pede
uma forma que o back não tem, **a tela mantém a forma dela** e a divergência fica
listada aqui, para ser resolvida na integração — dos dois lados, não por adivinhação.
Os tipos dessas formas estão no fim do `src/types/api.ts`, em "PROVISÓRIOS DA TELA",
e o dado fictício mora no `<feature>Api.ts` (mock).

| Tela | Forma da tela | O que o back tem | O que falta decidir |
|---|---|---|---|
| Empresas (super adm) e cadastro público | `Company`: nome, e-mail, documento (número), responsável, telefone; status `ativo`/`pendente` | `OrganizationResponse`: `name`, `address`, `document_id`; status `active`/`inactive`; sem rota pública de cadastro | rota pública, onde moram e-mail/responsável/telefone e o estado "pendente" (CREED-591/595) |
| Membros (painel da empresa) | `Member`: status `ativo`/`pendente`, `tag` = setor (`DepartmentType`) | `UserResponse` (`RecordStatus`); setor em `links.department_id` | rota que liste e remova membros; "pendente" = convite não aceito? |
| Mentorandos (super adm) | `Mentee`: `hasAnsweredCurrent` | participante com vínculo `mentoria`; nada sobre "respondeu o atual" | rota que liste; de onde vem "respondeu" |
| Adicionar mentorando | só e-mail | convite exige `name`, `email`, `role` e a organização | o nome entra na tela? qual organização? |
| Período do questionário (painel da empresa) | início e término (data e hora) | `FormRead` tem só `status` | onde o período mora |
| Dashboards | pedido por recorte (`period`, `department` ou `member_id`; sem nada, o período mais recente da organização inteira) e devolvido com o recorte resolvido; payload montado para a tela: períodos, notas dos prismas e das sete dimensões (`Dimension`), resumo, setores (`DepartmentType`) e membros para o recorte, e as comparações, uma por combinação de período e escopo (`scope`: um setor ou `organization`, a empresa toda; o nulo é "o mesmo que está sendo exibido"; o setor exibido também entra), com as notas de prismas e dimensões da referência, a variação já calculada e o período padrão de comparação (`default_period`, o anterior ao exibido); os períodos de comparação (`comparison_options.periods`) incluem o exibido, que a tela só deixa escolher junto de um setor; no resumo do Creed.ai, a análise, a recomendação, um texto curto por prisma e quais prismas são destaque e oportunidade; só na empresa, o alinhamento (pessoas por faixa de nota, P-061/P-062) e o mapa setores × prismas, sempre da organização inteira no período pedido (o recorte não o muda), com a diferença de cada setor já calculada | `DashboardResponse`: `user_id`, `form_id`, `is_private` | contrato de leitura dos dashboards (com `prismas` e `insights`); se o back manda todas as combinações ou responde a uma por vez; texto por prisma contraria a P-042 (um insight por resposta), e insight de setor ou organização ainda não existe |
| Demográficos | `name` e `perspective` junto do rascunho | `DemographicCreate` não tem nenhum dos dois; `name` é do `Participant` | rota de gravação e onde mora a `perspective` |

**Resolvido em 2026-11-02:** a tag do membro é o setor do vínculo (`DepartmentType`), com a mesma tag e a mesma cor em toda tela (`src/components/department/DepartmentTag.tsx`; cores placeholder em `src/lib/departmentColors.ts`). "Vendas" deixou de existir, porque o back não tem esse setor.

**Resolvido em 2026-11-02:** o radar de prismas dos dashboards usava os cinco eixos
do `.dbml` (`plasticidade_humana`, `empreendedorismo`…). Passou a usar o enum `Prisma`
do back (`seguranca_psicologica`, `lideranca_adaptativa`, `cultura_empreendedora`,
`adaptabilidade_cognitiva`, `neuroinovacao_prisma`), que vem do material do produto
sobre a composição dos prismas (SP, LA, CE, AC, NP).

### O molde é forma, não campo

O molde é `users` no back e `authentication` no front: é deles que se copia a forma de
router, service, repository, schemas, slice e view. Então:

- copie dele a **forma**: nomes de camada, formato de resposta e de erro, a separação
  entre `<feature>Api.ts`, slice e View;
- **não** copie os **campos** para um domínio novo — os de `users` valem para usuário,
  não para o que você está construindo.

**`respondentes` saiu do front em 2026-11-02.** O domínio do back foi removido em
2026-09-21; no front, a tela, o slice, o `respondentesApi.ts` e o tipo `Respondente`
saíram na refatoração que espelhou o back. As telas de demográficos viraram a feature
`demographics`. O namespace de i18n `respondentes` continua com esse nome.

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

- **`snake_case` do backend permanece `snake_case`** no `types/api.ts` (`vinculo_id`,
  `started_at`, `tamanho_pagina`). Não "arrume" para camelCase: o que chega no JSON é o
  que o Pydantic serializa.
- **Opcional e nulo não são a mesma coisa.** `datetime | None` no schema vira
  `string | null` (como o `submitted_at` do `FormResponseResponse`, nulo enquanto a
  resposta está em andamento); campo com `default` que pode ser omitido no POST vira
  `campo?:`.
- **Campo gerado pelo servidor** existe na leitura e **não** existe no create: o
  `FormResponseResponse` tem `id`, `vinculo_id`, `status` e `started_at`, e o
  `FormResponseCreate` só tem `form_id` (o vínculo vem do login).
- **Paginação** já tem forma: `ListaPaginada<T>` com `itens`, `total`, `pagina`,
  `tamanho_pagina`. Não crie uma segunda.

## A camada de integração

Toda chamada passa pelo `src/lib/apiClient.ts`, que já resolve base URL (`/api/v1`),
cabeçalho, 204 sem corpo e erro. Nunca `fetch` direto, nunca URL absoluta — o Vite faz
proxy.

```ts
export const organizationsApi = {
  listOrganizations: ({ pagina = 1, tamanho_pagina = 50 } = {}) =>
    apiClient.get<ListaPaginada<OrganizationResponse>>(`/organizacoes?${query}`),
  getOrganization: (id: string) =>
    apiClient.get<OrganizationResponse>(`/organizacoes/${id}`),
  createOrganization: (data: OrganizationCreate) =>
    apiClient.post<OrganizationResponse>('/organizacoes', data),
};
```

Funções puras: recebem parâmetro, devolvem promessa. Sem Redux, sem React, sem
`try/catch` — quem trata erro é o slice. Nome da função em inglês, verbo + recurso
(`getForm`, `listQuestions`, `createLink`); o caminho é o do router do back, como ele
está — inclusive `/organizacoes` e `/department`.

**Um `Api.ts` por domínio do back.** Uma tela que usa três domínios (o questionário lê
`forms` e `questions` e grava em `responses`) importa três `Api.ts` no slice; não junta
as rotas de outros domínios no `Api.ts` da própria feature.

**Mock mora no `Api.ts`, nunca na View.** Tela que precisa de dado que o back ainda não
serve chama uma função do `<feature>Api.ts` que devolve `Promise.resolve(<mock>)`, com
o mesmo tipo que a rota de verdade vai devolver. Assim a View já cobre os quatro estados
da máquina e o slice já existe; integrar é trocar o corpo da função. Se o mock guarda
estado (remover, aprovar), o arquivo exporta um `reset…Mock()` para os testes.

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
