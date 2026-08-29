# Playbook: criar domínio no backend

**Quando:** a task cria um domínio novo em `app/domains/`, ou adiciona um recurso
completo (CRUD + regra) a um existente.

**Molde:** `app/domains/respondentes/` — **abra os sete arquivos antes de escrever
qualquer linha.** Este playbook é lembrete; o molde é a fonte.

## Ordem

1. **`models.py`** — tabela SQLAlchemy. Nome da classe no singular, tabela no plural.
2. **Migration** — `../playbooks/criar-migration.md`. Não pule para o passo 3 antes
   da migration existir; schema é o que trava o resto.
3. **`schemas.py`** — Pydantic **separado por direção**: `<Entidade>Create`,
   `<Entidade>Read`, `<Entidade>Update`. Nunca um schema servindo entrada e saída.
4. **`repository.py`** — queries e agregações. É aqui que mora `SUM`, `COUNT`,
   `GROUP BY`. Recebe sessão, devolve model ou tupla; não decide regra.
5. **`service.py`** — regra de negócio. Não importa nada de `fastapi`, não monta
   query. Levanta exceção de `app/shared/exceptions.py`.
6. **`dependencies.py`** — injeção da sessão e do service.
7. **`router.py`** — rotas. Recebe, valida via schema, delega ao service, devolve
   schema. Sem `if` de regra de negócio.
8. **Registrar o router** onde os outros estão registrados (siga `respondentes`).
9. **Testes** — `tests/domains/<nome>/`, um arquivo por camada
   (`../conventions/testes.md`).

## Erros que este playbook existe para evitar

| Erro | Sinal |
|---|---|
| Regra no router | `if` sobre dado de negócio dentro da função de rota |
| Query no service | `select(`, `session.` fora do repository |
| Schema único para entrada e saída | `id` opcional para servir aos dois casos |
| Domínio importando model de outro | `from app.domains.outro.models import` |
| Agregação empurrada para o front | endpoint devolvendo lista crua onde a tela mostra total |

## Antes de fechar

```bash
ruff check . && ruff format --check .
mypy app
pytest tests/domains/<nome> -q
```

E a checagem que nenhum comando faz: **o domínio novo se parece com `respondentes`?**
Se um colega abrir os dois lado a lado, a diferença deve ser só o assunto.
