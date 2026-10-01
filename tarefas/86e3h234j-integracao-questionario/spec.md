# 86e3h234j — CREED-48 · Integração do back ao front: o questionário

> Gerada por `workflows/tarefa-to-spec.md` em 2026-09-30, a partir da tarefa
> [CREED-48](https://app.clickup.com/t/86e3h234j), criada no mesmo dia pelo Leonardo
> (líder do front), **sem descrição**. Estado lido: `creed-frontend` em `origin/dev`
> `5bac8fd`; `creed-backend` na branch `feat/86e3gurw3-integracao-sprint-2` (PR #31,
> **aberto**, CI verde), com o fluxo testado à mão em 2026-09-30 (20 de 20 chamadas com o
> código esperado).
>
> **Decisão do Leonardo, em 2026-09-30, antes da spec:** a CREED-48 liga **as telas do
> questionário** às rotas do PR #31, só com perguntas descritivas, e inclui corrigir o
> `link_id` da sessão. A [CREED-21](https://app.clickup.com/t/86e33p0gx) fica com as
> objetivas e a escala; o contrato que ela descreve (`/questions`, `/evaluations`, envio
> em lote) não existe no back e precisa ser atualizado antes de alguém pegá-la.

> **Atualização em 2026-09-30, depois da spec:** o PR #31 do back entrou na `dev`
> (`5222ad6`), e o `link_id` da sessão foi corrigido no front à parte (PR #37,
> `c419d75`). A entrega 1 fica só com os tipos novos e o `responsesApi.ts`.
>
> **Decisão do Leonardo em 2026-09-30, depois da entrega 4:** para a apresentação à
> cliente, o questionário mostra **uma pergunta de escala de 1 a 5 e uma objetiva**,
> integradas no front antes de o back tê-las:
> - o contrato das alternativas foi escrito a partir da tabela `QuestionOption` do
>   modelo (P-039), e a escala é uma objetiva com alternativas 1 a 5 (P-040);
> - as duas perguntas estão **no formato do back**
>   (`src/features/responses/questoesDeDemonstracao.ts`) e entram no
>   `loadQuestionnaire`, somadas às reais, no fim da seção Avaliação. Daí em diante
>   passam pelo mesmo seletor, pela mesma tela e pela mesma revisão que as reais;
> - o envio já monta a objetiva com `option_id` (`paraAnswerCreate`), mas ainda não a
>   manda, porque o back recusa (D2 da CREED-47);
> - a P-037 foi ajustada: some só a objetiva **sem** alternativas.
>
> Com a CREED-37: apagar `questoesDeDemonstracao.ts` e o `if` que o usa, apagar a linha
> que pula objetiva no `submitResponses` e transcrever o schema real das alternativas.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | **Regra de ciclo de vida nova:** quando a resposta é gravada no back (P-034). **Cinco premissas novas** (P-034 a P-038; mais duas, P-039 e P-040, vieram depois, com a demonstração de escala e objetiva), duas delas mudam premissas abertas do questionário (P-024 e o motivo da P-025). |
| Técnico | T3 | **Padrão que não existe no código nem no harness:** um envio que é uma sequência de chamadas (abrir, gravar N respostas, enviar), com falha possível no meio e nova tentativa. Reforça: primeiro slice do front que carrega dado de servidor na máquina `idle · loading · ready · error`, e contrato novo de três domínios do back. |

Dispensadas nesta calibragem: nenhuma.

## Problema

As telas do questionário (`/form`, `/questionario/revisao`, `/questionario/enviado`)
estão prontas, mas mostram **perguntas escritas no código** e o envio **não grava
nada**: o `RevisaoRespostasRoute` só navega para a tela de "enviado". O back passou a ter
as rotas para ler o formulário, abrir uma resposta, gravar e enviar (PR #31), e nada no
front as chama.

Há também um campo errado no tipo da sessão: o front espera `vinculo_id`, e o back manda
`link_id` desde a CREED-32.

## Quem usa

| Papel | O que enxerga e faz depois desta tarefa |
|---|---|
| Qualquer papel logado (`admin`, `gestor`, `respondente`) | Abre o questionário, vê as perguntas descritivas do formulário de demonstração, separadas em abas por seção, responde, revisa, edita na revisão e envia. O envio fica gravado no banco, ligado ao vínculo do login (P-031). |
| Quem já enviou | Ao tentar enviar de novo, vê a mensagem de que já respondeu este formulário. Não há como responder duas vezes (regra do back). |
| Time (dev e apresentação) | Mostra o fluxo de ponta a ponta com o usuário `dev@creed.example.com` e o seed local. |

Ninguém escolhe formulário nesta entrega (P-035).

## Escopo

**Entra:**
- `src/types/api.ts`: `UserSessionResponse.vinculo_id` vira `link_id`, e os tipos das rotas
  consumidas, transcritos dos `schemas.py` do back.
- `src/features/responses/responsesApi.ts`: as cinco chamadas da tabela "Contrato".
- `src/features/responses/responsesSlice.ts`, registrado no `store.ts`: carregar formulário e
  perguntas, e enviar.
- `FormView`: perguntas, seções e quantidade vindas do slice. Estados de carregando, erro e
  formulário sem pergunta.
- `RevisaoRespostasRoute`: o envio chama o slice e só vai para `/questionario/enviado` quando
  o back confirmar. Em caso de erro, mostra a mensagem e deixa tentar de novo.
- Regras de tela das premissas P-036 (seções), P-037 (objetiva escondida) e P-038 (opcional).
- Textos novos em `src/i18n/locales/pt-BR.ts` e `en.ts`.
- Testes das camadas novas e ajuste dos testes das telas que mudaram.

**Não entra:**
- **Perguntas objetivas e escala de 1 a 5.** Ficam na CREED-21, depois da CREED-37 (P-037).
- **Gravar a resposta no "Avançar"** e **retomar o questionário depois de recarregar.** Os
  dois pedem mudança no back (P-034).
- **Escolher entre formulários.** Não há rota que liste (P-035).
- **Nome da pessoa no cabeçalho** do `FormView` (hoje "João Silva" fixo). A sessão não traz
  nome.
- **Dados demográficos no envio.** A CREED-21 cita `demographic_data`, que o back não tem.
- **`GET /form-responses/{id}/answers`.** A revisão usa o que está na memória da tela
  (P-034), então essa rota não tem uso nesta entrega.
- **Modo com login desligado** (`VITE_LOGIN_ENABLED=false`). Sem token, toda rota do
  questionário responde 401. O questionário passa a exigir login.
- **Mudanças no back.** As três sugestões para o back (rota para recuperar a resposta
  aberta, `GET /forms` e 422 estruturado no envio) estão no comentário de review do PR #31
  e viram tarefas de back, fora desta.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-frontend | feature `responses`: `responsesApi.ts` e `responsesSlice.ts` novos; `FormView.tsx` e `RevisaoRespostasRoute.tsx` alterados; `src/types/api.ts`; `src/app/store.ts`; locales |
| creed-backend | nada. Consome o PR #31, que precisa estar na `dev` antes do PR do front |
| creed-infrastructure | nada |
| creed-ai-context | depois do merge do back, atualizar o quadro "Hoje têm contrato de verdade" de `conventions/contrato-front-back.md`, que ainda diz que `answer` não tem rota, e a situação da feature `responses` no `catalogo.md` |

Nome da feature no front: `responses`. Ela consome **três** domínios do back: `forms`,
`questions` e `responses`. A regra de espelhamento vale para a pasta do front, que já
existe. Criar `forms` e `questions` no front para duas chamadas de leitura seria
feature sem tela.

## Contrato

Todas as rotas já existem no PR #31, exigem token e usam o prefixo `/api/v1`. Fonte:
`app/domains/{forms,questions,responses}/schemas.py` e `router.py`.

| Método | Rota | Entrada | Saída | Quem chama |
|---|---|---|---|---|
| GET | `/forms/{form_id}` | — | `FormRead` · 200 | carregar |
| GET | `/forms/{form_id}/questions` | — | `QuestionResponse[]` em ordem de `order_index` · 200 | carregar |
| POST | `/form-responses` | `{ form_id }` | `FormResponseResponse` · 201 | enviar, passo 1 |
| POST | `/form-responses/{id}/answers` | `{ question_id, value }` | `AnswerResponse` · 201 | enviar, passo 2 (uma por resposta preenchida) |
| PATCH | `/form-responses/{id}` | — (sem corpo) | `FormResponseResponse` com `status: "submitted"` · 200 | enviar, passo 3 |

Tipos a transcrever, sem renomear campos:

| Tipo | Campos |
|---|---|
| `FormRead` | `id`, `name`, `organization_id`, `status` (`draft` · `published` · `closed`), `created_at` |
| `QuestionResponse` | `id`, `form_id`, `text`, `order_index`, `type` (`objective` · `descriptive`), `section` (`profile` · `assessment` · `closing`), `required`, `prisma` (enum ou `null`), `created_at` |
| `FormResponseResponse` | `id`, `form_id`, **`vinculo_id`** (o back não renomeou este), `status` (`in_progress` · `submitted`), `started_at`, `submitted_at: string \| null` |
| `AnswerCreate` | `question_id`, `option_id?`, `value?` |
| `AnswerResponse` | `id`, `form_response_id`, `question_id`, `option_id: string \| null`, `value: string \| null`, `created_at` |
| `UserSessionResponse` | troca `vinculo_id` por **`link_id`** |

Erros que o slice traduz em mensagem (chave de i18n, como no `authenticationSlice`):

| Chamada | Status | Mensagem para a pessoa |
|---|---|---|
| carregar | 404 | "Questionário não encontrado" (o seed não rodou) |
| carregar | 403 | "Você não tem acesso a este questionário" |
| enviar, passo 1 | 409 | "Você já respondeu este questionário" |
| qualquer | 5xx ou rede | "Não foi possível falar com o servidor. Tente de novo." |
| qualquer | 422 | a mesma mensagem genérica. Em desenvolvimento, 422 é bug de transcrição (`contrato-front-back.md`) |

401 já é tratado pelo `apiClient`: ele renova a sessão ou limpa e lança o erro.

## Dados

Nenhuma tabela nem coluna nova. O envio escreve em `form_responses` e `answer` pelas rotas
do back.

**O dado que já existe no banco local:** quem já respondeu o formulário `…0003` com o
usuário `dev` (pelo Swagger ou pelo teste do PR #31) tem uma resposta de formulário, e o
passo 1 do envio vai dar 409. Para testar de novo, é preciso apagar essa resposta no
banco local (comando em "Como verificar").

## Abordagem técnica

### Escolhido: uma resposta na memória da tela, gravada inteira no envio

**1. Gravar no envio, não no "Avançar" (P-034).** O `FormView` continua guardando as
respostas em `useState`, como hoje. Ao confirmar na revisão, um thunk `submitResponses`
faz as três etapas em sequência.
*Descartado:* gravar cada resposta no "Avançar". A edição na revisão daria 409 (P-032), e
recarregar a página no meio deixaria uma resposta aberta que o front não tem como
recuperar.

**2. Envio que pode ser retomado.** O slice guarda o `id` da resposta de formulário assim
que ela é criada, e a lista de `question_id` já gravadas. Se uma chamada falhar no meio,
"Tentar de novo" pula o que já foi feito: não cria outra resposta de formulário e não
grava de novo a mesma pergunta.
*Descartado:* recomeçar do zero a cada tentativa. O passo 1 daria 409, e a pessoa ficaria
presa com uma resposta aberta.
*Limite:* se a pessoa recarregar a página depois de uma falha no meio, o slice se perde, e
a resposta aberta no back dá 409 na próxima tentativa. Isso só resolve com a rota de
recuperação no back (ver "Riscos").

**3. Gravar as respostas uma por vez, em ordem.** São poucas perguntas, e em sequência o
erro aponta a pergunta exata.
*Descartado:* `Promise.all`. Várias falhas ao mesmo tempo complicariam a retomada do
item 2, sem ganho que alguém perceba.

**4. Perguntas no slice, respostas no componente.** O que veio do servidor (formulário,
perguntas, status) fica no `responsesSlice`, como pede `camadas-do-front.md`. As
respostas digitadas continuam no `useState` do `FormView` e passam para a revisão pelo
`state` da rota, como já acontece. Ninguém além dessas duas telas precisa delas.
*Descartado:* guardar cada tecla no Redux. Seria estado global para um campo de
formulário, contra a mesma convenção.

**5. Tipo da pergunta convertido numa função só.** O back usa `descriptive` e `section`;
as telas usam `'dissertativa'` e número de seção. Uma função no slice (seletor) monta a
lista que a tela usa: filtra as objetivas (P-037), agrupa por seção na ordem da P-036 e
mantém `order_index` dentro de cada seção. A View não conhece os valores do back.
*Descartado:* trocar o `QuestionType` das telas para o inglês do back. Mexeria no
`Question.tsx` e na revisão inteira por causa de um nome, e a CREED-21 ainda vai
acrescentar a objetiva e a escala.

**6. O id do formulário é uma constante da feature** (`DEMO_FORM_ID`, em
`responsesSlice.ts`, com o marcador `🟡 Premissa P-035`).
*Descartado:* variável de ambiente. Seria uma configuração nova de deploy para um valor
que só existe no seed local.

### Corte em entregas

Um PR no `creed-frontend`, **aberto só depois de o PR #31 do back estar na `dev`**. Antes
disso, a `dev` do front chamaria rotas que a `dev` do back não tem. Dá para trabalhar
antes, com o back da branch rodando localmente.

| # | Entrega | Depende de | Arquivo que se abre primeiro | Pronto quando |
|---|---|---|---|---|
| 1 | **Tipos e chamadas**: `link_id`, tipos da tabela "Contrato", `responsesApi.ts` com `getForm`, `listQuestions`, `createFormResponse`, `recordAnswer` e `submitFormResponse` (forma de `src/features/authentication/authenticationApi.ts`) | — | `src/types/api.ts` | `npm run typecheck` passa; teste do `responsesApi` confere método, caminho e corpo de cada uma das cinco chamadas |
| 2 | **Carregar**: `responsesSlice` com `loadQuestionnaire` (formulário + perguntas), o seletor `selectQuestionnaireSections` do item 5, registro no `store.ts` (forma de `src/features/authentication/authenticationSlice.ts`, com a máquina `idle · loading · ready · error`) | 1 | `src/features/responses/responsesSlice.ts` | testes do slice cobrem `loading → ready`, `ready` com lista vazia, 404 e 403 com a chave de erro certa, e o seletor (objetiva fora, ordem das seções) |
| 3 | **Tela com dados reais**: `FormView` lê do slice. Seções e quantidade de perguntas dinâmicas, regras da P-038, estados de carregando, erro e vazio | 2 | `src/features/responses/FormView.tsx` | com o back local, `/form` mostra as 3 perguntas do formulário de demonstração em 3 abas; a opcional pode ficar em branco; testes do `FormView` passam com o store de teste |
| 4 | **Enviar**: `submitResponses` com as três etapas e a retomada do item 2; `RevisaoRespostasRoute` chama o thunk e só navega no sucesso | 2, 3 | `src/features/responses/responsesSlice.ts`, depois `RevisaoRespostasRoute.tsx` | o envio grava no banco local (conferido pelo Swagger); o teste do slice cobre falha na 2ª resposta e a nova tentativa sem repetir a 1ª; 409 no passo 1 mostra "já respondeu" |

## Critérios de aceite

- [ ] `UserSessionResponse` tem `link_id` e não tem `vinculo_id`; `npm run typecheck` passa.
- [ ] Nenhum `View.tsx` importa `@/lib/apiClient` (`camadas-do-front.md`).
- [ ] `/form` mostra as perguntas descritivas que o back devolve para o formulário
      `…0003`, com o texto do back, e nenhuma pergunta fixa no código.
- [ ] As abas seguem a P-036: uma por seção com pergunta, na ordem `profile` →
      `assessment` → `closing`.
- [ ] Pergunta objetiva criada no formulário **não aparece** na tela (P-037).
- [ ] Pergunta opcional pode ficar em branco, e sair da seção só exige as obrigatórias
      (P-038).
- [ ] Enquanto carrega, a tela mostra carregando. Se o formulário não existir, mostra a
      mensagem de "não encontrado", não uma tela quebrada. Formulário sem pergunta mostra
      mensagem de vazio.
- [ ] Nenhuma chamada de escrita acontece antes de confirmar o envio na revisão (P-034).
- [ ] Confirmar o envio grava uma resposta de formulário `submitted` e uma resposta por
      pergunta preenchida, com o texto **editado na revisão** quando houve edição.
- [ ] Só depois do 200 do `PATCH` a tela vai para `/questionario/enviado`.
- [ ] Falha no meio do envio mostra a mensagem e o botão de tentar de novo. A nova
      tentativa não cria outra resposta de formulário nem grava de novo uma pergunta já
      gravada.
- [ ] Tentar enviar um formulário já respondido mostra "Você já respondeu este
      questionário".
- [ ] Textos novos existem em `pt-BR.ts` e `en.ts`.
- [ ] `npm run check` passa (lint, format, typecheck e testes).

## Como verificar

**Preparar o back** (terminal do back, em `creed-backend`):

1. `git checkout feat/86e3gurw3-integracao-sprint-2`, ou `dev`, depois do merge do PR #31.
2. `docker compose up -d db keycloak`, depois `source .venv/bin/activate`,
   `alembic upgrade head` e `python scripts/seed_local.py`.
3. `uvicorn app.main:app --reload`.
4. Se o `dev` já respondeu o formulário antes, limpe a resposta:
   `docker compose exec -T db psql -U creed -d creed -c "DELETE FROM answer WHERE form_response_id IN (SELECT id FROM form_responses WHERE form_id='00000000-0000-0000-0000-000000000003'); DELETE FROM form_responses WHERE form_id='00000000-0000-0000-0000-000000000003';"`

**No front** (terminal do front, em `creed-frontend`, `npm run dev`):

5. Entre com `dev@creed.example.com` / `dev` e siga até `/form`.
6. Aparecem 3 abas (Seção 1, 2 e 3), uma pergunta em cada, com os textos
   "[Demonstração] …".
7. Tente sair da Seção 1 sem responder: a tela barra. Responda as duas obrigatórias e
   deixe a de encerramento em branco: chega à revisão.
8. Na revisão, edite a resposta da Seção 1 e confirme o envio: vai para "enviado".
9. No Swagger (`http://localhost:8000/api/v1/docs`), com o login do `dev`, rode
   `GET /form-responses/{id}/answers` com o `id` da resposta (ou consulte
   `SELECT value FROM answer;` no banco): aparecem 2 respostas, e a da Seção 1 tem o
   **texto editado**.
10. Faça o fluxo de novo e envie: aparece "Você já respondeu este questionário".
11. **Falha no meio:** repita o passo 4. Na revisão, antes de confirmar, desligue o back
    (`Ctrl + C`), confirme o envio e veja a mensagem de erro. Religue o back e clique em
    tentar de novo: vai para "enviado", e o banco tem **uma** resposta de formulário.
12. **Objetiva escondida:** pelo Swagger, crie uma pergunta `objective` no formulário
    `…0003` (`POST /questions`), recarregue `/form`: ela não aparece.
13. `npm run check`.

**O que estes passos não provam:** falha **entre** a 1ª e a 2ª resposta gravada só se
reproduz no teste do slice (passo 11 derruba antes da primeira chamada). O 403 de
formulário de outra organização não se reproduz com o realm local, que só tem o `admin`.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-034 | O questionário só grava no back ao confirmar o envio, e recarregar antes disso perde o que foi digitado | baixo |
| P-035 | O questionário abre sempre o formulário de demonstração, com o id fixo no front | baixo |
| P-036 | As abas vêm das seções que têm pergunta, na ordem `profile` → `assessment` → `closing` | baixo |
| P-037 | Pergunta objetiva sem alternativas não aparece (ajustada: a versão inicial escondia toda objetiva até a CREED-37) | baixo |
| P-038 | Pergunta opcional pode ficar em branco, e sair da seção exige só as obrigatórias | baixo |
| P-039 | As alternativas chegam dentro da pergunta, em `options`, na forma da tabela `QuestionOption` do modelo; a resposta objetiva vai em `option_id`. Contrato provisório, escrito antes de o back tê-lo | baixo |
| P-040 | A escala de 1 a 5 é uma objetiva com alternativas de valor 1 a 5, e não um tipo próprio | baixo |

As sete estão abertas em [`decisoes/premissas.md`](../../decisoes/premissas.md). No código,
cada uma tem o marcador `🟡 Premissa P-0NN` onde é aplicada. A P-023 (8 seções) continua
aberta. Duas premissas anteriores foram ajustadas no ledger, sem mudar de número: a P-024
(sair da seção exige só as obrigatórias, pela P-038) e a P-025 (a seção só ganha o check
depois que a pessoa passa por ela).

**A P-039 e a P-040 precisam chegar à CREED-37:** são o formato que o front já espera das
alternativas. Se o back escolher outro, ele ganha, e o front se ajusta em
`src/types/api.ts` e no seletor do `responsesSlice.ts`.

## Riscos

- **O PR #31 do back muda na review.** O front foi escrito contra a branch. **Mitigação:**
  o PR do front só abre depois do merge do back, e a entrega 1 é conferida de novo contra
  os `schemas.py` da `dev`. **Sinal:** 422 em alguma chamada do front.
- **Pessoa presa com resposta aberta.** Falha no meio do envio seguida de recarregar a
  página deixa uma resposta `in_progress` no back, e cada nova tentativa dá 409 ("já
  respondeu") sem que ela tenha enviado. **Mitigação:** a janela é pequena, porque nada é
  gravado antes do envio (P-034). A saída de verdade é a rota de recuperação sugerida no
  review do PR #31. **Sinal:** alguém recebe "já respondeu" sem ter chegado à tela de
  "enviado".
- **Perder o que digitou ao recarregar.** É consequência aceita da P-034. **Sinal:** queixa
  na apresentação ou na review da cliente. A volta é gravar no "Avançar", depois que o back
  tiver edição de resposta.
- **Apresentação com o formulário já respondido.** O `dev` só responde uma vez.
  **Mitigação:** rodar o passo 4 do "Como verificar" antes de apresentar. **Sinal:** "Você
  já respondeu este questionário" na frente da cliente.
- **Texto das perguntas de demonstração lido como proposta.** As perguntas dizem
  "[Demonstração]", mas a tela agora parece o produto. **Sinal:** a cliente comentando o
  conteúdo das perguntas em vez do fluxo.
- **O questionário deixa de funcionar com o login desligado.** Quem usa
  `VITE_LOGIN_ENABLED=false` para ver as telas vai ver o erro de carregamento. **Sinal:**
  alguém do time relatando que `/form` "quebrou".
