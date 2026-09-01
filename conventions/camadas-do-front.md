# Camadas do front

O molde `src/features/respondentes/` — gerado no scaffold dos projetos — já tem a
separação certa. Esta convenção diz **por que** ela existe e **como perceber que
furou** — porque camada furada não dá erro de compilação, só aparece na terceira
feature, quando já é caro.

## As quatro camadas

| Camada | Arquivo | Responsabilidade | Não pode |
|---|---|---|---|
| Integração | `<feature>Api.ts` | falar HTTP: montar path, query e corpo | conhecer Redux, conhecer React |
| Estado | `<feature>Slice.ts` | guardar o que veio do servidor e o status | fazer `fetch`, formatar texto para a tela |
| UI | `<Feature>View.tsx` e componentes | desenhar e capturar interação | fazer `fetch`, agregar dado |
| Compartilhado | `src/lib/`, `src/hooks/`, `src/components/` | o que mais de uma feature usa | conhecer uma feature específica |

## Sinais de que a camada furou

| Sinal | O que está errado |
|---|---|
| `View.tsx` importando `@/lib/apiClient` | UI falando HTTP direto — passe pelo `<feature>Api.ts` |
| `<feature>Api.ts` importando `@reduxjs/toolkit` | integração sabendo de estado |
| `slice.ts` com `fetch(` ou `axios` | estado sabendo de HTTP |
| `.reduce(` na View para montar indicador | agregação no front: é do backend (`../context/arquitetura.md`) |
| um thunk que "carrega e filtra" | duas responsabilidades num lugar só — dois thunks, ou filtro no backend |
| componente que busca dado **e** desenha, com mais de uma tela usando | separe: um container que busca, um de apresentação que recebe por prop |
| `src/components/` importando de `src/features/` | compartilhado dependendo de específico — a seta aponta ao contrário |

É SOLID dito no vocabulário deste código. A regra prática: **cada arquivo tem um motivo
para mudar.** Se mudar a rota do backend obriga a mexer na View, a camada furou.

## O que vai — e o que não vai — para o Redux

| Estado | Onde mora | Por quê |
|---|---|---|
| Dado que veio do servidor | slice da feature | é compartilhado entre telas e sobrevive à desmontagem |
| Status da requisição | slice, na máquina `idle` · `carregando` · `pronto` · `erro` | é o que a View usa para escolher o que desenhar |
| Erro da requisição | slice, como mensagem já pronta | a View não interpreta `ApiError` |
| Campos de formulário | `react-hook-form` | ver `formularios.md` |
| Aberto/fechado, aba ativa, hover | `useState` no componente | ninguém mais precisa saber |
| Valor derivado (total, filtrado, ordenado) | seletor, não campo do state | campo derivado desincroniza; seletor não |

Store global com tudo dentro é o oposto de boa gestão de estado: cada campo a mais é um
lugar a mais para desincronizar.

## A máquina de status

Uma só, igual em toda feature, copiada do `respondentesSlice`:

```ts
status: 'idle' | 'carregando' | 'pronto' | 'erro'
```

A View cobre os quatro casos — inclusive **`pronto` com lista vazia**, que é estado de
produto (mensagem de vazio), não ausência de estado. Feature que só desenha o caso feliz
volta na review.

## Onde mora o compartilhado

| O quê | Onde | Quando criar |
|---|---|---|
| Cliente HTTP | `src/lib/apiClient.ts` | já existe — use, não reimplemente |
| Schemas de validação (zod) | `src/lib/validadores.ts` | no primeiro formulário; um export por schema |
| Formatação (data, número, nome) | `src/lib/formatadores.ts` | no segundo uso; o primeiro pode ficar na feature |
| Helper de classe (`cn`) | `src/lib/utils.ts` | já existe |
| Hook reutilizável | `src/hooks/` | quando duas features usarem o mesmo hook |
| Tipos do backend | `src/types/api.ts` | ver `contrato-front-back.md` |

Regra dos dois usos: **o primeiro uso mora na feature, o segundo sobe para `lib/`.**
Subir cedo demais cria util que ninguém acha; subir tarde demais cria duas versões da
mesma função.

## Dívida conhecida do molde

O `respondentes` é exemplo de scaffold, não código nascido de tarefa, e mostra a idade:
o `RespondentesView.tsx` usa `text-slate-600`, `border-red-200` e afins — cor crua, não
token do tema (`../conventions/ui-e-responsividade.md` §1). O molde é canônico na
**estrutura** (camadas, nomes, i18n, máquina de status); nessa parte específica ele é
dívida, e feature nova nasce com token. Não refatore o molde de passagem: escopo fechado
(`../context/trabalho-com-ia.md`, regra 4).
