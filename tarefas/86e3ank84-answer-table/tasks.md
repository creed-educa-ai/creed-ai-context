# Tasks — CREED-31 Answer table context

Spec: [`spec.md`](spec.md)

## Progresso

- [ ] 1 — [Tabela `answer` no banco, com o domínio `responses`](1_task.md) · `creed-backend`
- [ ] 2 — [Registrar uma resposta: repository, service e schemas](2_task.md) · `creed-backend`

Marque aqui ao concluir cada task ([`workflows/tasks-to-code.md`](../../workflows/tasks-to-code.md)).

## Ordem e corte

```
1 (tabela) ──► 2 (registrar resposta)
```

**Sequencial, sem paralelismo.** A task 2 importa o model que a 1 cria — não há contrato
intermediário contra o qual programar, porque as duas vivem no mesmo repo e na mesma
pasta. Somadas cabem numa sprint: a 1 é meia jornada, a 2 é uma.

O recorte publicado no board divide em três (model+migration · repository+service ·
schemas). **Aqui são duas de propósito:** "criar schemas" sem router não tem resultado
verificável — dá para conferir que a classe existe, não que ela faz algo —, e a regra que
daria substância a ela (P-014) é regra de produto, então mora no service. Os schemas vão
junto da task 2.

## Fora do escopo desta rodada

- **Router, e registro em `app/main.py`.** Não há endpoint nesta rodada
  ([`spec.md`](spec.md) → Escopo). `main.py` **não é tocado** — ninguém precisa procurar
  onde registrar.
- **As chaves estrangeiras e a coluna `form_response_id`.** Vão na tarefa de
  **amarração**, que ainda não existe no board e precisa de dono e data. Enquanto ela não
  acontecer, a tabela `answer` **precisa continuar vazia** — é o que mantém a amarração
  barata (uma migration em vez de três passos).
- **Validação cruzada** do tipo "a alternativa pertence mesmo a esta pergunta". Depende de
  `question_option` existir.
- **Front.** Nada muda no `creed-frontend`.

## Divergências com o que está publicado no board

Quem for implementar vai encontrar, nas subtarefas do ClickUp, instruções que estas tasks
**não** seguem. Não é descuido — está justificado em [`spec.md`](spec.md) → "Abordagem
técnica":

| A subtarefa diz | Aqui é | Por quê |
|---|---|---|
| CREED-31 (épico): entregar `POST /api/v1/answers` | nenhum endpoint | receberia `form_response_id` sem a tabela existir, e gravaria lixo não rastreável |
| 311: *"pode colocar de forma mockada esses id no models"* | `form_response_id` não entra nem como coluna | coluna `UUID` sem FK e sem destino não valida nada; na amarração vira `ALTER` em vez de `ADD` |
| 312: *"texto vazio deve ser recusado"* | uma das duas formas preenchida (P-014) | a regra do board recusaria **toda** resposta objetiva, que tem `value` nulo por desenho |
| 312: `service.create_text()` / `service.get_by_id()` | `service.record()` / `service.get()` | `get_by_id` em service é repository disfarçado; `create_text` amarra o caso de uso a uma das duas formas |
| 322 (épico vizinho, mesma forma): repository dá `commit()` | `flush()` + `refresh()` | `commit()` fora de `core/database.py` é sinal declarado de camada furada |

**A descrição do épico precisa ser corrigida no board antes de alguém pegar a tarefa.**
Não é mudança que estes arquivos fazem sozinhos.
