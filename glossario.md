# Glossário

Termos do domínio da CREED.ai Educa. **O nome no código é o nome aqui** — domínio em
português, código técnico em inglês.

> ⚠️ Este glossário é um **esqueleto**. Cada entrada marcada com 🟡 está preenchida por
> premissa da equipe, não por definição da cliente. Confirmar na próxima reunião
> (ver `pauta/proxima-reuniao.md`) e trocar 🟡 por ✅ quando confirmado.

| Termo | Definição | Onde aparece | Status |
|---|---|---|---|
| **Respondente** | Pessoa que responde aos instrumentos da plataforma | `domains/respondentes`, `features/respondentes` | 🟡 |
| **Organização** | Instituição à qual respondentes pertencem | `domains/organizacoes` | 🟡 |
| **Prisma** | Recorte/dimensão de análise aplicada às respostas | `domains/prismas` | 🟡 |
| **Prognóstico** | Projeção gerada a partir dos prismas | `domains/prognosticos` | 🟡 |
| **Relatório** | Saída consolidada e exportável para a organização | `domains/relatorios` | 🟡 |
| **Dashboard** | Visão agregada e interativa dos indicadores | `domains/dashboards` | 🟡 |
| **Plasticidade humana** | Conceito-base do produto (cliente é a autoridade) | produto | 🟡 |
| **Esteira de IA** | Fluxo N8N acionado por webhook assíncrono | infraestrutura | ✅ |

## Como usar

- Termo que **não está aqui** e vai virar nome de tabela, endpoint ou componente:
  registre premissa antes de codar (`conventions/premissas-e-duvidas.md`).
- Termo que muda de significado: **atualiza aqui primeiro**, depois renomeia no código
  — renomear coluna vira drop+create e perde dados (`conventions/migrations.md`).
