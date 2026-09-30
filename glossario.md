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
| **Formulário** | O instrumento que a plataforma aplica: um conjunto de perguntas que uma pessoa responde. Dono é a organização, não uma pessoa. | `domains/forms` | 🟡 |
| **Pergunta (Question)** | Um item de um formulário: enunciado, ordem, se é obrigatória, e o tipo (objetiva/múltipla escolha ou descritiva). | `domains/questions` | 🟡 |
| **Seção (do formulário)** | A parte do formulário em que uma pergunta é desenhada na tela. É um valor fixo de uma lista (`QuestionSection`), não algo que o gestor cria. É independente do prisma: a seção organiza a tela, e o prisma organiza a análise. Os valores atuais são provisórios (P-020). | `questions.section`, telas do formulário | 🟡 |
| **Resposta de formulário (FormResponse)** | A participação de um vínculo em um formulário. Abre em andamento, recebe as respostas pergunta a pergunta e é enviada uma vez; depois do envio, não muda mais. Cada vínculo tem no máximo uma por formulário. | `domains/responses`, tabela `form_responses` | 🟡 |
| **Resposta (Answer)** | O que foi respondido em **uma** pergunta, dentro de uma resposta de formulário: o texto escrito, se a pergunta é descritiva, ou a alternativa marcada, se é objetiva (as alternativas chegam com a CREED-37). | `domains/responses`, tabela `answer` | 🟡 |
| **Organização** | Instituição à qual respondentes pertencem | `domains/organizacoes` | 🟡 |
| **Participante** | A pessoa, independente do vínculo — é onde as respostas de uma mesma pessoa em duas organizações se encontram | `domains/participants`, tabela `participants` | 🟡 |
| **Vínculo** | O elo entre uma pessoa (Participante) e uma Organização: guarda o papel (`role`), o tipo (`type`) e o período (`start_at`/`end_at`) daquele vínculo. No código é **`Link`** (ADR-0005; a P-029, que o mantinha em português, foi refutada em 2026-09-29). No `.dbml` segue `Vinculo` | `domains/links`, `user.link_id` | 🟡 |
| **Setor** | Subdivisão de uma organização à qual um vínculo pode pertencer; dado da organização, não enum fixo. No código é **`Department`** | `Link.department_id` | 🟡 |
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
