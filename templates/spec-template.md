# <ID ClickUp> — <título da tarefa>

> Preencher com `workflows/tarefa-to-spec.md`. Seções vazias devem ser apagadas,
> não deixadas com "N/A" — spec com placeholder é spec que ninguém leu. Quais seções
> valem para esta tarefa é a calibragem abaixo que decide
> (`conventions/profundidade-da-spec.md`).

## Calibragem

**P<1-3> · T<1-3>**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P<n> | <o sinal da tarefa que decidiu — frase da descrição, premissa, regra nova> |
| Técnico | T<n> | <o sinal — repo, molde, contrato, migration> |

Dispensadas nesta calibragem: <lista, ou "nenhuma">.

<Bloco único: recalibrar substitui, não acrescenta.>

## Problema

<O que está ruim hoje, em uma ou duas frases. Não a solução.> — **sempre**

## Quem usa

<Respondente? Organização? Time interno? Para quê. Em P3, quebrado por papel:
quem enxerga o quê.> — **P2+**

## Escopo

**Entra:** — **sempre**
- <item>

**Não entra:** — **P2+**
- <item — esta lista vale tanto quanto a de cima>

## Repos afetados

**sempre** — uma linha em T1, tabela a partir de T2.

| Repo | O que muda |
|---|---|
| creed-backend | <domínio, endpoints> |
| creed-frontend | <feature, telas> |
| creed-infrastructure | <ou "nada"> |

Nome do domínio/feature (iguais nos dois lados): `<nome>`

## Contrato

**T2+** — endpoints novos ou alterados. Request/response em alto nível.

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| GET | `/api/v1/<recurso>` | — | `<Recurso>Read[]` |

## Dados

**T3** (em T2, só se houver coluna nova) — tabelas e colunas novas, migration prevista,
agregação nova, e o que acontece com o dado que já existe.

## Abordagem técnica

**T3** — a opção escolhida **e a descartada**, com o motivo de uma linha. É a metade
techspec do documento: sem ela, um T3 é PRD com tabela de endpoint.

## Critérios de aceite

- [ ] <verificável — dá para dizer sim ou não> — **sempre**
- [ ] <verificável>

## Como verificar

1. <passo concreto que o revisor executa> — **sempre**
2. <passo>

## Premissas

**P2+**

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-NNN | <interpretação adotada> | baixo / médio / alto |

<Premissa aberta também vai para `decisoes/premissas.md`.>

## Riscos

**nível 2 em qualquer eixo**

- <o que pode dar errado, e o sinal de que deu>
