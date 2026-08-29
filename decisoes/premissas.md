# Ledger de premissas

Registro de toda interpretação de produto adotada pelo time **sem confirmação da
cliente**. Regras: [`../conventions/premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md).

- ID sequencial `P-NNN`, **nunca reaproveitado**.
- Premissa escrita como **afirmação**, não pergunta.
- Premissa fechada **fica aqui** com o desfecho — é o que evita rediscutir na sprint
  seguinte.
- Status: 🟡 aberta · ✅ confirmada · ❌ refutada.

| ID | Data | Assunto | Premissa adotada | Por quê | Reverter | Tarefa | Status |
|---|---|---|---|---|---|---|---|
| P-001 | 2026-08-29 | glossário | Os termos do `glossario.md` (respondente, prisma, prognóstico, relatório, dashboard) têm o sentido inferido do código existente. | Os domínios já existem no backend com esses nomes; renomear depois é migration, não refactor. | médio | — | 🟡 aberta |
| P-002 | 2026-08-29 | processo | O time adota este harness como fonte única de padrões para todas as ferramentas de IA. | Sem ele, cada colega instrui o próprio modelo de um jeito e o código diverge por ferramenta. | baixo | — | 🟡 aberta |

<!-- Exemplo do formato — apagar quando houver premissas reais suficientes:
| P-003 | 2026-09-05 | prognosticos | O prognóstico considera apenas respondentes ativos. | Consistência com `respondentes`; incluir inativos depois é filtro, excluir depois exige recalcular histórico. | baixo | 42 | 🟡 aberta |
-->

## Fechadas

<Mover para cá as premissas com desfecho, mantendo a linha completa e a data da
reunião que decidiu.>
