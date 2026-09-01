# Workflow: tasks → código

## Entrada
`tarefas/<ID>-<slug>/N_task.md` + spec para contexto.

## Saída
Código no working tree, testes verdes, entrega didática, task marcada em `tasks.md`.
**Sem commit.**

## Princípios

- **Uma task por vez.** Não implemente duas em paralelo — o diff fica irrevisável.
- **Ler antes de escrever:** task → spec → molde (`respondentes`) → `context/` do repo.
- **Copiar a forma do molde**, não inventar estrutura.
- **Teste junto**, não depois.
- **Escopo fechado**: nada fora da task entra no diff.
- **Nível do time**, não código esperto (`../conventions/nivel-de-codigo.md`).
- **Julgamento é humano**: bifurcação de design vira parada, não escolha silenciosa.

## Passos

| # | Passo | Modo agente | Modo copiloto |
|---|---|---|---|
| 1 | Ler task, spec e molde | lê | cole os arquivos |
| 2 | Conferir dependências (tasks anteriores marcadas?) | lê `tasks.md` | você confere |
| 3 | Carregar o playbook aplicável | `../playbooks/` | cole o playbook |
| 4 | Bifurcação de design? → **parada de decisão** (abaixo) | pergunta e espera | você decide antes de aplicar |
| 5 | Implementar código + teste | escreve arquivos | você aplica as sugestões |
| 6 | Rodar a suíte | roda | **você roda** |
| 7 | Auto-review contra `../checklists/revisao-de-codigo.md` | gera veredito | você lê o diff |
| 8 | Encerrar em `../templates/entrega-didatica.md` | escreve a entrega | você lê e cobra o que faltou |
| 9 | Marcar a task em `tasks.md` | edita | você edita |
| 10 | Responder à `../checklists/defesa-do-codigo.md` | — | **só você** |

## Parada de decisão

Antes de escrever, classifique a dúvida. **Só a última linha vira pergunta**:

| Situação | Ação | Pergunta? |
|---|---|---|
| O molde (`respondentes`) já resolve | siga o molde | não |
| Convenção, playbook ou ADR já resolve | siga | não |
| Lacuna de **produto** (o que o sistema deve fazer) | premissa (`../conventions/premissas-e-duvidas.md`) | não |
| Diferença só de estilo, sem efeito no diff | escolha e siga | não |
| Bifurcação **técnica** com efeito visível no diff, sem resposta no harness | **PARE** | sim |

Caso padrão, quando nada acima se aplica: **siga sem perguntar** e registre a decisão
na seção "Decisões desta task" do encerramento, atribuída ao agente — não ao humano.

Formato da parada — no máximo **2 por task**, apresentadas de uma vez:

```
⏸ DECISÃO SUA — <onde, no código>

  A) <opção>   + <ganho> · − <custo>
  B) <opção>   + <ganho> · − <custo>

  O molde faz <A/B/não cobre>. Recomendo <X> porque <motivo em uma linha>.
  Responda A, B ou "decide você".
```

Regras:

- **Duas opções, no máximo três.** Mais que isso é análise, não decisão.
- **Recomende uma.** Parada sem recomendação empurra o trabalho de volta.
- **"Decide você" é resposta válida**: implemente a recomendada e registre no
  encerramento que a escolha foi do agente, não do humano. Não finja consenso.
- **Não pare por migration**: migration não é bifurcação, é proposta que precisa de
  leitura humana linha a linha (`../playbooks/criar-migration.md`).
- Estourou o limite de 2? As demais viram decisão do agente, registradas no encerramento.

## Playbooks

| Task envolve | Playbook |
|---|---|
| domínio novo no backend | `../playbooks/criar-dominio-backend.md` |
| feature nova no front | `../playbooks/criar-feature-frontend.md` |
| mudança de schema | `../playbooks/criar-migration.md` |
| versionar e abrir PR | `../playbooks/abrir-pr.md` |

## Encerramento

Terminada a task, a resposta encerra no formato de
[`../templates/entrega-didatica.md`](../templates/entrega-didatica.md) — a parte
didática primeiro, o bloco operacional fechando:

```
Arquivos tocados: <lista>
Suíte: <comando> → <resultado, ou "não executada">
Premissas usadas: P-NNN (ou nenhuma)
Fora do escopo, observado mas não mexido: <lista ou "nada">
Próximo passo humano: rodar a suíte, ler o diff, responder à defesa, seguir para a task N+1
```

Encerramento sem as seções didáticas é entrega incompleta — a explicação é parte do
trabalho, não um extra (`../context/aprendizado.md`).

Não faça commit. Versionar é `../playbooks/abrir-pr.md`, sob pedido explícito.
