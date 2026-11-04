# Tasks — CREED-23.8 Convite de primeiro acesso por e-mail

Spec: [`spec.md`](spec.md) · Revisão de entrada:
[`revisao-23.8.md`](../86e348g6u-autenticacao-da-plataforma/revisao-23.8.md)

## Progresso

**Um PR por task**, como manda o "Corte em entregas" da spec. Back e front nunca ficam no
mesmo PR, e as tasks do back andam em sequência, porque mexem nos mesmos arquivos de
`users`.

- [x] 1 — [O Keycloak local manda e-mail](1_task.md) · `creed-backend`
- [x] 2 — [Criar acesso cria nos dois lados e convida](2_task.md) · `creed-backend`
- [x] 3 — [Adicionar membro numa chamada](3_task.md) · `creed-backend`
- [x] 4 — [Reenviar convite e esqueci minha senha](4_task.md) · `creed-backend`
- [x] 5 — [Primeiro admin por convite](5_task.md) · `creed-backend`
- [x] 6 — [Front sem tela de senha, com reset por e-mail e convite de membro](6_task.md) · `creed-frontend`
- [x] 7 — [Produção recebe o SMTP e os ajustes do realm](7_task.md) · `creed-infrastructure` (parte versionada; rodar na EC2 espera o release)
- [x] 8 — [Documentos refletem o convite](8_task.md) · `creed-ai-context`

Marque aqui ao concluir cada task ([`workflows/tasks-to-code.md`](../../workflows/tasks-to-code.md)).

## Ordem e corte

```
PR #47 (guarda do DELETE) ──┐
                             ▼
1 (e-mail local) ──► 2 (acesso nos dois lados) ──► 3 (membros) ──► 4 (reenvio e reset)
       │                     └──────────────────► 5 (primeiro admin)
       └──► 7 (produção) ··· roda em produção só depois do release
6 (front) ── começa já, contra o contrato da spec
8 (documentos) ── fecha atrás de 2 a 7
```

- **A 1 vem primeiro.** Ela cria as settings que a 2 lê e o Mailpit que prova a 2.
- **A 2 depois do [creed-backend#47](https://github.com/creed-educa-ai/creed-backend/pull/47).**
  É a guarda de `admin` no `DELETE /users`, mergeada na `dev` em 27/10. A 2 também mexe no
  `DELETE`: comece da `dev` atual, que já tem a guarda.
- **A 3, a 4 e a 5 depois da 2.** A 3 e a 4, nessa ordem: as duas mexem em
  `users/service.py`, `users/router.py` e `tests/test_openapi.py`. A 5 só toca `scripts/`
  e `Dockerfile`, então pode andar junto com a 3 e a 4.
- **A 6 começa já**, contra o contrato da spec. O que ela não consegue provar sem o back
  está no [`6_task.md`](6_task.md).
- **A 7**: o script e o compose podem andar depois da 1. Rodar em produção depende do
  release, e o release depende da consolidação das migrations (CREED-57, ADR-0009,
  item 6).
- **A 8 é o último PR**, no harness, com base na `main`.

**Fora do board, mas no caminho:**

- a consolidação das migrations (CREED-57, backlog). Sem ela, o fluxo não sobe num banco
  limpo, porque falta a tabela `organizations`;
- o acesso à EC2 (Enzo, dono da CREED-28);
- as credenciais do Gmail do projeto, que ficam com o Enzo: o SMTP de produção é o do
  Google, não o SES (adendo de 2026-10-27 do ADR-0006). A senha de app vai para o
  `/opt/creed/.env` antes da task 7.

**Tamanho:**

| Tasks | Tamanho |
|---|---|
| 2 | a maior, perto de um dia e meio |
| 1, 3 e 6 | perto de um dia cada |
| 4, 5, 7 e 8 | meio dia cada |

## Achados ao decompor, que a spec não previa

- **`tests/test_openapi.py`.** Ele lista as rotas que precisam de `summary`, `description`
  e `operation_id`. Também confere as respostas documentadas de `POST /users` e
  `DELETE /users/{user_id}` (`test_success_error_and_bearer_authentication_responses_are_documented`).
  As rotas novas e o 503 entram nesse arquivo, nas tasks 2, 3 e 4.
- **Seis testes de `tests/domains/users/test_service.py`** montam `UserCreate` com
  `keycloak_id`. A task 2 os refaz com um `admin.py` falso.
- **`tests/domains/authentication/test_service.py`** levanta `KeycloakUnavailableError` e
  espera o erro de credencial. A task 2 inverte para `ServiceUnavailableError`.
- **O i18n do front é tipado pelo pt-BR** (`en: typeof ptBR`). As chaves da tela de senha
  saem dos três idiomas no mesmo commit (task 6).
- **A imagem do back não leva `scripts/`.** O `Dockerfile` copia só `app`, `alembic` e
  `alembic.ini`. Sem `COPY scripts`, o script do primeiro admin não roda em produção
  (task 5).

## Fora do escopo desta rodada

O "Não entra" da spec, resumido:

- status do convite e tabela de membros (CREED-503);
- página do painel da empresa (CREED-50);
- mentorandos e aprovação de empresas (CREED-594, 591 e 595);
- excluir membro por inteiro;
- tema de e-mail próprio;
- `PATCH` de papel e de status;
- busca do usuário pelo `sub`;
- 503 na guarda das rotas;
- limite de envios;
- domínio próprio;
- SMTP do N8N.
