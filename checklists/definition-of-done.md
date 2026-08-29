# Definition of Done

Uma task só está pronta quando **todas** valem:

## Código
- [ ] Critérios de aceite atendidos — todos, não a maioria.
- [ ] Segue a estrutura do molde (`respondentes` no back, `respondentes` no front).
- [ ] Sem regra de negócio no `router.py`, sem query no `service.py`, sem agregação
      no front.
- [ ] Sem credencial, `.env` ou dado pessoal real no diff.

## Testes
- [ ] Caso feliz + pelo menos um caso de borda.
- [ ] Bug corrigido tem teste que falha sem a correção.
- [ ] **Suíte local rodada por um humano** e verde:
      backend `ruff check . && mypy app && pytest` · front `npm run check`.

## Migration (se houver)
- [ ] Arquivo lido **linha a linha** por um humano.
- [ ] `alembic heads` retorna um único head.
- [ ] Mudança destrutiva quebrada em passos.

## Rastro
- [ ] Premissa usada está no ledger e marcada no artefato.
- [ ] Documentação tocada quando o comportamento mudou (README do repo, glossário).
- [ ] Task marcada em `tarefas/<ID>/tasks.md`.

## PR
- [ ] Nome da branch no padrão 🔒.
- [ ] Descrição diz o que muda, por quê e **como o revisor verifica**.
- [ ] Tarefa do ClickUp vinculada.
- [ ] Linha de rastreabilidade de IA (`../context/trabalho-com-ia.md` §4).

> O item que mais falha na prática é "suíte local rodada **por um humano**". Agente
> dizer que rodou não substitui — rode você, antes de abrir o PR.
