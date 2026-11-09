# Tasks — CREED-6910 · C-1 · Trocar o setor de um membro

Spec: [`spec.md`](spec.md)

Branch: `feat/6910-trocar-setor-membro`, saída do `dev` em `e37c0a1`.

## Progresso

- [x] 1 — Buscar ou criar o setor da empresa por tipo · `creed-backend`
- [x] 2 — Trocar o setor de um vínculo (service e repository de `links`) · `creed-backend`
- [x] 3 — Rota `PATCH /organizations/{organization_id}/members/{link_id}` · `creed-backend`

Marque aqui ao concluir cada task (`workflows/tasks-to-code.md`).

## Por que três, e nesta ordem

- **1 antes de 2:** a troca precisa de "o setor X desta empresa", que hoje não existe. O
  `DepartmentService` só busca setor por id e cria setor sem conferir se ele já existe.
- **2 separada de 3:** a regra (quem pode, o que é 404, o que `null` faz) fica testável
  sem HTTP. A rota só traduz exceção em código. Juntas, passariam de um dia de trabalho.

## Molde

O `app/domains/respondentes/`, que o `CLAUDE.md` aponta como molde, **está vazio no
`dev`** (só tem `__pycache__`). As tasks copiam a forma do que já existe e faz a mesma
coisa:

| Para quê | Copiar de |
|---|---|
| Rota de sub-recurso de organização | `app/domains/links/router.py` |
| Segundo router no mesmo domínio | `app/domains/questions/router_options.py` |
| 403 antes de 404 | `OrganizationService.get`, em `app/domains/organizacoes/service.py` |
| `IntegrityError` da regra única | `ParticipantRepository.create`, em `app/domains/participants/repository.py` |
| Teste de service com dublês | `tests/domains/links/test_service.py` |
| Teste de rota com token falso | `tests/domains/links/test_router.py` |
