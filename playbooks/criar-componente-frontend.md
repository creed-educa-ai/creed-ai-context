# Playbook: criar componente no front

**Quando:** a task pede um componente de UI — compartilhado, primitivo ou tela de
feature. Para criar a **feature inteira** (view + slice + api + teste), o playbook é
[`criar-feature-frontend.md`](criar-feature-frontend.md); este aqui é sobre a peça de
interface.

**Regras que mandam:** [`../conventions/ui-e-responsividade.md`](../conventions/ui-e-responsividade.md).
Este playbook é a sequência; a regra mora lá.

**Molde:** depende do que você está criando —

| Você vai criar | Molde | Onde mora |
|---|---|---|
| Componente usado por mais de uma feature | `src/components/SeletorIdioma.tsx` + `SeletorIdioma.test.tsx` | `src/components/` |
| Primitivo de UI (botão, campo, diálogo) | `src/components/ui/field.tsx` + `field.test.tsx` | `src/components/ui/`, via `npx shadcn@latest add` |
| Tela de uma feature | `src/features/respondentes/RespondentesView.tsx` | `src/features/<feature>/` |

Abra o molde **antes** de escrever. Ele é a fonte; este arquivo é lembrete.

## Ordem

1. **Procure antes de criar.** `grep -ri "<nome ou algo parecido>" src/components src/features`.
   Em carga alta de componentes, o erro campeão é criar o segundo botão de ação.
2. **Decida onde mora** pela tabela acima. Componente que só uma feature usa não vai
   para `components/` "porque um dia pode servir".
3. **Precisa de um primitivo que não está em `src/components/ui/`?**
   `npx shadcn@latest add <nome>` — a registry já está configurada (`components.json`,
   estilo `radix-nova`, base `neutral`). Isso **não** é dependência nova. Pacote fora
   da registry é parada: ver §2 da convenção.
4. **Escreva o componente**, copiando a forma do molde:
   - props tipadas, sem `any`;
   - classes com `cn()` de `@/lib/utils`;
   - variantes com `cva`, não com `if` espalhado no JSX;
   - todo texto visível vindo de `useTranslation()`;
   - cores só por token do tema (`bg-primary`, `text-muted-foreground`…).
5. **Responsividade junto, não depois.** Base mobile, `md:` para cima. Confira em
   **375 · 768 · 1280** no navegador — `npm run dev` e o modo dispositivo do DevTools.
6. **Rótulos nos dois idiomas**: `src/i18n/locales/pt-BR.ts` e `en.ts`, no namespace
   `comum` se for compartilhado, no namespace da feature se for dela.
7. **Teste ao lado**, no molde do teste do componente-exemplo: renderiza, interage com
   `user-event`, afirma o comportamento. Estado que some da árvore se afirma com
   `queryBy...` devolvendo `null` — não com "está escondido".
8. **`npm run check`** — lint (com `jsx-a11y`), formatação, tipos e testes, na ordem do
   CI. Verde aqui = o check `qualidade` passa.

## Em série

A fase que vem é de muitos componentes seguidos. Três coisas mudam quando é em lote:

- **Um componente por vez, na mesma forma.** Dez componentes com dez APIs diferentes
  custam mais para revisar do que dez telas.
- **Abstração só no terceiro uso.** Dois componentes parecidos ficam parecidos; extrair
  base compartilhada antes disso costuma dar errado — a terceira variação nunca cabe.
- **Cada componente com o seu teste no mesmo commit.** Deixar "os testes para o fim" é
  como o lote inteiro chega sem nenhum.

## Erros que este playbook existe para evitar

| Erro | Sinal | O certo |
|---|---|---|
| Criar `tailwind.config.js` | o arquivo aparece no diff | Tailwind v4: tokens em `@theme`, dentro de `src/index.css` |
| `className={`...${x}`}` | string crua com condicional | `cn()` |
| Cor em hex no componente | `#185fa5` no JSX | token do tema |
| Texto direto no JSX | `<span>Salvar</span>` | `t('comum.acoes.salvar')` |
| Layout só de desktop | `w-[960px]`, nada de `md:` | base mobile + `max-w-*` |
| Instalar pacote de UI para um caso | dependência nova no `package.json` | shadcn `add`, `cva`, ou composição |
| Esconder por CSS o que devia sumir | `hidden`/`display:none` para permissão | não renderizar o nó |

## Encerramento

O componente entra na entrega didática da task
([`../templates/entrega-didatica.md`](../templates/entrega-didatica.md)) dizendo, em uma
linha cada: onde ele mora e por quê, quais tokens/variantes usou, e em que larguras
você conferiu.
