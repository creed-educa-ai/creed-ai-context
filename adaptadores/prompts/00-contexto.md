Você vai me ajudar no CREED.ai Educa, uma plataforma de Plasticidade Humana e
Inteligência Neuroinovadora (projeto acadêmico AGES/PUCRS, cliente professora).

ARQUITETURA
Front React/TS/Vite/Tailwind/Redux Toolkit → API FastAPI/SQLAlchemy/Alembic →
PostgreSQL (RDS). N8N como esteira de IA por webhook assíncrono. Tudo em EKS; banco
fora do cluster.

TRÊS REPOSITÓRIOS
- creed-backend (FastAPI, organizado POR DOMÍNIO em app/domains/<nome>/)
- creed-frontend (React, organizado POR FEATURE em src/features/<nome>/)
- creed-infrastructure (Job de migration, notas de EKS)

Domínio do backend e feature do front têm SEMPRE o mesmo nome.
Molde do backend: app/domains/respondentes/ — router.py (HTTP, sem regra),
service.py (regra, sem HTTP nem ORM), repository.py (query e agregação),
schemas.py (Pydantic separado por direção Create/Read), models.py (SQLAlchemy),
dependencies.py.
Molde do front: src/features/respondentes/ — <Feature>View.tsx, <feature>Slice.ts,
<feature>Api.ts, <feature>Slice.test.ts.

PRINCÍPIOS INEGOCIÁVEIS
1. Agregação no banco, cálculo no backend, renderização no front. Front somando array
   para montar indicador significa que a arquitetura vazou.
2. Migration nunca roda no startup do container — Job dedicado.
3. Autogenerate de migration é SEMPRE revisado linha a linha por um humano; rename
   vira drop+create e perde dados.
4. CI é obrigatório.
5. Estrutura por domínio (back) espelhada por feature (front).

NOMES
Domínio em português sem acento (prognosticos); técnico em inglês (service, repository).
Model no singular, tabela e pasta no plural.

QUALIDADE
backend: ruff check . && ruff format --check . && mypy app && pytest
frontend: npm run check

GIT (cobrado pelo GitHub)
Branch: <slug>/<id-clickup>-<contexto>, ex. feat/1-criar-usuarios — sem o ID o push é
recusado. Slugs: feat fix refactor perf test docs style chore ci build hotfix release.
Commit: Conventional Commits, imperativo, minúscula, sem ponto final, até 72
caracteres. PR aponta para dev.

COMO VOCÊ DEVE TRABALHAR
- Copie a forma do molde; não invente estrutura.
- Escopo fechado: só o que eu pedir entra na resposta. Problema que você notar ao lado,
  liste no fim — não conserte.
- Não sugira comandos de git de escrita a menos que eu peça explicitamente.
- Nunca inclua credencial, .env real ou dado pessoal de respondente.
- DÚVIDA DE PRODUTO: a cliente só é acessível em reunião marcada, então não me pergunte
  e espere — eu também não sei. Adote a interpretação mais barata de reverter, diga
  explicitamente "isto não está definido; adotei X porque Y", e siga. Eu registro como
  premissa.
- Dúvida TÉCNICA é diferente: se está nos padrões acima, siga-os; se não estiver,
  pergunte.

Confirme que entendeu em uma linha e espere meu próximo prompt.
