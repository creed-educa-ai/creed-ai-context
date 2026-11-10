# Tasks — CREED-69 · E-1 a E-6 · Cadastro, aprovação e exclusão de empresas

Spec: [`spec.md`](spec.md)

## Branches

Uma branch e um PR por subtarefa do ClickUp. As do back são empilhadas (modo AGES III,
item 5): cada uma sai da anterior **depois do commit dela**, o PR aponta para a branch
anterior e passa a apontar para a `dev` quando a anterior for mergeada. Ajuste numa
branch de baixo chega às de cima por `git merge`, nunca por rebase.

| Subtarefa | Tasks | Repo | Branch | Sai de |
|---|---|---|---|---|
| [691 · E-1](https://app.clickup.com/t/1dfej6fvrvn) | 1 | back | `feat/691-empresa-pendente` | `dev` |
| [692 · E-2](https://app.clickup.com/t/1dfej6fvrvp) | 2 | back | `feat/692-cadastro-de-empresa` | `feat/691-empresa-pendente` |
| [696 · E-6](https://app.clickup.com/t/1dfej6fvrvw) | 3 e 4 | back | `feat/696-excluir-empresa` | `feat/692-cadastro-de-empresa` |
| [693 · E-3](https://app.clickup.com/t/1dfej6fvrvt) | 5 | back | `feat/693-aprovar-empresa` | `feat/696-excluir-empresa`, com a `dev` mesclada depois que o creed-backend#51 entrar nela |
| [694 · E-4/E-5](https://app.clickup.com/t/1dfej6fvrvu) | 6 e 7 | front | `feat/694-integracao-empresas` | `dev` |

## Progresso

- [ ] 1 — Empresa pendente: status, dados de contato e documento na leitura · `creed-backend`
- [ ] 2 — Cadastro público `POST /organizations/sign-up` · `creed-backend`
- [ ] 3 — Exclusão de empresa no banco (`OrganizationRemovalService`) · `creed-backend`
- [ ] 4 — Rota `DELETE /organizations/{organization_id}` · `creed-backend`
- [ ] 5 — Aprovar `POST /organizations/{organization_id}/approval` · `creed-backend`
- [ ] 6 — Cadastro público ligado ao back · `creed-frontend`
- [ ] 7 — Tabela de empresas ligada ao back · `creed-frontend`

Marque aqui ao concluir cada task (`workflows/tasks-to-code.md`).

## Por que sete, e nesta ordem

- **A exclusão (3 e 4) vem antes da aprovação (5).** Rejeitar é a rota de excluir
  (spec, Abordagem técnica, item 6), e a aprovação depende do creed-backend#51, ainda
  aberto. Assim as tasks 1 a 4 não esperam ninguém.
- **A E-6 virou duas tasks, como a M-2.** A task 3 compõe sete domínios e é testável
  sem HTTP; a 4 só traduz erros em status. As duas vão no mesmo PR (696).
- **O front também virou duas.** O cadastro (6) só precisa da task 2; a tabela (7)
  precisa de todo o back. As duas vão no mesmo PR (694), como dois commits.
- **O "Esqueci minha senha" não tem task.** O código existe nos dois lados (front na
  `dev`, back no creed-backend#52). Entra como o texto de "aguarde confirmação" na task
  6 e como verificação ponta a ponta na task 7.

## Onde mora cada coisa, e por quê

`tests/test_arquitetura.py` deixa um domínio importar outro só pelo `service` ou pelo
`dependencies` dele, e só se o domínio estiver em `COMPOE_COM_SERVICE_DE`. Os dois
domínios abaixo já estão lá; o que muda é o **motivo** escrito ao lado.

| Domínio | Passa a compor com | Por quê | Task |
|---|---|---|---|
| `organizacoes` | `documents` (criar e ler por lista, além de "existe?") | o cadastro cria o documento; a leitura mostra o número | 1, 2 |
| `organizacoes` | `users.dependencies` (no `router_organizations.py`) | as rotas de exclusão e aprovação delegam aos services de `users`, como `links/router_members.py` faz com a M-3 | 4, 5 |
| `users` | `organizacoes`, `department`, `documents` | o `OrganizationRemovalService` apaga pelo service de cada dono | 3 |

`users` já importa `organizacoes` na branch do #51 (`MemberService`). Os services novos
ficam em `users` pelo mesmo motivo da M-3: em `organizacoes`, eles importariam `users`, e
`users` já importa `organizacoes`.

## Molde

| Para quê | Copiar de |
|---|---|
| Enum próprio de um domínio, com nome de tipo no banco | `DocType` em `app/domains/documents/models.py` |
| Segundo router de um domínio, com prefixo próprio | `app/domains/links/router_members.py` |
| Rota que delega a um service de `users` | `delete_member` em `app/domains/links/router_members.py` |
| Composição de exclusão, na ordem das chaves estrangeiras | `MemberRemovalService` em `app/domains/users/service.py` |
| Testes da composição, com dublês que registram a ordem | `tests/domains/users/test_member_removal_service.py` |
| Convite tudo-ou-nada | `MemberService.invite_member_service` em `app/domains/users/service.py` (branch do #51) |
| `create` que devolve `None` na constraint única | `OrganizationRepository.create` em `app/domains/organizacoes/repository.py` |
| Thunk com chave de erro de i18n | `requestPasswordReset` em `src/features/authentication/authenticationSlice.ts` |
| Teste que passa pelo `apiClient` de verdade | `src/test/stubFetch.ts` e `src/features/organizations/organizationsApi.test.ts` |

## Fora do board

- **creed-backend#51** (convite de membro): a task 5 só sobe com ele na `dev`.
- **creed-backend#52** ("esqueci minha senha" no back): a verificação ponta a ponta da
  task 7 precisa dele na `dev`.
- **creed-infrastructure#10** (e-mail da EC2): sem ele, aprovar em produção dá 503.
  Não bloqueia nenhuma task; bloqueia o uso real.
