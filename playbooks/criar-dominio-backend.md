# Playbook: criar domínio no backend

**Quando:** a task cria um domínio novo em `app/domains/`, ou adiciona um recurso
completo (CRUD + regra) a um existente.

**Molde:** `app/domains/respondentes/` — **abra os arquivos do molde antes de escrever
qualquer linha.** Ele é canônico na **estrutura**; sobre os três pontos em que é dívida,
ver a dívida conhecida em
[`../conventions/camadas-do-back.md`](../conventions/camadas-do-back.md).

**Regras que mandam:**
[`camadas-do-back.md`](../conventions/camadas-do-back.md) ·
[`estrutura-e-nomes.md`](../conventions/estrutura-e-nomes.md) ·
[`migrations.md`](../conventions/migrations.md) ·
[`testes.md`](../conventions/testes.md) ·
[ADR-0004](../decisoes/adrs/0004-camadas-do-backend.md)

Para integrar com serviço de fora (N8N e afins), o playbook é
[`integrar-servico-externo.md`](integrar-servico-externo.md).

## Passo 0 — os campos existem?

**Antes de qualquer código.** Domínio novo começa por decidir o que a tabela guarda, e
isso é decisão de produto, não de implementação:

| O que você tem | Caminho |
|---|---|
| spec da tarefa com os campos | siga; a spec é a fonte |
| spec sem os campos, ou sem spec | vira premissa no ledger + pergunta na pauta, e o domínio espera ([`premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md)) |
| só o molde `respondentes` como referência | é scaffold: copie a **forma**, nunca os campos — `regiao`, `pais` e `genero` são exemplo plausível, não contrato acordado |

Campo inventado vira migration, e migration vira dado. É o passo mais barato de fazer e
o mais caro de pular.

## Ordem

1. **`models.py`** — tabela SQLAlchemy. Classe no singular, tabela no plural.
2. **Migration** — [`criar-migration.md`](criar-migration.md). Não pule para o passo 3
   antes da migration existir; schema é o que trava o resto.
3. **`schemas.py`** — Pydantic **separado por direção**: `<Entidade>Create`,
   `<Entidade>Update`, `<Entidade>Response`. Nunca um schema servindo entrada e saída.
   Listagem é `PaginaDe[<Entidade>Response]` de `app/shared/paginacao.py` — não escreva
   um `<Entidade>ListResponse` próprio. O mapeamento model → schema é
   `@classmethod de_model()` **aqui**, não no router.
4. **`repository.py`** — queries e agregações. É onde mora `SUM`, `COUNT`, `GROUP BY`.
   Recebe a sessão no construtor; devolve model, tupla ou escalar. Não decide regra e
   não levanta exceção de domínio — devolve `None`. Só `flush()`, nunca `commit()`.
5. **`service.py`** — regra de negócio. Classe, recebe o repository no construtor. Não
   importa `fastapi` nem `sqlalchemy`. Levanta exceção de `app/shared/exceptions.py`.
6. **`utils.py`** — o cálculo puro que saiu do service (sem sessão, sem I/O, sem
   `settings`).
7. **`constants.py`** — no primeiro número solto com significado.
8. **`dependencies.py`** — injeção: sessão → repository → service, exportando
   `ServiceDep`.
9. **`router.py`** — rotas. Recebe, valida via schema, delega ao service, devolve
   schema. Sem `if` de regra e **sem importar `models`**.
10. **Registrar o router** na tupla de `app/main.py`, junto com os outros.
11. **Testes** — `tests/domains/<nome>/`, um arquivo por camada
    ([`testes.md`](../conventions/testes.md)).

Os passos 6 e 7 criam arquivo **só quando há o que pôr dentro**: `utils.py` vazio é
ruído no diff e no `grep`.

## Fatiamento

Domínio inteiro num diff só é irrevisável, e o pior lugar para descobrir isso é na
review da migration. Corte por **fatia vertical**: model + migration + o primeiro caso
de uso de ponta a ponta primeiro; os demais endpoints depois, um por task. Cada fatia
sobe verde e é revisável sozinha.

Não corte por camada horizontal ("uma task para os schemas, outra para o service"):
task que não entrega comportamento não dá para revisar nem testar.

## Erros que este playbook existe para evitar

| Erro | Sinal |
|---|---|
| Campo inventado | coluna em `models.py` que não aparece em spec nem premissa |
| Regra no router | `if` sobre dado de negócio dentro da função de rota |
| Query no service | `select(`, `session.` ou `self.db` fora do repository |
| Router conhecendo tabela | `from app.domains.<x>.models import` no `router.py` |
| Schema único para entrada e saída | `id` opcional para servir aos dois casos |
| Paginação reescrita | `<Entidade>ListResponse` próprio em vez de `PaginaDe[T]` |
| Mapeamento no router | helper `_to_response()` na camada de HTTP |
| Cálculo puro preso no service | função sem `self` e sem repository dentro da classe |
| `commit()` fora do `get_db` | qualquer `commit()` em domínio |
| Repository decidindo | `raise NotFoundError` dentro do `repository.py` |
| Domínio importando domínio | `from app.domains.<outro>` fora do caso de leitura permitido |
| Agregação empurrada para o front | endpoint devolvendo lista crua onde a tela mostra total |
| Util global | função nova em `app/shared/utils.py` — arquivo proibido |

## Antes de fechar

```bash
ruff check . && ruff format --check .
mypy app
pytest tests/domains/<nome> -q
pytest tests/test_arquitetura.py -q
```

O último roda os `grep` de camada de
[`camadas-do-back.md`](../conventions/camadas-do-back.md). Vermelho ali não é estilo: é
camada furada.

E a checagem que nenhum comando faz: **o domínio novo se parece com `respondentes`?** Se
um colega abrir os dois lado a lado, a diferença deve ser só o assunto.
