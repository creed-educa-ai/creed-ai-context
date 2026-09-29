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

## 3. Primeiro acesso e senha esquecida

**Hoje está assim:** a plataforma **não envia e-mail** — isso não existe na
infraestrutura. Então o time planeja: o administrador cadastra a pessoa com uma senha
provisória, e a plataforma obriga a trocar no primeiro acesso. Quem esquecer a senha
pede uma nova ao administrador.

**Pergunta:** isso funciona na prática de vocês, ou a senhora espera que a pessoa
receba um convite por e-mail e crie a própria senha?

**Custo de mudar:** médio — passa a exigir um serviço de envio de e-mail configurado,
que hoje não existe em lugar nenhum do projeto.

*(P-007, P-009)*

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
  cadastro feito por um administrador. A empresa pode pedir cadastro pela plataforma,
  e o pedido só vira acesso depois da aprovação da equipe CREED.
- **P-010** — quanto tempo a pessoa fica logada antes de precisar entrar de novo
  (proposto: 8 horas).

---

## Anotações da reunião

| Premissa | Desfecho | Ação |
|---|---|---|
| P-001 | | |
| P-006 (+ P-003) | | |
| P-007 | | |
| P-009 | | |
