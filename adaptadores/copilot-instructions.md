<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->
<!-- Fonte: creed-ai-context/adaptadores/copilot-instructions.md -->

# CREED.ai Educa — instruções

Este arquivo **duplica** o essencial de propósito: o Copilot não lê arquivos fora do
repositório de forma confiável. A fonte é `creed-ai-context/` no workspace `ages/`;
quando ela estiver acessível, ela prevalece.

## Arquitetura em uma frase

Front (React/Vite) estático no **Amplify** → API (FastAPI) → PostgreSQL (RDS). Back,
N8N e Keycloak são três containers numa **EC2 única** — os mesmos do ambiente local,
num compose de produção próprio (`creed-infrastructure/ec2/`). Banco no RDS, fora da instância, um schema por componente. N8N como
esteira de IA por webhook assíncrono. (ADR-0007)

## Princípios inegociáveis

1. **Agregação no banco, cálculo no backend, renderização no front.** Front somando
   array para montar indicador = arquitetura vazou.
2. **Migrations nunca no startup do container** — passo dedicado do pipeline.
3. **Autogenerate de migration é sempre revisado linha a linha por um humano** —
   rename vira drop+create e perde dados.
4. **CI é obrigatório.**
5. **Estrutura por domínio (back) e por feature (front), com o mesmo nome.**
6. **O código precisa ser defensável por quem entrega.** Toda implementação encerra
   explicando abordagem e alternativas descartadas; bifurcação técnica real vira
   pergunta, não escolha silenciosa. Projeto acadêmico: quem entrega precisa entender.

## Backend — `app/domains/<nome>/`

Molde: `app/domains/users/`.

| Arquivo | Faz | Não faz |
|---|---|---|
| `router.py` | rota, validação, delega | regra, query |
| `service.py` | regra de negócio | HTTP, ORM |
| `repository.py` | query e agregação | decidir regra |
| `schemas.py` | Pydantic separado por direção (`Create`/`Read`) | lógica |
| `models.py` | tabela SQLAlchemy | validação |

Domínio não importa `models.py` de outro domínio.

## Frontend — `src/features/<nome>/`

Molde: `src/features/authentication/` — `<Feature>View.tsx`, `<feature>Slice.ts`,
`<feature>Api.ts`, `<feature>Slice.test.ts`.

Chamada HTTP **só** no `<feature>Api.ts`, caminho relativo `/api/...`.
Nada de agregação no front. Texto visível via i18n.

## Nomes

**Inglês em todo identificador** — pasta, classe, método, rota, schema, chave de i18n
(ADR-0005). Português só no termo que a cliente usa em reunião, e essa lista ainda está
aberta (`Prisma`). Vínculo e setor já são `Link` e `Department`; valores de enum seguem
em português. Model singular, tabela e pasta plural. Nome da feature = nome do domínio.

O molde já está no idioma decidido pelo ADR-0005 (inglês em todo identificador).
O que sobrou do idioma antigo é o `PaginaDe[T]` de `app/shared/paginacao.py`. E a tela continua em português — chave de i18n em inglês, valor em `pt-BR`.

## Testes

Backend: service com mock de repository · repository com banco real · router só
contrato. Frontend: slice direto, View por interação.

```
backend:  ruff check . && ruff format --check . && mypy app && pytest
frontend: npm run check
```

## Nível do código

Nível de líder técnico é **código que o time mantém**, não código esperto. Um colega
entende o arquivo em uma passada. Não entram sem justificativa escrita: abstração para
um caso de uso só, factory/strategy com uma opção, metaprogramação, genérico TS com 3+
parâmetros, herança onde composição resolve, `any`/`# type: ignore`/`except: pass`,
padrão que nenhum arquivo do repo usa ainda, dependência nova.
Tipagem completa, função pequena com nome do domínio e early return **não** contam
como complexidade — são o esperado.

## Ao terminar uma implementação

Explique, nesta ordem: o que a task pedia · abordagem e por que esta · **o que você
descartou e por quê** · mapa do diff (arquivo → papel) · o que os testes provam e o que
**não** provam · onde pode quebrar depois · 3 perguntas que eu deveria saber responder
sobre este diff, com `arquivo:linha` — sem respondê-las por mim.

Antes de escrever, se houver bifurcação técnica real (efeito visível no código, sem
resposta no molde ou nas convenções): **pare, dê 2 opções com trade-off e a sua
recomendação**. Dúvida de produto não para — vira premissa.

## Git 🔒

Branch `<slug>/<id-clickup>-<contexto>` (ex. `feat/1-criar-usuarios`) — sem o ID do
ClickUp o push é recusado. Commit em Conventional Commits, imperativo, até 72
caracteres. PR aponta para `dev`.

## Dúvida de produto

A cliente só é acessível em reunião marcada. Lacuna de produto **não bloqueia**:
adote a interpretação mais barata de reverter, diga explicitamente que adotou, e
registre em `creed-ai-context/decisoes/premissas.md`.

## Nunca

- Versionar por conta própria (`git add`/`commit`/`push`/PR) sem pedido explícito.
- Rodar `alembic upgrade` fora do banco local, ou `kubectl`/`helm`/`aws` em ambiente
  real.
- Colocar credencial, `.env` real ou dado pessoal de respondente em código ou teste.
- Refatorar de passagem: só o que a tarefa pede entra no diff.
