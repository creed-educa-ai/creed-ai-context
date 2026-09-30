Você vai me ajudar no CREED.ai Educa, uma plataforma de Plasticidade Humana e
Inteligência Neuroinovadora (projeto acadêmico AGES/PUCRS, cliente professora).

ARQUITETURA
Front React/TS/Vite/Tailwind/Redux Toolkit publicado como estático no AWS Amplify →
API FastAPI/SQLAlchemy/Alembic → PostgreSQL (RDS). Back, N8N e Keycloak rodam como três
containers numa EC2 única, pelo mesmo docker-compose do ambiente local; o banco fica no
RDS, fora da instância, com um schema por componente. N8N como esteira de IA por webhook
assíncrono. (ADR-0007)

TRÊS REPOSITÓRIOS
- creed-backend (FastAPI, organizado POR DOMÍNIO em app/domains/<nome>/)
- creed-frontend (React, organizado POR FEATURE em src/features/<nome>/)
- creed-infrastructure (notas de deploy; o Job de migration está aposentado)

Domínio do backend e feature do front têm SEMPRE o mesmo nome.
Molde do backend: app/domains/users/ — router.py (HTTP, sem regra),
service.py (regra, sem HTTP nem ORM), repository.py (query e agregação),
schemas.py (Pydantic separado por direção Create/Read), models.py (SQLAlchemy),
dependencies.py.
Molde do front: src/features/authentication/ — <Feature>View.tsx, <feature>Slice.ts,
<feature>Api.ts, <feature>Slice.test.ts.

PRINCÍPIOS INEGOCIÁVEIS
1. Agregação no banco, cálculo no backend, renderização no front. Front somando array
   para montar indicador significa que a arquitetura vazou.
2. Migration nunca roda no startup do container — passo dedicado do pipeline.
3. Autogenerate de migration é SEMPRE revisado linha a linha por um humano; rename
   vira drop+create e perde dados.
4. CI é obrigatório.
5. Estrutura por domínio (back) espelhada por feature (front).

NOMES
Inglês em todo identificador: pasta, classe, método, rota, schema, chave de i18n
(ADR-0005). Português só no termo que a cliente usa em reunião — lista ainda aberta
(Prisma). Vínculo e setor já são Link e Department; valores de enum seguem em
português. Model no singular, tabela e pasta no plural.
O molde já está em inglês (ADR-0005). Resíduo do idioma antigo: PaginaDe[T].
A TELA continua em português: chave de i18n em inglês, valor em pt-BR.

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
