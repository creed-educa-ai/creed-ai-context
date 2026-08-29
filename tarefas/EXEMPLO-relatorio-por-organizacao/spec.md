# EXEMPLO — Relatório de respondentes por organização

> ⚠️ **Exemplo, não tarefa real.** Serve para mostrar a forma. Não implemente.

## Problema

A organização não consegue ver, num lugar só, quantos respondentes concluíram os
instrumentos. Hoje isso é contado à mão exportando dados brutos.

## Quem usa

Gestor da organização, mensalmente, para acompanhar adesão.

## Escopo

**Entra:**
- Endpoint que devolve, por organização, total de respondentes e total de conclusões.
- Tela de relatório com a tabela e o filtro por organização.

**Não entra:**
- Exportação (PDF/CSV) — fica para tarefa própria.
- Recorte por período — não pedido.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | domínio `relatorios`: novo endpoint agregado |
| creed-frontend | feature `relatorios`: tela de listagem |
| creed-infrastructure | nada |

Nome do domínio/feature: `relatorios`

## Contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| GET | `/api/v1/relatorios/adesao` | `organizacao_id?` | `AdesaoRead[]` |

`AdesaoRead`: `organizacao_id`, `organizacao_nome`, `total_respondentes`,
`total_conclusoes`, `percentual_adesao`.

## Dados

Sem tabela nova. Agregação (`COUNT` + `GROUP BY organizacao_id`) no `repository.py`
de `relatorios`. Índice em `respondentes.organizacao_id` se ainda não existir —
verificar antes de criar migration.

## Critérios de aceite

- [ ] `GET /api/v1/relatorios/adesao` devolve uma linha por organização com dados.
- [ ] `percentual_adesao` vem calculado do backend, não do front.
- [ ] Organização sem respondente aparece com zeros, não some da lista.
- [ ] Tela mostra a tabela e o filtro; sem organização selecionada, mostra todas.

## Como verificar

1. `docker compose up -d db && alembic upgrade head && uvicorn app.main:app --reload`
2. `curl localhost:8000/api/v1/relatorios/adesao` — confere as colunas.
3. `npm run dev`, abrir a tela, filtrar por uma organização.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-00X | Respondente inativo **conta** no total da organização. | baixo |

## Riscos

- Agregação sem índice em `organizacao_id` fica lenta com volume. Sinal: query acima
  de ~200ms com poucos milhares de linhas.
