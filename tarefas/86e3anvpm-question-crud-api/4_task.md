# Task 4 — Modelo de dados descrevendo a seção da pergunta

**Repo:** `creed-ai-context`
**Depende de:** task 1, porque só dá para descrever a coluna depois que a migration existe

## Objetivo

O modelo de dados do time passa a descrever a coluna `section` e o enum
`QuestionSection`, que a tabela `questions` tem e o `.dbml` não tem, e passa a dizer que
os valores são provisórios e por quê.

## Por que isto é tarefa própria, e não um item da task 1

1. **É outro repositório.** A task 1 entrega migration no `creed-backend`, e o modelo de
   dados mora no `creed-ai-context`. Uma task não cruza repos
   ([`workflows/spec-to-tasks.md`](../../workflows/spec-to-tasks.md)).
2. **Não se verifica no mesmo PR.** O "pronto quando" da task 1 é `alembic upgrade` e
   `pytest`. O desta é um diff de documentação.
3. **Sem ela, alguém "corrige" o código.** Quem abrir o modelo, procurar `section` em
   `Question` e não achar tende a concluir que a coluna está sobrando. É o mesmo risco
   que fez a CREED-33 criar a entrega 4 dela.

## Contexto que você não tem como adivinhar

O modelo de dados tem três camadas, e esta tarefa mexe só na do meio:

| Onde | O que é |
|---|---|
| dbdiagram.io | o desenho que o time fez em conjunto |
| `context/modelo-de-dados.dbml` | cópia literal do export do dbdiagram. **Não mexa** |
| `context/modelo-de-dados.proposta.dbml` | a correção fechada em 2026-09-04, que as tarefas de tabela estão lendo. **É aqui** |

**A seção não é o prisma.** A pergunta já tem `prisma` (a dimensão de análise, `[C9]`
no modelo). A seção é a parte do formulário em que a pergunta aparece na tela. Uma
pergunta tem as duas coisas, e elas mudam por motivos diferentes. O comentário no
`.dbml` precisa dizer isso, senão a primeira leitura vai achar que é duplicação.

**Os valores são provisórios** (P-020). O time decidiu que a seção existe, mas não
quais são as seções. O `.dbml` tem de registrar a lista **e** o fato de ela ser
provisória. Registrar só a lista faria o modelo transformar uma premissa em decisão.

## Arquivos que provavelmente mudam

- `context/modelo-de-dados.proposta.dbml`: o enum novo, a coluna na tabela `Question` e
  a contagem de enums no cabeçalho
- `context/modelo-de-dados.md`: uma linha em "Decisões já tomadas" e a linha de
  `Question` no "Mapa tabela → domínio do backend"

## O que fazer, concretamente

**1. Na `proposta.dbml`, o enum novo**, junto dos outros enums no topo do arquivo:

```
// [C31] Seção do formulário: onde a pergunta é desenhada na tela (CREED-35).
//       NÃO é o prisma: o prisma é a dimensão de análise ([C9]); a seção é o
//       agrupamento visual. Uma pergunta tem os dois.
//       Valores PROVISÓRIOS (P-020): o time decidiu que a seção existe, não quais são.
Enum QuestionSection {
  profile
  assessment
  closing
}
```

**2. Na tabela `Question`**, a coluna, logo depois de `type`:

```
  section QuestionSection [not null]  // [C31] obrigatória, sem default (P-028)
```

Nenhum índice novo. O filtro por seção sempre vem junto de `form_id`, que já tem índice.

**3. Acerte o cabeçalho.** Ele diz "14 tabelas · 9 enums · 21 FKs", e passa a ter **10
enums**. As FKs não mudam: `section` não aponta para tabela nenhuma.

**4. No `modelo-de-dados.md` → "Decisões já tomadas"**, uma linha nova, no formato das
outras:

| Data | Decisão | Consequência |
|---|---|---|
| 2026-09-22 | **`Question` ganha `section`** (`QuestionSection`, `not null`, sem default) **[C31]** | o front sabe em que parte do formulário desenhar cada pergunta, e a listagem de perguntas de um formulário filtra por ela. Independente do prisma. **Valores provisórios** (P-020): trocar depois de haver pergunta gravada é `ALTER TYPE` + atualização das linhas. Decisão de time, não da cliente |

**5. No mesmo arquivo → "Mapa tabela → domínio do backend"**, a linha
`| formularios | novo | Form, Question, QuestionOption |` deixou de ser verdade:
`Question` nasceu no domínio `questions`, separado de `forms` (a CREED-33 e a CREED-35
correm em paralelo). Troque a linha por duas:

