# Task 8 — Documentos refletem o convite

**Repo:** `creed-ai-context`, com base na `main`.
**Depende de:** tasks 2 a 7. Cada documento descreve o que já está no código ou na
produção.
**Branch sugerida:** `docs/86e35vhxm-documentos-do-convite`

## Objetivo

Nenhum documento do harness continua dizendo que "não existe envio de e-mail" ou que o
primeiro acesso usa senha passada por fora. ADR, contrato, arquitetura, infraestrutura,
ledger, pauta e glossário descrevem o convite como ele ficou.

## Contexto que você não tem como adivinhar

- **A spec, a revisão e as premissas P-045 a P-053 não esperam esta task.** Já estão na
  `main` desde o creed-ai-context#36, e o adendo do Gmail desde o #37. Esta task cuida só
  do que descreve o convite **depois** de ele existir no código e na produção.
- **ADR-0006.** O adendo do provedor já existe (2026-10-27: Gmail do projeto por SMTP,
  sem SES) e já cita o script de ajuste do realm. Falta acrescentar a ele que, sem
  domínio, o link do convite sai com o IP do servidor.

  O status sai de "Proposto" se o time confirmar.
- **O que cada documento diz hoje e passa a dizer:**

  | Documento | Hoje | Depois |
  |---|---|---|
  | `context/arquitetura.md` | o provedor já está certo desde o #37: o "fora da AWS" do diagrama passou a ser verdade, porque o Gmail fica fora da AWS. O fluxo do convite só tem o `POST /users` | o fluxo com membros, reenvio e redefinição |
  | `context/infraestrutura.md` | a tabela "Onde ficam os segredos" não tem o SMTP | uma linha para a conta do Gmail do projeto e a senha de app: ficam com o dono da conta e só no `.env` da EC2, como exceção à regra do Parameter Store, e a linha diz como a conta passa para a turma seguinte |
  | `tarefas/86e348g6u-…/contrato-api.md` | `UserCreate { link_id, email, initial_password }`; "o 503 ainda não acontece" | `UserCreate { name, email, link_id }`; rotas de membros, reenvio e reset; 503 |
  | `tarefas/86e348g6u-…/spec.md` | "Não entra: recuperação de senha por e-mail — não existe serviço de e-mail" | aponta para a 23.8 |
  | `pauta/proxima-reuniao.md`, item 3 | descreve a P-007, refutada, e diz que a plataforma não envia e-mail | pergunta à cliente o que as P-045 a P-053 decidiram sem ela, e se o remetente `@gmail.com` serve até haver domínio |
  | `glossario.md` | sem convite, membro e mentorando | os três termos |
  | `catalogo.md` | `organizacoes` como scaffold; sem `links`, `participants`, `forms` e `questions` | o estado de hoje |

- **Ledger** (`decisoes/premissas.md`). Premissa não some: muda de status, com o desfecho
  escrito.
  - A P-009 vira ❌ refutada, porque o reset existe.
  - A P-012 registra que o interim acabou.
  - A P-013 troca o motivo.
  - As P-003 e P-004 de 07/09 (tela de senha e 8 caracteres) fecham com o desfecho: a
    tela foi removida, e a regra foi para o realm.
- **Fora deste repo, e fora desta task:**
  - o `creed-docs` (`docs/arquitetura/index.md`) tem o aviso "🟡 Convite e e-mail ainda
    são desenho, não código". Ele muda num PR próprio daquele repo;
  - a descrição da 23.8 no ClickUp, com a tabela "Hoje/Depois" errada, muda na publicação
    (`workflows/tasks-to-clickup.md`).

## Arquivos que provavelmente mudam

- `decisoes/adrs/0006-e-mail-transacional.md`.
- `context/arquitetura.md` e `context/infraestrutura.md`.
- `tarefas/86e348g6u-autenticacao-da-plataforma/contrato-api.md` e `spec.md`.
- `decisoes/premissas.md`.
- `pauta/proxima-reuniao.md`.
- `glossario.md`.
- `catalogo.md`.

## Molde

- Adendo de ADR com nota datada: a "Nota de implementação — dois composes (2026-10-09)",
  no ADR-0007.
- Premissa fechada com desfecho: a seção "Fechadas" do ledger (P-007, P-011).

## Critérios de aceite

- [ ] A busca do "Como testar" só acha texto histórico, marcado como tal.
- [ ] O ADR-0006 diz que, sem domínio, o link sai com o IP do servidor. Provedor, porta,
      credenciais e script já estão no adendo de 27/10.
- [ ] `context/infraestrutura.md` diz onde ficam a conta do Gmail e a senha de app, e como
      elas passam para a turma seguinte.
- [ ] O contrato da CREED-23 bate com o OpenAPI do back depois das tasks 2 a 4.
- [ ] A P-009 está em "Fechadas", com o desfecho, e nenhuma premissa sumiu.
- [ ] O item 3 da pauta pergunta o que ainda depende da cliente: validade do link, texto
      do e-mail, remetente `@gmail.com`, mentorando e empresa aprovada.

## Como testar

```bash
cd creed-ai-context
grep -rn -i "initial_password\|não existe envio de e-mail\|não existe serviço de e-mail\|não envia e-mail\|email-smtp\|sandbox do SES" --include=*.md --exclude-dir=86e35vhxm-convite-de-primeiro-acesso .
```

A pasta da própria 23.8 fica fora da busca, porque cita esses termos para dizer o que
muda.

Leitura: alguém que não participou da 23.8 lê a seção "Autenticação e e-mail" de
`context/arquitetura.md` e consegue dizer como uma pessoa ganha acesso.

## Premissas aplicáveis

- Todas as da spec (P-045 a P-053), só para levar à pauta. Esta task não cria premissa.
