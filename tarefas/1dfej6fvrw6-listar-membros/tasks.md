# Tasks — CREED-697 · M-2 · Listar os membros de uma organização

Spec: [`spec.md`](spec.md)

Branch: `feat/697-listar-membros`, saída da `feat/6910-trocar-setor-membro` (C-1)
**depois do commit dela**. O PR aponta para a branch da C-1 e passa a apontar para o
`dev` quando a C-1 for mergeada.

## Progresso

- [ ] 1 — Escolher o período de um membro · `creed-backend`
- [ ] 2 — Listar os membros com o período (service e repository de `links`) · `creed-backend`
- [ ] 3 — Rota `GET /organizations/{organization_id}/members` · `creed-backend`

Marque aqui ao concluir cada task (`workflows/tasks-to-code.md`).

## Por que três, e nesta ordem

- **1 sozinha:** é a regra de produto que mais pode mudar na reunião (P-068). Isolada
  numa função pura, ela tem teste próprio, e a task 2 a usa como caixa-preta.
- **2 separada de 3:** a montagem com três consultas e a regra de acesso são testáveis
  sem HTTP. A rota só traduz.

## Onde mora cada coisa, e por quê

O teste de arquitetura (`tests/test_arquitetura.py`) define o que `links` pode importar
de `forms`:

| Arquivo de `links` | Pode importar de `forms` | Por quê |
|---|---|---|
| `service.py` | só o `service.py` | composição (`COMPOE_COM_SERVICE_DE`) |
| `repository.py` | o `models.py` | leitura por JOIN (`LEITURA_ENTRE_DOMINIOS`, declarada na C-1) |
| `schemas.py` | o `schemas.py`, com entrada nova em `SCHEMA_DE_SAIDA_DE_OUTRO_DOMINIO` | o `PeriodStatus` mora em `forms/schemas.py` |

Por isso a regra de escolha (`pick_period`) mora em `forms/service.py`, ao lado da
regra de janela (`period_status`), e o service de `links` só a chama.

## Molde

| Para quê | Copiar de |
|---|---|
| Situação do período | `_period_status` e `list_periods` em `app/domains/forms/service.py` |
| Desempate entre dois abertos | `FormRepository.get_open_for_link` em `app/domains/forms/repository.py` |
| Leitura do membro por JOIN | `LinkRepository.get_member` (C-1) |
| Schema que estende outro | `PeriodRead(FormRead)` em `app/domains/forms/schemas.py` |
| Regra de acesso dos membros | `LinkService._check_can_manage_members` (C-1) |
| Rota e testes de rota | `router_members.py` e `tests/domains/links/test_router_members.py` (C-1) |