| Domínio | Situação | Tabelas |
|---|---|---|
| `forms` | novo (CREED-33) | `Form` |
| `questions` | novo (CREED-35) | `Question`. `QuestionOption` fica para a CREED-37 decidir, junto com a amarração, se entra aqui ou em `forms` |

Mexa só nessa linha. Os outros nomes do mapa estão em português e são anteriores ao
ADR-0005; renomeá-los é outra conversa.

**6. Confira e reporte, sem corrigir:** o `.dbml` descreve os valores dos enums em
minúsculas (`objective`, `plasticidade_humana`), mas o banco guarda o **nome** do membro
em maiúsculas (`OBJECTIVE`, `PLASTICIDADE_HUMANA`). É o comportamento padrão do
SQLAlchemy, e as migrations da `user` e da `form_responses` já estão assim. A API
devolve minúsculas. Não é defeito desta tarefa nem se resolve aqui. Mas quem ler o
modelo e depois consultar o banco pelo `psql` vai estranhar, e isso merece uma linha no
PR.

## Cuidado com a CREED-33

A task 4 da CREED-33 mexe nos **mesmos dois arquivos**: ela reescreve `Table Form` com
`[C29]` e `[C30]`, e acerta a contagem de FKs do cabeçalho. As duas podem estar abertas
ao mesmo tempo.

- **Os números de correção:** `[C29]` e `[C30]` são dela, e `[C31]` é desta. Antes de
  usar, confira com `grep -o '\[C[0-9]*\]'` que ninguém gastou o 31.
- **O cabeçalho:** as duas mudam a mesma linha, uma nas FKs e a outra nos enums. Quem
  mesclar por último junta as duas mudanças e reconta, em vez de aceitar uma das
  versões.
- **O mapa tabela → domínio:** o item 5 desta task troca a linha `formularios`. Se a
  CREED-33 também a tiver tocado, junte as duas.

## O que não entra

- **Colar no dbdiagram e reexportar `modelo-de-dados.dbml`.** Depende de o time aceitar
  a proposta inteira. É o passo 1 de "Quando o modelo for aceito".
- **Decidir a lista de seções.** Esta tarefa descreve a premissa, e não a resolve.
- **Corrigir a diferença entre nome e valor dos enums** (item 6). Só se reporta.

## Critérios de aceite

- [ ] `proposta.dbml` tem `Enum QuestionSection` com os três valores e o comentário
      `[C31]`, que diz que não é o prisma e que os valores são provisórios (P-020).
- [ ] `Table Question` tem `section QuestionSection [not null]`, sem default e sem índice
      novo.
- [ ] O cabeçalho conta 10 enums, e a contagem bate com o número de blocos `Enum` do
      arquivo.
- [ ] `modelo-de-dados.md` → "Decisões já tomadas" tem a linha de 2026-09-22 com
      `[C31]`, P-020 e "decisão de time, não da cliente".
- [ ] O mapa tabela → domínio mostra `Form` em `forms` e `Question` em `questions`.
- [ ] A diferença entre nome e valor dos enums está **reportada por escrito** (no PR ou
      na tarefa).
- [ ] `modelo-de-dados.dbml` (o export literal) **não** foi tocado.

## Como testar

Não há teste automático: a saída é documentação. A conferência é por leitura.

```bash
cd creed-ai-context
grep -n -B 5 -A 5 '^Enum QuestionSection' context/modelo-de-dados.proposta.dbml
grep -n -A 12 '^Table Question ' context/modelo-de-dados.proposta.dbml
grep -c '^Enum ' context/modelo-de-dados.proposta.dbml   # tem que bater com o cabeçalho
grep -n 'QuestionSection' context/modelo-de-dados.dbml   # não pode devolver nada
```

**Caso de borda:** o `grep` de `Table Question ` tem um espaço no fim de propósito. Sem
ele, o comando também pega `Table QuestionOption`.

## Premissas aplicáveis

- **P-020**: os valores `profile`, `assessment` e `closing` são provisórios. É o que o
  comentário `[C31]` registra. Se a lista mudar, esta linha do `.dbml` muda junto.
- **P-028**: a seção é obrigatória. É o `[not null]` sem default.

As duas estão 🟡 **abertas**. Diferente da task 4 da CREED-33, aqui o modelo descreve
premissa aberta, e não fechada. O comentário não pode soar como decisão final.
