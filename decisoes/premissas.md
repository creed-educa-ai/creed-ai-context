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
| P-006 | 2026-09-05 | autenticação | Os papéis da plataforma são `admin`, `gestor` e `respondente` — a lista do diagrama de dados, não a de P-003. | O diagrama foi feito em time e é artefato coletivo; P-003 nasceu de um ensaio da esteira (`EXEMPLO`) que nunca virou código. Hoje **nenhum dos dois lados tem uma linha atrás**, então decidir custa zero. Depois da auth, mudar a lista é migration de enum + refactor de toda guarda de rota + realm do Keycloak. | baixo hoje, **alto depois** | 86e348g6u | 🟡 aberta |
| P-008 | 2026-09-05 | autenticação | Não existe autocadastro. Todo login nasce da cadeia Organização → Participante → Vínculo → Usuário, criada por alguém com papel `admin`. | É consequência direta de [C2] no modelo (usuário não nasce antes do vínculo). Tela pública de "criar conta" abriria a plataforma para quem não tem vínculo com organização nenhuma. | baixo | 86e348g6u | 🟡 aberta |
| P-009 | 2026-09-05 | autenticação | "Esqueci minha senha" não existe nesta entrega. Quem perde a senha pede a um `admin`, que emite outra temporária. | Sem serviço de e-mail, o fluxo de reset não tem por onde sair. Acrescentar depois é configurar SMTP no realm, não escrever código. | médio | 86e348g6u | 🟡 aberta |
| P-010 | 2026-09-05 | autenticação | Sessão: `access_token` de 15 minutos e `refresh_token` de 8 horas (um turno), sem renovação deslizante além disso. | Prazo curto limita a janela de um token vazado, e 8h cobre um dia de trabalho sem relogar. É configuração de realm — trocar não é migration nem deploy de código. | baixo | 86e348g6u | 🟡 aberta |
| P-012 | 2026-09-08 | autenticação | O primeiro acesso é por **e-mail com link para o realm do Keycloak**, onde a pessoa define a própria senha. Enquanto o envio de e-mail não existir, o acesso nasce com **senha definitiva** definida pelo admin e passada fora da plataforma — sem ação obrigatória no Keycloak, portanto sem troca forçada no primeiro login. | Decisão de time, com precedente de uso corporativo. O Keycloak já resolve o fluxo inteiro (`execute-actions-email` + página do realm), então a plataforma nunca precisa de tela de troca de senha — nem hoje nem depois. No interim, `temporary: false` no provisionamento evita a ação obrigatória que faria o Direct Access Grant (D1) recusar o login. Substitui P-007 e P-011. | baixo — o front não muda em nenhum dos dois momentos; muda o provisionamento no backend | 86e348g6u | 🟡 aberta |
| P-003 | 2026-09-07 | autenticação | A tela de troca de senha (CREED-18.8) não integra com nenhuma API: "Avançar" só valida os dados no front. | Não existe domínio de autenticação no creed-backend, nenhum contrato definido; integrar contra um contrato inexistente arriscaria codificar campo que nunca vai existir. | médio | — | 🟡 aberta |
| P-004 | 2026-09-07 | autenticação | A senha precisa ter no mínimo 8 caracteres, sem regra adicional de complexidade. | Não existe política de senha definida em documento do produto; 8 é o mínimo comum de mercado, barato de apertar depois. | baixo | — | 🟡 aberta |

> ⚠️ **IDs duplicados: P-003 e P-004 aparecem duas vezes nesta tabela.** As de
> 2026-09-01 são de navegação (tarefa `EXEMPLO`); as de 2026-09-07 são da tela de troca
> de senha e nasceram com ID já em uso. Não foi descuido de uma pessoa: na `main` o
> último ID era P-005, e as **P-006 a P-010 passaram dias sem commit** — quem olhasse o
> repositório não as via. Premissa que não está commitada não existe para o time.
>
> **Preservadas como estão, de propósito.** Renumerar significa editar código de uma PR
> aberta de outra pessoa (`AlterarSenhaView.tsx:22`, `validadores.ts:3`), e essa PR pode
> nem sobreviver à P-012. Tarefa própria:
> [renumerar as premissas duplicadas](https://app.clickup.com/t/86e35wea4).

> **P-003 (a de navegação) × P-006 vão juntas para a pauta.** P-003 (`admin`/`funcionario`) continua aberta
> e em conflito com P-006 (`admin`/`gestor`/`respondente`). Não são duas perguntas: são a
> mesma, e a resposta da cliente fecha as duas de uma vez.

## Fechadas

| ID | Data | Assunto | Premissa adotada | Desfecho | Tarefa | Status |
|---|---|---|---|---|---|---|
| P-007 | 2026-09-05 | autenticação | O acesso nasce com senha temporária definida por quem cadastra, e o Keycloak exige a troca no primeiro login (`UPDATE_PASSWORD`). Não há convite por e-mail. | **Refutada em 2026-09-08 por decisão de time** (não da cliente): o time já tinha estratégia definida, com precedente de uso corporativo — convite por e-mail com link para o realm do Keycloak. A troca obrigatória deixa de existir; quem define a senha é a página do Keycloak. Substituída por P-012. | 86e348g6u | ❌ refutada |
| P-011 | 2026-09-08 | autenticação | A troca de senha do primeiro acesso acontece em tela da plataforma: o login responde 409 `password_change_required` e a aplicação pede a senha nova em `POST /authentication/password`. | **Refutada em 2026-09-08, no mesmo dia em que foi registrada**, por decisão de time anterior que eu desconhecia ao registrá-la. A tela não existe no desenho de destino: quem define a senha é a página do Keycloak, alcançada por link no e-mail. Consequência: o 409 e o `POST /authentication/password` saem do contrato, e a tela da PR #11 do `creed-frontend` perde a função. Substituída por P-012. | 86e348g6u | ❌ refutada |

> Premissa refutada **não é erro do time** — é o mecanismo funcionando
> (`../conventions/premissas-e-duvidas.md` → "Ciclo de vida"). P-007 e P-011 caíram por
> falta de registro de uma decisão já tomada, não por interpretação errada do produto.
