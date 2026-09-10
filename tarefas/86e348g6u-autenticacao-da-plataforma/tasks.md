# Tasks — CREED-23 Estruturar autenticação da plataforma

Spec: [`spec.md`](spec.md) · Contrato: [`contrato-api.md`](contrato-api.md)

Este épico não foi decomposto em tasks pequenas aqui: cada linha abaixo é uma **entrega**
que já existe como subtarefa no ClickUp, com escopo e critério de aceite escritos lá.
O arquivo `N_task.md` nasce quando alguém pega a entrega, e traz o recorte de código.

## Progresso

- [ ] 1 — Inaugurar o banco (modelo, entidades, primeira migration) · `creed-backend`
- [x] 2 — [Keycloak no ambiente local com realm versionado](2_task.md) · `creed-backend`
- [ ] 3 — Domínio `users`: provisionamento e seed do primeiro admin · `creed-backend`
- [ ] 4 — Domínio `authentication` e a guarda de rota compartilhada · `creed-backend`
- [ ] 5 — Sessão autenticada no front (`session.ts` + `apiClient`) · `creed-frontend`
- [ ] 6 — Tela de login e proteção de rota · `creed-frontend`
- [ ] 7 — Nível de acesso por tela · `creed-frontend`

Marque aqui ao concluir cada entrega (`workflows/tasks-to-code.md`).

## Ordem e corte

```
1 (banco) ──┐
            ├──► 3 (users) ──► 4 (authentication)
2 (keycloak)┘

[contrato acordado] ──► 5 (sessão) ──► 6 (login) ──► 7 (acesso por tela)
```

**1 e 2 são independentes entre si** — o Keycloak local não precisa do nosso schema, e o
schema não precisa dele. **3 precisa das duas; 4 precisa da 3.** **5 e 6 não esperam a 4
terminar**: programam contra [`contrato-api.md`](contrato-api.md), que é exatamente o que
esse documento existe para permitir. **7 fecha atrás da 6.**

## Fora do escopo desta rodada

- **Keycloak no EKS** — manifest, schema no RDS, ADR do componente novo. Não bloqueia
  nada: as 7 entregas rodam inteiras em ambiente local. Sem tarefa no board.
- **Convite de primeiro acesso por e-mail** — premissa P-012, subtarefa CREED-23.8 no
  ClickUp. Adiada de propósito; no interim a senha é definitiva e passada por fora.
