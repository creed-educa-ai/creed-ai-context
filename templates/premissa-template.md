# Premissa P-NNN

Formato de uma linha no ledger (`decisoes/premissas.md`):

```markdown
| P-007 | 2026-08-29 | prognosticos | O prognóstico considera apenas respondentes ativos. | Consistência com `respondentes`; incluir inativos depois é filtro, excluir depois exige recalcular histórico. | baixo | THK-... | 🟡 aberta |
```

Colunas:

| Coluna | O que é |
|---|---|
| ID | `P-NNN`, sequencial, nunca reaproveitado |
| Data | quando foi adotada |
| Assunto | domínio/feature ou "produto" |
| Premissa | a interpretação adotada, **afirmativa** — não é pergunta |
| Por quê | qual dos critérios de escolha aplicou (`conventions/premissas-e-duvidas.md`) |
| Custo de reverter | baixo / médio / alto |
| Tarefa | ID do ClickUp onde foi usada |
| Status | 🟡 aberta · ✅ confirmada · ❌ refutada |

Marcador no artefato onde a premissa foi aplicada:

```markdown
> 🟡 **Premissa P-007** — o prognóstico considera apenas respondentes ativos.
> Confirmar na próxima reunião.
```

A premissa é escrita como **afirmação**, não pergunta. "Considera apenas ativos" —
não "considera inativos?". A pergunta é derivada dela na hora de montar a pauta.
