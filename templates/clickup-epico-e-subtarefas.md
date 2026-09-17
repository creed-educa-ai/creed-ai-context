# ClickUp — épico e subtarefas, formato

Formato **fixo** do que vai para o board, preenchido por
[`../workflows/tasks-to-clickup.md`](../workflows/tasks-to-clickup.md) e salvo em
`../tarefas/<ID>-<slug>/clickup.md` antes de qualquer chamada de escrita.

Regras de preenchimento:

- **Português corrente.** Quem lê pode não estar no tema — e pode não ser dev.
- **Seção sem conteúdo real é apagada**, não preenchida com "N/A".
- **Caminho, método, rota e comando são literais.** Só o *porquê* vira prosa.
- **Nenhum jargão do harness sem expansão**: "molde", "spec", "P-012", "T2", "prisma"
  ou viram frase explicada, ou viram material anexado.
- Tamanho alvo da subtarefa: cabe em uma tela e meia. Se passou muito disso, a
  decomposição é que estava grossa.

---

## Parte 1 — cabeçalho do `clickup.md`

<!-- Fica só no arquivo do repo; não vai para o ClickUp. -->

```
Épico: <ID> — <título>
Spec: spec.md · Tasks: tasks.md
Gerado em: <AAAA-MM-DD> · Publicado em: <AAAA-MM-DD, ou "ainda não">
```

### Mapa de publicação

| # | Título da subtarefa | Repo | Ação | ID no ClickUp |
|---|---|---|---|---|
| 1 | <título> | `creed-backend` | criar | — |
| 2 | <título> | `creed-frontend` | atualizar | `86xxxxxxx` |
| 3 | <título> | `creed-backend` | deixar como está | `86xxxxxxx` |

A coluna **ID** é preenchida no passo 6 e é o que torna a segunda rodada barata.

### Materiais — visão do épico

| Material | Onde está | Vai em | Situação |
|---|---|---|---|
| `contrato-api.md` | `tarefas/<ID>-<slug>/contrato-api.md` | subtarefas 1 e 4 | ⬜ falta anexar — AGES IV |
| Mock das telas (PDF) | `mock/` | subtarefa 5 | ✅ anexado |
| Premissa P-012 (texto) | `decisoes/premissas.md` | subtarefa 3 | ⬜ colar no corpo |

---

## Parte 2 — descrição do épico (nível de produto)

<!-- Vai em markdown_description do ClickUp, no ID do épico. -->

### O que é

<Duas a quatro linhas. O que passa a existir e por que isso importa. Linguagem de
produto: nada de nome de arquivo, nada de camada. Quem lê pode ser a cliente.>

### Para quem, e o que muda para essa pessoa

| Quem | Hoje | Depois desta entrega |
|---|---|---|
| <papel> | <o que essa pessoa não consegue fazer> | <o que passa a conseguir> |

### O que entra nesta rodada

- <item, em resultado observável>

### O que não entra — e por quê

- <item> — <motivo em uma linha>

<Esta lista vale tanto quanto a de cima: é ela que impede a entrega de crescer sozinha.>

### Como vai ser verificado

1. <passo concreto que qualquer pessoa do time executa e vê o resultado>

### Decisões que tomamos sem a cliente

| O que decidimos | Por quê | Custo de mudar depois |
|---|---|---|
| <a premissa, em texto corrido — não o ID> | <o motivo> | baixo / médio / alto |

<Sai do ledger de premissas. Vai o texto; o ID fica no rastreio.>

### As entregas

| # | Entrega | Onde | Depende de |
|---|---|---|---|
| 1 | <título da subtarefa> | back | — |
| 2 | <título da subtarefa> | front | 1 (só do contrato) |

### Materiais desta tarefa

- ✅ <material anexado>
- ⬜ <material que falta> — **anexar: <quem>**

### Rastreio

```
creed-ai-context/tarefas/<ID>-<slug>/spec.md
```

---

## Parte 3 — descrição de cada subtarefa

<!-- Vai em markdown_description, com parent = <ID> do épico. -->
<!-- Título da subtarefa: um resultado ("Relatório de adesão por organização"),
     nunca uma atividade ("Criar service e repository"). -->

### Em uma frase

<O que esta entrega faz, sem jargão. Se precisar de vírgula demais, a task é grande.>

### O que muda para quem usa

<Dois a quatro parágrafos curtos. Quem é afetado, o que essa pessoa vê de diferente e
por que decidimos assim. Esta seção é lida por quem não está imerso no tema — nenhum
caminho de arquivo aqui.>

### Como pretendemos fazer

<Prosa técnica, 3 a 8 linhas: o caminho escolhido e o motivo, ancorado em onde o
trabalho fica. Ex.: "A soma por organização fica na camada que fala com o banco, porque
agregação é trabalho do banco; a camada de regra só calcula o percentual e trata a
divisão por zero." Aqui entra também o que **não** fazer, quando já se sabe.>

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/<nome>/repository.py` | `contar_adesao_por_organizacao(...)` — a consulta agregada |
| `app/domains/<nome>/service.py` | `AdesaoService.listar(...)` — calcula o percentual |
| `tests/domains/<nome>/test_service.py` | caso feliz + organização sem respondente |

<Proposta, não contrato: se a implementação pedir outro arquivo **do mesmo repo**, tudo
bem. Se pedir outro repo, a decomposição estava errada — avise em vez de seguir.>

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| `PaginaDe[T]` | `app/shared/paginacao.py` | resposta paginada — não escreva outra |
| `NotFoundError` | `app/shared/exceptions.py` | 404 com corpo padronizado |
| Domínio de exemplo completo | `app/domains/respondentes/` | copie a **forma**: arquivos, camadas, injeção |

### Contrato

<Só quando a entrega cria ou muda endpoint. Em task de front, é o contrato que a tela
consome — a mesma tabela, vista do outro lado.>

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| GET | `/api/v1/<recurso>` | `?organizacao_id=<uuid>&pagina=1` | `200` · `PaginaDe[<Recurso>Read]` |

**Corpo da saída**

```json
{ "itens": [ { "id": "uuid", "nome": "string", "percentual_adesao": 0.0 } ],
  "total": 0, "pagina": 1 }
```

**Erros**

| Código | Quando | Corpo |
|---|---|---|
| 404 | organização não existe | `{"detail": "..."}` |
| 422 | parâmetro fora do formato | validação padrão do FastAPI |

### Pronto quando

- [ ] <critério verificável — dá para responder sim ou não olhando a tela ou o teste>

### Como verificar

```bash
docker compose up -d db
pytest tests/domains/<nome> -q
```

<Caso feliz + caso de borda, nomeados. Se corrige bug: o teste falha sem a correção.>

### Decisões já tomadas que valem aqui

- <a premissa em texto, e o que muda no código se ela cair>

### Materiais para consumir

| Material | Situação |
|---|---|
| Contrato da API (`contrato-api.md`) | ⬜ falta anexar — **AGES IV** |
| Mock da tela | ✅ anexado |
| Definição de "prisma" | ✅ colada acima |

<Regra: enquanto está ⬜, a tarefa não diz "veja o anexo" em lugar nenhum.>

### Rastreio

<!-- Última linha da descrição. É a chave que impede a subtarefa de ser duplicada. -->

```
Rastreio: <ID>/<N> — creed-ai-context/tarefas/<ID>-<slug>/<N>_task.md
```

<Para quem usa o repositório de contexto. Quem não usa não perde nada: tudo o que
importa já está acima.>
