# ADR-0009 — PR de tarefa sobe sem migration; o AGES III consolida

- **Status:** Aceito
- **Data:** 2026-10-06 (registro; decidido na retrospectiva da sprint 2)
- **Decidem:** time CREED
- **Relacionado:** [`conventions/migrations.md`](../../conventions/migrations.md) — cujas
  regras 3 e 7 esta decisão emenda

## Contexto

Na sprint 2, várias tarefas mexeram no banco ao mesmo tempo, e cada PR trouxe a própria
revisão do Alembic, gerada a partir da `dev` do dia em que a branch saiu. Duas revisões
com o mesmo `down_revision` são dois heads. O primeiro PR mergeava limpo, e todos os
outros caíam no check "heads únicas" do CI.

O conserto era sempre o mesmo, e sempre manual: `alembic merge`, commit novo, CI de novo.
Commit novo **descarta a aprovação** (CONTRIBUTING), então o PR voltava para a fila de
review por causa de um arquivo que ninguém precisava ler. A sprint fechou com 20
revisões em `alembic/versions/`, e **9 delas são só merge de heads**. É ruído na
história do banco, retrabalho para quem abre o PR e para quem revisa, e uma corrida
de quem mergeia primeiro.

O que torna a troca viável: **os testes do back não falam com o banco**. Não há sessão
real na suíte (os de router usam service fake), então um PR que muda `models.py` sem
migration passa no CI. A migration só é exigida de verdade quando alguém roda a
aplicação contra um banco.

## Decisão

1. **PR de tarefa não traz arquivo em `alembic/versions/`.** Ele muda `models.py` e o
   que depende dele, e mais nada no banco.
2. **Quem desenvolve gera a migration localmente para testar**, com o mesmo cuidado
   de sempre: autogenerate e leitura linha a linha. **Antes de abrir o PR**, desfaz a
   migration no banco local com `alembic downgrade` e só então apaga o arquivo. Essa
   ordem importa, porque com o arquivo apagado o Alembic não acha mais a revisão para
   descer.
3. **O PR que muda `models.py` preenche a seção "Banco" do template**: o que mudou no
   schema e **todo ajuste manual que a migration temporária precisou**, como rename
   (o autogenerate gera `drop` + `add` e perde o dado), backfill, `server_default` em
   tabela com linhas e passo de mudança destrutiva. É o único canal entre quem
   entendeu a mudança e quem vai escrevê-la.
4. **Em um ou mais momentos da sprint, um AGES III gera a migration consolidada**: uma
   branch `chore/<id-clickup>-consolidar-migrations` saída da `dev`, um autogenerate
   sobre o `models.py` acumulado, os ajustes manuais tirados das seções "Banco" dos
   PRs mergeados desde a consolidação anterior, e leitura linha a linha. Esse PR é
   sempre **Sensível**.
5. **O CI garante a regra.** Um PR que mexe em `alembic/versions/` falha, a menos que
   a branch seja de consolidação. Na de consolidação, o CI aplica as migrations num
   Postgres limpo e roda `alembic check`, que falha se ainda sobrou diferença entre
   `models.py` e o banco.
6. **Release `dev` → `main` só depois de consolidar.** A `dev` entre consolidações tem
   model sem tabela, e isso não pode chegar a um ambiente real.

## Alternativas descartadas

- **Continuar com migration no PR e resolver heads com `alembic merge`.** É o que
  gerou o problema. A regra 3 continua certa para quando acontece, mas fazer disso a
  rotina custa uma review a cada merge.
- **Rebasear e reescrever o `down_revision` antes do merge.** É mais limpo na
  história, mas é exatamente o "editar `down_revision` à revelia" que a regra 3
  proíbe, e quebra quem já aplicou a revisão antiga.
- **Fila de merge para PRs com migration.** Serializa sem eliminar o retrabalho: o
  segundo da fila ainda regenera.
- **Rename e mudança destrutiva como exceção, subindo com migration no PR.** Protege
  mais o dado, mas reabre o conflito de heads justamente nos PRs mais delicados. O
  canal escolhido é a seção "Banco" (item 3).
- **Reconhecer o PR de consolidação por label, não por nome de branch.** Label pode
  ser posta depois de aberto o PR e exige o CI ouvir o evento `labeled`. O nome da
  branch já é cobrado pelo check `nome-da-branch` e é determinístico.

## Consequências

- ✅ PR de tarefa não conflita mais por head, e a aprovação não cai por causa de um
  commit de merge de heads.
- ✅ A história de `alembic/versions/` fica com uma revisão por consolidação, e não uma
  por PR mais uma por colisão.
- ⚠️ **Entre o merge e a consolidação, a `dev` tem model sem tabela.** Quem roda a
  aplicação a partir da `dev` precisa gerar uma migration temporária local, inclusive
  para o `scripts/seed_local.py`, e desfazê-la antes do próprio PR.
- ⚠️ **Quem escreve a migration não é quem entendeu a mudança.** O conhecimento viaja
  como texto na seção "Banco". Se ela vier incompleta, o autogenerate da consolidação
  faz `drop` + `add` em silêncio. Por isso o AGES III lê também o diff de `models.py`
  de cada PR, e não só o texto.
- ⚠️ **A revisão consolidada é maior que a de um PR**, e é a mais arriscada do
  projeto. Consolidar mais de uma vez na sprint mantém o tamanho revisável.
- ⚠️ **A regra 6 (mudança destrutiva em passos) muda de unidade.** Adicionar, migrar
  dados e remover não podem cair na mesma consolidação. A seção "Banco" do PR diz em
  qual passo ele está, e cada passo espera a próxima consolidação.
- ⚠️ Revisor de PR de tarefa **não revisa migration**, revisa a seção "Banco". Quem
  revisa de fato o banco é o par do PR de consolidação.
