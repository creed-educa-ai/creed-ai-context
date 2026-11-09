# Task 1 — Escolher o período de um membro

**Repo:** `creed-backend`
**Depende de:** nenhuma (precisa só da P-6, que já está no `dev`)

## Objetivo

Uma função pura que, dada a lista de períodos de uma organização, devolve **o** período
de um membro, pela regra da P-068. Sem banco: recebe os formulários já lidos.

## Contexto

Um **período** é um formulário (`Form`) com `opens_at` e `closes_at` preenchidos (P-6).
O `Form.link_id` diz para quem ele vale: nulo é para a organização inteira, e preenchido
é só para a pessoa daquele vínculo (o caso do mentorando). A **situação** do período, em
relação a agora, é `open` (`opens_at <= agora < closes_at`), `scheduled` (ainda não abriu)
ou `past` (já fechou). Quem calcula isso hoje é o `_period_status`, privado, em
`app/domains/forms/service.py`.

**A regra (P-068):** o período de um membro é, nesta ordem:
1. o **aberto** agora; entre dois abertos, o **individual** antes do "para todos" e,
   depois, o que **abriu por último** (a mesma ordem do `get_open_for_link`);
2. se não houver aberto, o **próximo agendado** (o que abre primeiro);
3. se não houver agendado, o **último que fechou** (o que fechou por último);
4. se não houver nenhum, `None`.

Só contam os períodos que valem para a pessoa: `link_id` nulo ou igual ao vínculo dela.

## Arquivos que provavelmente mudam

- `app/domains/forms/service.py`
  - `_period_status` passa a ser `period_status` (pública). O `list_periods` usa o nome
    novo.
  - `pick_period(periods: list[Form], link_id: uuid.UUID, now: datetime) -> Form | None`:
    função de módulo, ao lado da `period_status`. Filtra os que valem para o vínculo,
    separa por situação e aplica a ordem acima. Use `for` e `if` explícitos, com
    `min`/`max` e uma `key` nomeada. Nada de ordenação com tupla de quatro critérios
    numa linha só.
- `tests/domains/forms/test_pick_period.py` (novo)

## Molde

- `_period_status` e `list_periods` em `app/domains/forms/service.py`
- `get_open_for_link` em `app/domains/forms/repository.py` (o `order_by` dele é o
  desempate entre abertos)

## Critérios de aceite

- [ ] Aberto e agendado: vem o aberto.
- [ ] Dois abertos, um individual e um "para todos": vem o individual, mesmo que o "para
      todos" tenha aberto depois.
- [ ] Dois abertos "para todos": vem o que abriu por último.
- [ ] Só agendados: vem o que abre primeiro.
- [ ] Só fechados: vem o que fechou por último.
- [ ] O período individual de **outra** pessoa é ignorado, inclusive quando é o único
      aberto.
- [ ] Formulário sem `opens_at`/`closes_at` é ignorado.
- [ ] Lista vazia, ou sem nenhum período que valha para a pessoa: `None`.
- [ ] Bordas da janela: em `now == opens_at` está aberto; em `now == closes_at` já
      fechou.
- [ ] Os testes atuais de `forms` continuam passando com o nome novo.

## Como testar

```bash
cd creed-backend
pytest tests/domains/forms -q
ruff check . && ruff format --check . && mypy app
```

Os `Form` dos testes são montados à mão, com `now` fixo. Nada de `datetime.now()`
dentro do teste.

## Premissas aplicáveis

- P-068: a ordem de escolha do período.
