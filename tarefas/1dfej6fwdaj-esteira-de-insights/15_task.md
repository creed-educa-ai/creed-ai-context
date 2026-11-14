# Task 15 — Ramo da empresa no N8N

**Repo:** o ramo é montado no **N8N da AWS**. O registro fica no `creed-backend`, em
`docker/n8n/`.
**Depende de:** tasks 8 e 13

## Objetivo

O workflow passa a tratar `scope = "organization"` com o prompt da empresa, e a
avaliação ganha três perfis de empresa.

## Arquivos que provavelmente mudam

No N8N: o sub-workflow "gerar insight" (ramo da empresa) e o workflow de avaliação.

No `creed-backend`:

- `docker/n8n/prompts/empresa.md`
- `docker/n8n/avaliacao/perfis-empresa.json` e `resultado-empresa-v1.md`
- `docker/n8n/contrato/saida-n8n-empresa.json`
- `docker/n8n/workflows/*.json`, exportados de novo
- `tests/n8n/test_prompts.py`
- `tests/external_services/n8n/test_contrato.py`

## Molde

- A task 8: os prompts e a avaliação do individual.
- Spec, "Abordagem técnica", item 2.3: o que um bom insight da empresa faz.

## Critérios de aceite

- [ ] O `exemplo-ida-empresa.json` é aceito pelo nó de validação.
- [ ] O ramo da empresa usa os mesmos blocos 1 a 4 do individual, para o cache servir
      aos dois, e o `empresa.md` nos blocos 5 e 6.
- [ ] O `prompt_version` é `empresa-v1+dossie-v1`.
- [ ] Os três perfis (alinhada, dividida, e com um setor que destoa) passam nos
      critérios automáticos e em mais um: nenhuma frase permite identificar uma pessoa.
- [ ] Duas pessoas fazem a leitura humana dos três perfis, registrada em
      `resultado-empresa-v1.md`.
- [ ] A `saida-n8n-empresa.json` valida contra o `volta.schema.json`, num teste do back.
- [ ] Os JSON exportados não contêm segredo.

## Como testar

No N8N: executar a avaliação com os perfis de empresa.

No `creed-backend`:

```bash
pytest tests/n8n tests/external_services/n8n -q
```

## Premissas aplicáveis

- P-089: insight da empresa por período
- P-090: nenhum texto livre no agregado
- P-094: desenvolvimento, não diagnóstico
