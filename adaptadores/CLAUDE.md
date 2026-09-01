<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->
<!-- Fonte: creed-ai-context/adaptadores/CLAUDE.md -->

# CREED.ai Educa

O contexto deste projeto vive em **`creed-ai-context/`**, compartilhado com as outras
ferramentas de IA do time (Codex, Copilot, Cursor).

## Leia primeiro

@creed-ai-context/CONTEXT.md

## Ao começar qualquer tarefa

1. `creed-ai-context/CONTEXT.md` — princípios, pipeline, prioridade em conflitos
2. `creed-ai-context/context/trabalho-com-ia.md` — as seis regras
3. `creed-ai-context/catalogo.md` — o que é cada repo, domínio e feature
4. O **molde**: `creed-backend/app/domains/respondentes/` ou
   `creed-frontend/src/features/respondentes/`

## Ao implementar

- Nível do time, não código esperto —
  `creed-ai-context/conventions/nivel-de-codigo.md`.
- Bifurcação técnica real: **pare e pergunte** (máx. 2 por task) —
  `creed-ai-context/workflows/tasks-to-code.md` → "Parada de decisão".
- Encerre no formato de `creed-ai-context/templates/entrega-didatica.md`:
  abordagem, **o que foi descartado**, mapa do diff, o que os testes não provam.

## Nunca

- `git add` / `commit` / `push` / criar branch / abrir PR sem pedido explícito
  (`creed-ai-context/playbooks/abrir-pr.md`).
- Rodar `alembic upgrade` fora do banco local, ou `kubectl`/`helm`/`aws` contra
  ambiente real.
- Dizer que rodou a suíte sem ter rodado.
- Preencher lacuna de produto em silêncio — vira premissa
  (`creed-ai-context/conventions/premissas-e-duvidas.md`).
- Entregar código sem explicar a abordagem e as alternativas descartadas.

## Comandos

`/calibrar` · `/spec` · `/tasks` · `/atualizar-spec` · `/implementar` · `/revisar` · `/pr` · `/premissa` · `/pauta`
