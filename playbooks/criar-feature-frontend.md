# Playbook: criar feature no front

**Quando:** a task cria `src/features/<nome>/` ou acrescenta tela a uma feature.

**Molde:** `src/features/respondentes/` — abra os quatro arquivos antes de começar. Ele é
canônico na **estrutura**; sobre as cores cruas dele, ver a dívida conhecida em
[`../conventions/camadas-do-front.md`](../conventions/camadas-do-front.md).

**Regras que mandam:**
[`camadas-do-front.md`](../conventions/camadas-do-front.md) ·
[`contrato-front-back.md`](../conventions/contrato-front-back.md) ·
[`formularios.md`](../conventions/formularios.md) ·
[`ui-e-responsividade.md`](../conventions/ui-e-responsividade.md)

Para a peça de interface isolada (um componente, um ajuste visual), o playbook é
[`criar-componente-frontend.md`](criar-componente-frontend.md).

## Passo 0 — o contrato existe?

**Antes de qualquer código.** Abra `creed-backend/app/domains/<dominio>/router.py`:

| O que você encontra | Caminho |
|---|---|
| endpoints de verdade | transcreva o contrato real (passo 2) e siga |
| docstring "STUB", ou diretório inexistente | o contrato vira decisão de produto: spec + premissa + tarefa de backend no ClickUp, e o front codifica contra o tipo escrito a partir da spec |

Hoje só `respondentes` está implementado. Pular este passo é o que produz front pronto
contra campo que nunca existiu.

## Ordem

1. **Nome** — igual ao domínio do backend. `prognosticos` no back, `prognosticos` no
   front. Sem acento, plural.
2. **`src/types/api.ts`** — transcreva os `schemas.py`. `snake_case` permanece;
   opcional e nulo não se misturam; campo calculado existe na leitura e não no create.
3. **`<feature>Api.ts`** — funções puras sobre o `apiClient`. Só aqui existe HTTP.
   Sem Redux, sem React, sem `try/catch`.
4. **`<feature>Slice.ts`** — thunks, máquina `idle · carregando · pronto · erro`,
   erro já virando mensagem. O que **não** entra no store está na convenção de camadas.
   Registrar o reducer em `src/app/store.ts`.
5. **`<Feature>View.tsx`** — a tela. Cobre os **quatro** estados, incluindo `pronto` com
   lista vazia. Sem `fetch`, sem agregação, sem string literal visível.
6. **Componentes** — procure antes de criar; siga
   [`criar-componente-frontend.md`](criar-componente-frontend.md). Formulário segue
   [`formularios.md`](../conventions/formularios.md).
7. **i18n** — namespace com o nome da feature em `pt-BR.ts` e `en.ts`; `comum` para o
   que é compartilhado.
8. **Rota** — registrar em `src/app/routes.tsx`.
9. **Testes** — slice (reducers e transições) e o que tiver interação de verdade.
10. **`npm run check`** — lint, formatação, tipos e testes, na ordem do CI.

## Fatiamento

Feature inteira num diff só é irrevisável. Corte por **fatia vertical**: contrato +
estado + tela do caso de uso principal primeiro; os demais casos de uso depois, um por
task. Cada fatia sobe verde e é revisável sozinha.

Não corte por camada horizontal ("uma task para os tipos, outra para o slice"): task que
não entrega comportamento não dá para revisar nem testar.

## Erros que este playbook existe para evitar

| Erro | Sinal |
|---|---|
| Integrar contra domínio stub | `router.py` só com `APIRouter(prefix=...)` e nenhum endpoint |
| Campo inventado | `types/api.ts` com nome que não aparece em nenhum `schemas.py` |
| Agregação no front | `.reduce(`, `.filter().length` para montar indicador |
| Fetch fora do Api | `fetch(` ou `axios` na View ou no slice |
| Nome divergente do backend | pasta `analises` para o domínio `prognosticos` |
| Só o caso feliz | View sem tratar `erro` e sem mensagem de vazio |
| Texto hardcoded | string em português dentro do JSX |
| Componente de uma feature em `components/ui/` | só uma feature importa |

## Antes de fechar

```bash
npm run check
```

Verde aqui = o check `qualidade` do CI passa. A entrega didática diz, em uma linha cada:
de onde veio o contrato (arquivo do backend ou premissa), o que entrou no store e por
quê, e em que larguras a tela foi conferida.
