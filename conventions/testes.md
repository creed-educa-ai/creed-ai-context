# Testes

## Princípio

Teste existe para **falhar no lugar certo**. Se um teste de rota quebra quando muda
uma regra de negócio, ele está no nível errado.

## Backend

| Camada | Como testar | Dependência |
|---|---|---|
| `service.py` | regra de negócio, casos de borda | repository fake/mock |
| `repository.py` | query e agregação | banco real (`docker compose up -d db`) |
| `router.py` | contrato: status, shape, validação de entrada | app de teste |

Um teste de agregação **precisa** de banco real — mock de query não testa `GROUP BY`.

```bash
pytest
pytest tests/domains/respondentes -q
```

## Frontend

| Coisa | Como testar |
|---|---|
| slice | reducers e selectors, direto — sem render |
| View | render + interação do usuário, sem espiar estado interno |
| api | mock de rede; não testa o backend |

```bash
npm run test:run
npm run check     # o que o CI roda
```

## Cobertura mínima por task

Uma task não está pronta sem:

- caso feliz;
- pelo menos um caso de borda (vazio, nulo, limite);
- se corrigiu bug: **teste que falha sem a correção**. Escreva o teste, veja vermelho,
  então corrija.

## Dado de teste

Sintético, sempre. Nunca dado real de respondente em fixture, seed ou snapshot —
inclusive em teste local (`../context/trabalho-com-ia.md` §5).
