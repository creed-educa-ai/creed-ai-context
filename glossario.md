# Glossário

Termos do domínio da CREED.ai Educa. Desde o
[ADR-0005](decisoes/adrs/0005-idioma-do-codigo.md), **o nome no código é o nome aqui só
para os termos que a cliente de fato usa em reunião** — todo o resto do código é inglês.
Quais desses termos são esses ainda é decisão aberta do time (pendência do ADR-0005), e
é este arquivo que a decisão vai marcar.

> ⚠️ Este glossário é um **esqueleto**. Cada entrada marcada com 🟡 está preenchida por
> premissa da equipe, não por definição da cliente. Confirmar na próxima reunião
> (ver `pauta/proxima-reuniao.md`) e trocar 🟡 por ✅ quando confirmado.

| Termo | Definição | Onde aparece | Status |
|---|---|---|---|
| **Respondente** | Pessoa que responde aos instrumentos da plataforma | `UserRole.RESPONDENTE` no back, `features/respondentes` no front | 🟡 |
| **Organização** | Instituição à qual respondentes pertencem | `domains/organizacoes` | 🟡 |
| **Prisma** | Recorte/dimensão de análise aplicada às respostas | `domains/prismas` | 🟡 |
| **Prognóstico** | Projeção gerada a partir dos prismas | `domains/prognosticos` | 🟡 |
| **Relatório** | Saída consolidada e exportável para a organização | `domains/relatorios` | 🟡 |
| **Dashboard** | Visão agregada e interativa dos indicadores | `domains/dashboards` | 🟡 |
| **Papel (role)** | Nível de acesso dentro da organização. **Em conflito:** o modelo de dados diz `Admin`/`Gestor`/`Respondente`, a P-003 (de ensaio) diz `admin`/`funcionario`. Resolver antes da autenticação — ver [`context/modelo-de-dados.md`](context/modelo-de-dados.md) #12 | `Vinculo.role`, navegação do front | 🟡 |
| **Plasticidade humana** | Conceito-base do produto (cliente é a autoridade) | produto | 🟡 |
| **Esteira de IA** | Fluxo N8N acionado por webhook assíncrono | infraestrutura | ✅ |

## Como usar

- Termo que **não está aqui** e vai virar nome de tabela, endpoint ou componente:
  registre premissa antes de codar (`conventions/premissas-e-duvidas.md`).
- Termo que muda de significado: **atualiza aqui primeiro**, depois renomeia no código
  — renomear coluna vira drop+create e perde dados (`conventions/migrations.md`).
