# Tasks — <ID ClickUp> <título>

Spec: [`spec.md`](spec.md)

## Progresso

- [ ] 1 — <título> · `creed-backend`
- [ ] 2 — <título> · `creed-frontend`

Marque aqui ao concluir cada task (`workflows/tasks-to-code.md`).

---

<!-- Cada task vira um arquivo N_task.md com o formato abaixo -->

# Task N — <título>

**Repo:** `creed-<repo>`
**Depende de:** task N-1 (ou "nenhuma")

## Objetivo

<Um entregável funcional e testável. Uma frase.>

## Arquivos que provavelmente mudam

- `app/domains/<nome>/service.py`
- `tests/domains/<nome>/test_service.py`

<Provavelmente, não obrigatoriamente. Se a implementação pedir outro arquivo, tudo bem;
se pedir outro *repo*, a task estava errada.>

## Molde

<Qual arquivo do domínio/feature-exemplo copiar a forma. Ex.:
`app/domains/respondentes/service.py`>

## Critérios de aceite

- [ ] <verificável>

## Como testar

```bash
pytest tests/domains/<nome> -q
```

<Caso feliz + caso de borda. Se corrige bug: o teste falha sem a correção.>

## Premissas aplicáveis

- P-NNN — <interpretação> (ou "nenhuma")
