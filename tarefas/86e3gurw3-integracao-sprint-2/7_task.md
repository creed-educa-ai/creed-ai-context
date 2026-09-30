# Task 7 — Seed de demonstração

**Repo:** `creed-backend`
**Depende de:** tasks 1 a 6.

## Objetivo

`python scripts/seed_local.py` deixa o ambiente local pronto para a apresentação: além do
usuário de dev, há um formulário da organização `…0001` com perguntas descritivas, que
o `dev@creed.example.com` pode abrir, responder e enviar.

## Contexto que você não tem como adivinhar

**O conteúdo do instrumento é da cliente.** Os textos das perguntas são sintéticos e
dizem que são de demonstração, por exemplo começando com "[Demonstração]". Nada que
pareça proposta de pergunta real (spec, risco "o formulário de demonstração parece o
instrumento real").

**Ids fixos e idempotência**, como o seed já faz com o participante e a organização. O
formulário tem id fixo (`…0003`). As perguntas se reconhecem por `(form_id,
order_index)`, que já é único. Rodar duas vezes não duplica nada.

**Três perguntas, uma por seção** (`profile`, `assessment`, `closing`; P-020), todas
`descriptive` (D2). Duas obrigatórias e uma opcional, para a demonstração mostrar a
task 6 barrando o envio e depois aceitando.

**O seed escreve pelos repositories**, como já faz com `UserRepository` e
`LinkRepository`. Não passa pelos services, que exigiriam um usuário autenticado.

**O seed continua recusando `ENVIRONMENT` diferente de `local`.**

## Arquivos que provavelmente mudam

- `scripts/seed_local.py`

## Molde

O próprio `scripts/seed_local.py`: constantes fixas no topo e o padrão "busca; se não
existe, cria".

## Critérios de aceite

- [ ] Banco zerado (`alembic upgrade head` e seed): formulário `…0003` com três perguntas
      descritivas.
- [ ] Seed rodado de novo: nenhuma linha nova, sem erro.
- [ ] Com o token do `dev`: `GET /forms/…0003/questions` devolve as três perguntas, na
      ordem.
- [ ] Fluxo da spec ("Como verificar", passos 8 a 11) roda de ponta a ponta sobre esse
      formulário.
- [ ] A saída do seed diz o id do formulário de demonstração.

## Como testar

```bash
cd creed-backend
python scripts/seed_local.py
python scripts/seed_local.py   # segunda vez: nada novo
```

Depois, o roteiro "Como verificar" da spec no Swagger.

## Premissas aplicáveis

- **P-020**: os valores de seção são provisórios.
- **P-031**: o `admin` de dev pode responder, porque é da organização do formulário.
