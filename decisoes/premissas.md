# Ledger de premissas

Registro de toda interpretação de produto adotada pelo time **sem confirmação da
cliente**. Regras: [`../conventions/premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md).

- ID sequencial `P-NNN`, **nunca reaproveitado**.
- Premissa escrita como **afirmação**, não pergunta.
- Premissa fechada **fica aqui** com o desfecho — é o que evita rediscutir na sprint
  seguinte.
- Status: 🟡 aberta · ✅ confirmada · ❌ refutada.
- Tarefa `EXEMPLO`: a premissa nasceu de um **ensaio da esteira**, não de trabalho
  entregue. Fica registrada — o ID nunca se reaproveita — mas **não entra na pauta da
  cliente** e não vale como decisão de produto.

| ID | Data | Assunto | Premissa adotada | Por quê | Reverter | Tarefa | Status |
|---|---|---|---|---|---|---|---|
| P-001 | 2026-08-29 | glossário | Os termos do `glossario.md` (respondente, prisma, prognóstico, relatório, dashboard) têm o sentido inferido do código existente. | Os domínios já existem no backend com esses nomes; renomear depois é migration, não refactor. | médio | — | 🟡 aberta |
| P-002 | 2026-08-29 | processo | O time adota este harness como fonte única de padrões para todas as ferramentas de IA. | Sem ele, cada colega instrui o próprio modelo de um jeito e o código diverge por ferramenta. | baixo | — | 🟡 aberta |
| P-003 | 2026-09-01 | navegação | Os papéis desta fase são `admin` e `funcionario`, dois níveis apenas. | A tarefa cita só esses dois; criar hierarquia maior agora é escopo que ninguém pediu, e acrescentar papel depois é acrescentar valor a um union type. | baixo | EXEMPLO | 🟡 aberta |
| P-004 | 2026-09-01 | navegação | O papel do usuário vem do estado do front (slice dedicado, valor fixo em desenvolvimento) até a autenticação existir. | Não há login nem endpoint de papéis, e a autenticação como funcionalidade não tem tarefa no board (CREED-5 e CREED-13 são protótipo #FIGMA); o menu não pode esperar por ela, e trocar a origem do papel depois é mexer em um seletor. | baixo | EXEMPLO | 🟡 aberta |
| P-005 | 2026-09-01 | navegação | O menu lista apenas rotas já registradas em `routes.tsx`; tela desenhada no Figma e ainda sem rota não vira item. | Item que aponta para lugar nenhum é bug na mão do usuário; acrescentar item quando a rota nascer é uma linha. | baixo | EXEMPLO | 🟡 aberta |

## Fechadas

<Mover para cá as premissas com desfecho, mantendo a linha completa e a data da
reunião que decidiu.>
