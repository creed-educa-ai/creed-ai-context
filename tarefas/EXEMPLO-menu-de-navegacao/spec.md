# EXEMPLO — Criar menu de navegação (CREED-17)

> ⚠️ **Exemplo, não tarefa a implementar.** A tarefa existe no ClickUp, mas estes
> artefatos saíram de um **ensaio da esteira SDD** (MCP do ClickUp + `/calibrar` +
> `/spec` + `/tasks`). Nada foi implementado: não há branch, commit nem código de menu
> no `creed-frontend`. Fica como segundo exemplo de forma — este gerado a partir de uma
> tarefa real, complementando o `EXEMPLO-relatorio-por-organizacao/`, que é sintético.
>
> As premissas P-003, P-004 e P-005 nasceram aqui e estão no ledger marcadas como
> `EXEMPLO` na coluna Tarefa: não são decisão de produto e não vão para a pauta.

## Calibragem

**P3 · T1**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | regra de negócio nova — "bloquear a visão de algumas opções dependendo da role" — e 3 premissas novas (P-003, P-004, P-005) |
| Técnico | T1 | um repo, componente dentro do molde (`SeletorIdioma.tsx`), sem contrato de API, sem migration |

Dispensadas nesta calibragem: Contrato · Dados · Abordagem técnica.
Régua: [`../../conventions/profundidade-da-spec.md`](../../conventions/profundidade-da-spec.md).

## Problema

A plataforma não tem navegação: `src/app/routes.tsx` expõe só `/` e `/respondentes`, e
cada tela nova nasce sem caminho até ela. Junto disso, não existe forma de esconder uma
opção de quem não pode usá-la — hoje todo mundo veria tudo.

## Quem usa

Todo cliente autenticado da organização, em dois papéis que a tarefa cita: o **admin da
empresa**, que precisa chegar em "gerenciar funcionários", e o **funcionário**, que não
pode nem ver essa opção.

## Escopo

**Entra:**
- Componente de navegação compartilhado, responsivo entre web e mobile.
- Marcação por papel nos itens: cada item declara quais papéis o enxergam.
- Itens apontando para as rotas que **existem** em `routes.tsx`.
- Rótulos em `src/i18n/locales/` (pt-BR e en).
- Testes: render por papel e comportamento responsivo.

**Não entra:**
- Autenticação e login — não existe tarefa dessa funcionalidade no board: CREED-5 e
  CREED-13 são protótipo no Figma (`#FIGMA`), não implementação.
- Endpoint de papéis no backend: nesta task o papel vem do estado do front (P-004).
- As telas que o menu aponta (dashboard, formulário, cadastro de empresa): outras tasks.
- Autorização de verdade. Esconder item não protege rota — ver Riscos.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-frontend | componente de navegação compartilhado + rótulos i18n + testes |
| creed-backend | nada nesta task |
| creed-infrastructure | nada |

Não é feature nova: o menu é transversal, então mora em `src/components/`, não em
`src/features/<nome>/` (`context/frontend.md` — componente usado por mais de uma
feature é compartilhado). Não há domínio espelhado no backend.

## Critérios de aceite

- [ ] O menu aparece em todas as rotas registradas em `src/app/routes.tsx`.
- [ ] Abaixo de 768px o menu colapsa em botão e abre sobreposto; a partir de 768px fica visível sem interação.
- [ ] Item restrito a um papel **não é renderizado** para quem não tem o papel — não basta esconder por CSS.
- [ ] Um admin vê "gerenciar funcionários"; um funcionário não vê a opção na árvore renderizada.
- [ ] Nenhum texto visível hardcoded: todo rótulo vem de `src/i18n/locales/`.
- [ ] Existe teste para os dois papéis e para o colapso mobile.
- [ ] `npm run check` verde.

## Como verificar

1. `npm run dev` e abrir `/respondentes`.
2. Reduzir a janela para menos de 768px: o menu vira botão e abre sobreposto.
3. Trocar o papel na fonte definida por P-004 e recarregar: as opções restritas somem da
   árvore (conferir no inspetor que o nó não existe, não que está `display:none`).
4. `npm run check`.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-003 | Os papéis desta fase são `admin` e `funcionario`, dois níveis apenas. | baixo |
| P-004 | O papel vem do estado do front (slice dedicado, valor fixo em desenvolvimento) até a autenticação existir. | baixo |
| P-005 | O menu lista só rotas já registradas em `routes.tsx`; tela desenhada no Figma e ainda sem rota não vira item. | baixo |

Ledger completo em [`../../decisoes/premissas.md`](../../decisoes/premissas.md).

## Riscos

- **Esconder no menu não é autorização.** Sem checagem no backend, a rota segue
  acessível por URL. Sinal de que deu errado: funcionário digita a URL de gerenciar
  funcionários e a tela abre. Mitigação fora desta task: autorização no backend.
- **O Figma é a fonte visual e não está versionado aqui.** Se o desenho mudar, o
  componente muda junto. Sinal: divergência apontada na review de UX.
- **P-004 não tem data para sair.** A autenticação como funcionalidade não tem tarefa no
  board — CREED-5 e CREED-13 entregam só a tela no Figma —, então o papel fixo no front
  pode durar sprints. Sinal: dois lugares decidindo qual é o papel do usuário, ou tela
  nova nascendo já acoplada ao valor fixo.
