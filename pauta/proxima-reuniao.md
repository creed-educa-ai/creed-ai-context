# Pauta — próxima reunião com a cliente

> Gerada por [`../workflows/duvidas-to-pauta.md`](../workflows/duvidas-to-pauta.md).
> Máximo 5–7 itens, ordenados por custo de reverter.
> Depois da reunião: atualizar o ledger e arquivar como `YYYY-MM-DD.md` (nesta pasta).

## Contexto rápido (30 segundos)

<O que o time entregou desde a última reunião.>

---

## 1. Vocabulário do produto

**Hoje está assim:** o sistema usa os termos *respondente*, *organização*, *prisma*,
*prognóstico*, *relatório* e *dashboard* com o sentido que o time inferiu — eles já são
os nomes das tabelas e das telas.

**Pergunta:** algum desses termos significa, para a senhora, algo diferente do que o
time entendeu?

**Custo de mudar:** agora, baixo (renomear antes de haver dado). Depois que houver dado
de respondentes reais, alto — vira migration com risco de perda.

*(P-001)*

---

## 2. Níveis de acesso — quem pode o quê

**Hoje está assim:** o time vai construir a autenticação com **três níveis**:
*administrador* (cadastra pessoas e define o nível de cada uma), *gestor* (enxerga a
organização dele inteira: formulários, respostas e painéis) e *respondente* (só os
próprios formulários). É a lista que está no diagrama de dados que o time desenhou.

**Pergunta:** três níveis chegam, ou a senhora precisa de algum outro — alguém que veja
mais de uma organização, por exemplo, ou alguém que veja os painéis mas não possa
cadastrar ninguém?

**Custo de mudar:** **agora, zero** — nada foi construído ainda. Depois que a
autenticação existir, alto: muda o banco, muda a regra de todas as telas e muda o
servidor de senhas.

*(P-006, e fecha também a P-003)*

---

## 3. Convite por e-mail e senha esquecida

**Hoje está assim:** ninguém recebe senha de outra pessoa. Para dar acesso a alguém, o
administrador (ou o gestor da empresa, só na empresa dele) informa **nome, e-mail e
nível de acesso**, e a pessoa recebe um **e-mail de convite**. Ela clica no link, cria a
própria senha numa página segura e volta para a tela de login da plataforma. Quem
esquece a senha pede um link novo pelo "Esqueci minha senha". Alguns detalhes o time
decidiu sem a senhora:

- o link do convite vale **3 dias**; vencido, quem convidou reenvia;
- o e-mail usa o **texto padrão** do sistema de senhas, em português, que pede para a
  pessoa "atualizar a conta" — não é um texto de boas-vindas da CREED;
- o e-mail sai de um **endereço `@gmail.com`** do projeto, porque a plataforma ainda não
  tem domínio próprio, e o link aponta para o endereço numérico do servidor;
- o **mentorando** da senhora entra ligado à própria CREED, como "mentoria", e não a uma
  empresa;
- quando a senhora **aprova uma empresa**, o convite vai para o e-mail informado no
  cadastro, para a pessoa que cadastrou, como gestora da empresa;
- o gestor convida só funcionários e outros gestores, nunca administradores da
  plataforma.

**Pergunta:** algum desses pontos não serve para a senhora? Em especial: 3 dias é prazo
bom? O texto padrão do e-mail serve por enquanto? Um remetente `@gmail.com` é aceitável
até existir um domínio da CREED? E quem cadastra a empresa é mesmo quem vai administrá-la
na plataforma?

**Custo de mudar:** baixo na maioria — prazo, texto do e-mail e remetente são
configuração, sem mudar o sistema. Médio em dois: tirar o mentorando da organização da
CREED muda a estrutura dos dados, e o convite da empresa aprovada vai para quem estiver
lendo aquele e-mail (se for um "contato@", o acesso de gestor fica com quem lê essa caixa).

*(P-045, P-046, P-047, P-048, P-049, P-050, P-051, P-052, P-053)*

---

## 4. As seções do questionário

**Hoje está assim:** o time montou o questionário em **seções**, com abas no topo, e a
revisão das respostas separada por seção. Pelo material que a senhora enviou, são **8
seções**. Dentro de uma seção a pessoa pode pular perguntas e voltar a elas; para passar
à seção seguinte, precisa ter respondido todas as da seção atual.

**Pergunta:** são mesmo 8 seções, e quais os nomes de cada uma? E a regra de "responder
a seção inteira antes de seguir" faz sentido para quem vai responder?

**Custo de mudar:** o número e os nomes, **agora baixo** — nenhuma pergunta foi gravada
no banco ainda. Depois que houver perguntas gravadas, médio. A regra de navegação é
baixa em qualquer momento: não mexe em dado nenhum.

*(P-023, P-024)*

---

## Ficou para a próxima

- **P-008** — nenhuma pessoa cria a própria conta sozinha: todo acesso nasce de um
  convite feito por um administrador ou pelo gestor da empresa (P-045). A empresa pode
  pedir cadastro pela plataforma, e o pedido só vira acesso depois da aprovação da equipe
  CREED.
- **P-057 a P-060** — detalhes do convite, de custo baixo: empresa inativa ainda recebe
  convite; reenviar o convite não muda o nível de acesso de ninguém; a organização da
  CREED nasce com nome "CREED.ai Educa" e endereço a informar; convidar como
  administrador quem já tem acesso só reenvia o e-mail, sem mudar o nível da pessoa.
- **P-010** — quanto tempo a pessoa fica logada antes de precisar entrar de novo
  (proposto: 8 horas).

---

## Anotações da reunião

| Premissa | Desfecho | Ação |
|---|---|---|
| P-001 | | |
| P-006 (+ P-003) | | |
| P-045 a P-053 | | |
