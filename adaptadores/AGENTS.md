<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->
<!-- Fonte: creed-ai-context/adaptadores/AGENTS.md -->

# CREED.ai Educa — instruções para agentes

O contexto completo vive em **`creed-ai-context/`** (mesmo conteúdo para Claude Code,
Codex, Copilot e Cursor). Se você estiver num repo isolado e não enxergar essa pasta,
ela está no diretório-pai do workspace: `ages/creed-ai-context/`.

## Ordem de leitura

1. `creed-ai-context/CONTEXT.md` — entry point
2. `creed-ai-context/context/trabalho-com-ia.md` — regras de IA
3. `creed-ai-context/catalogo.md` — repos, domínios, features
4. O molde do que você vai mexer:
   `creed-backend/app/domains/respondentes/` ou
   `creed-frontend/src/features/respondentes/`

## Princípios inegociáveis

1. Agregação no banco, cálculo no backend, renderização no front.
2. Migrations nunca no startup do container — Job dedicado.
3. Autogenerate de migration sempre revisado linha a linha por um humano.
4. CI é obrigatório; pre-commit acelera, CI garante.
5. Estrutura por domínio (back) e por feature (front), espelhadas.
6. Lacuna de produto vira **premissa registrada**, não bloqueio —
   `creed-ai-context/conventions/premissas-e-duvidas.md`.
7. Código entregue por IA precisa ser **defensável por quem entrega** —
   `creed-ai-context/context/aprendizado.md`.

## Fluxo

tarefa (ClickUp) → spec → tasks → código → review → PR.
Workflows em `creed-ai-context/workflows/`. Playbooks técnicos em
`creed-ai-context/playbooks/`.

## Restrições

- **Não versione por conta própria**: nada de `git add`/`commit`/`push`/branch/PR sem
  pedido explícito. Leitura (`status`, `diff`, `log`) é livre.
- **Escopo fechado**: só o que a task pede entra no diff.
- **Migration**: proponha e avise que precisa de leitura humana linha a linha.
- **Nunca** rode `alembic upgrade` fora do banco local, nem `kubectl`/`helm`/`aws`
  contra ambiente real.
- **Nunca** coloque credencial, `.env` real ou dado pessoal de respondente em código,
  teste ou prompt.
- **Nível do time, não código esperto**: um colega entende o arquivo em uma passada —
  `creed-ai-context/conventions/nivel-de-codigo.md`.
- **Bifurcação técnica real: pare e pergunte** (2 opções, trade-off, recomendação;
  máx. 2 por task) — `creed-ai-context/workflows/tasks-to-code.md`.

## Encerramento de implementação

Formato fixo em `creed-ai-context/templates/entrega-didatica.md`: o que a task pedia ·
abordagem e por que esta · **o que foi descartado e por quê** · mapa do diff · o que os
testes provam e o que **não** provam · decisões do humano · onde pode quebrar · e o
bloco operacional (arquivos, suíte, premissas, fora de escopo). Explique decisão, não
sintaxe.

## Qualidade antes de considerar terminado

```
backend:  ruff check . && ruff format --check . && mypy app && pytest
frontend: npm run check
```

## Branch e commit (🔒 cobrado pelo GitHub)

Branch: `<slug>/<id-clickup>-<contexto>` — ex. `feat/1-criar-usuarios`.
Commit: Conventional Commits, imperativo, minúscula, até 72 caracteres.
Detalhes: `creed-ai-context/conventions/git-workflow.md`.
