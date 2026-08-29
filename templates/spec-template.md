# <ID ClickUp> — <título da tarefa>

> Preencher com `workflows/tarefa-to-spec.md`. Seções vazias devem ser apagadas,
> não deixadas com "N/A" — spec com placeholder é spec que ninguém leu.

## Problema

<O que está ruim hoje, em uma ou duas frases. Não a solução.>

## Quem usa

<Respondente? Organização? Time interno? Para quê.>

## Escopo

**Entra:**
- <item>

**Não entra:**
- <item — esta lista vale tanto quanto a de cima>

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | <domínio, endpoints> |
| creed-frontend | <feature, telas> |
| creed-infrastructure | <ou "nada"> |

Nome do domínio/feature (iguais nos dois lados): `<nome>`

## Contrato

<Endpoints novos ou alterados. Request/response em alto nível. Apague se não houver.>

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| GET | `/api/v1/<recurso>` | — | `<Recurso>Read[]` |

## Dados

<Tabelas e colunas novas. Migration prevista? Agregação nova?>

## Critérios de aceite

- [ ] <verificável — dá para dizer sim ou não>
- [ ] <verificável>

## Como verificar

1. <passo concreto que o revisor executa>
2. <passo>

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-NNN | <interpretação adotada> | baixo / médio / alto |

<Ou "nenhuma". Premissa aberta também vai para `decisoes/premissas.md`.>

## Riscos

- <o que pode dar errado, e o sinal de que deu>
