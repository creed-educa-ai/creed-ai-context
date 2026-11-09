# Task 1 — Buscar ou criar o setor da empresa por tipo

**Repo:** `creed-backend`
**Depende de:** nenhuma

## Objetivo

`DepartmentService.get_or_create(organization_id, type)` devolve o setor daquele tipo que
a empresa já tem, ou cria na hora. Dois pedidos simultâneos não duplicam o setor nem
geram 500.

## Contexto

O setor (`Department`) é uma linha por empresa e por tipo. São cinco tipos fixos
(`DepartmentType`: `Marketing`, `Financeiro`, `Administrativo`, `RecursosHumanos`,
`TecnologiaInformacao`), e o banco garante um por empresa com a restrição única
`uq_departments_organization_type`. Não há tela de cadastro de setor: quem cria é a troca
de setor do membro (task 2).

## Arquivos que provavelmente mudam

- `app/domains/department/repository.py`: dois métodos novos.
  - `get_by_organization_and_type(organization_id, type) -> Department | None`
  - `create_if_absent(department) -> Department | None`: grava dentro de um
    **savepoint** (`async with self.db.begin_nested():`). Se o `flush()` bater na
    `uq_departments_organization_type`, devolve `None`. Qualquer outro `IntegrityError` é
    relançado.
- `app/domains/department/service.py`: `get_or_create(organization_id, type) -> Department`.
  Busca; se não achar, chama `create_if_absent`; se vier `None` (outro pedido criou no
  meio), busca de novo e devolve o que achou.
- `tests/domains/sector/test_service_get_or_create.py` (novo)
- `tests/domains/sector/test_repository.py` (novo)

Os testes do domínio `department` moram em `tests/domains/sector/`, não em
`tests/domains/department/`. O `test_service.py` que já existe lá tem um dublê que guarda
um setor só; o do `get_or_create` precisa de lista e de corrida, por isso arquivo próprio.

**Por que savepoint:** no precedente (`ParticipantRepository.create`), a função acaba no
erro. Aqui ainda é preciso **ler depois** do conflito, e uma sessão que falhou no
`flush()` recusa a próxima consulta até alguém desfazer a transação. O savepoint desfaz
só o `INSERT` e mantém a transação do pedido viva.
**Descartado:** `INSERT ... ON CONFLICT DO NOTHING` (`sqlalchemy.dialects.postgresql.insert`).
Dá o mesmo resultado em menos linhas, mas não existe em nenhum lugar do código.

`get_or_create` não confere se a organização existe. Quem chama (task 2) já conferiu, e a
chave estrangeira garante o resto.

## Molde

- `app/domains/participants/repository.py` → `create` (o `except IntegrityError` com o
  nome da restrição)
- `tests/domains/participants/test_repository.py` (sessão falsa que levanta no `flush()`)
- `tests/domains/links/test_service.py` (dublê de repository em memória)

## Critérios de aceite

- [ ] Empresa sem o setor: `get_or_create` cria e devolve o setor novo.
- [ ] Empresa que já tem o setor: devolve o **mesmo** setor, sem chamar a criação.
- [ ] O mesmo tipo em duas empresas gera dois setores diferentes.
- [ ] Conflito na restrição única (outro pedido criou no meio): devolve o setor que o
      outro criou, sem exceção.
- [ ] `IntegrityError` de outra restrição é relançado.
- [ ] `ruff`, `mypy` e `pytest` passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/sector -q
ruff check . && ruff format --check . && mypy app
```

Casos nomeados: cria quando não existe (feliz), reaproveita quando existe, duas empresas,
corrida (o dublê do repository devolve `None` no `create_if_absent` e tem o setor na
segunda busca), outra violação relançada (sessão falsa, como no teste de `participants`).

**O que os testes não provam:** que o savepoint mantém a transação utilizável no Postgres
de verdade. A suíte não roda contra banco. Conferir uma vez à mão, com
`docker compose up -d db`, ou registrar no PR que não foi conferido.

## Premissas aplicáveis

- P-067: o setor que fica sem membro continua cadastrado. Esta task não apaga setor.
