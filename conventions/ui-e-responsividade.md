# UI e responsividade

Vale para todo componente do `creed-frontend`. Duas regras mandam aqui, e as duas vêm
da entrega combinada com a cliente:

1. **Responsivo não é caso especial.** Portabilidade entre dispositivos é entrega, não
   melhoria futura. Componente que só funciona em desktop está incompleto, não pronto.
2. **A biblioteca é fechada.** O que já está no `package.json` resolve; trazer pacote
   novo de UI é decisão do time, não do componente da vez.

## 1. O que já existe — use plenamente

| Para | Use | Onde |
|---|---|---|
| Primitivos de UI | shadcn/ui, estilo `radix-nova`, base `neutral` | `src/components/ui/` |
| Composição por baixo | `radix-ui` (o shadcn é a camada por cima) | via shadcn |
| Ícones | `lucide-react` | `iconLibrary` do `components.json` |
| Variantes de um componente | `class-variance-authority` (cva) | ver `src/components/ui/button.tsx` |
| Juntar classes | `cn()` de `@/lib/utils` (clsx + tailwind-merge) | sempre, nunca template string crua |
| Formulário | `react-hook-form` + `zod` + `@hookform/resolvers` | — |
| Animação | `tw-animate-css` e utilitárias do Tailwind | — |
| Texto visível | `react-i18next` (`useTranslation`) | `src/i18n/locales/` |
| Estado compartilhado | Redux Toolkit | `src/app/store.ts` |
| Teste | Vitest + Testing Library + `user-event` | `src/test/setup.ts` |

Detalhes que mudam o código e passam despercebidos:

- **Tailwind é v4, configurado em CSS.** Os tokens ficam em `@theme`, dentro de
  `src/index.css`. **Não existe `tailwind.config.js` e não crie um.**
- **Ordem de classe é automática.** O `prettier-plugin-tailwindcss` ordena; não perca
  tempo alinhando classe na mão.
- **Acessibilidade é lint.** O `eslint-plugin-jsx-a11y` roda no `npm run check`:
  `aria-label` em controle sem texto, `alt` em imagem, rótulo associado a input.
- **Tema por variável CSS.** Cores saem dos tokens (`bg-background`, `text-foreground`,
  `bg-primary`…), nunca hex no componente — a identidade visual ainda será definida
  com a cliente e vai mudar em um lugar só.

## 2. Precisa de algo que não existe?

| Situação | O que fazer |
|---|---|
| Primitivo que o shadcn tem e o projeto ainda não instalou (`dialog`, `sheet`, `dropdown-menu`, `tabs`, `table`, `sonner`…) | `npx shadcn@latest add <nome>` — é a **mesma registry já configurada**, não é dependência nova |
| Variação visual de um componente que já existe | acrescente uma variante com `cva` no próprio componente |
| Composição de dois componentes existentes | componha; não crie um terceiro primitivo |
| Ícone que falta | procure no `lucide-react` — ele tem milhares |
| Pacote de UI fora dessa lista (outro kit, outro set de ícones, carrossel, framer-motion, date picker externo…) | **PARE.** É dependência nova: justifique no PR, e se for estrutural vira ADR |

O critério para o último caso é estreito de propósito: **extremamente importante e sem
equivalente no que já temos**. "Seria mais bonito" e "eu já usei em outro projeto" não
passam. Cada pacote a mais é bundle, superfície de bug e uma segunda forma de fazer a
mesma coisa — o oposto do molde único.

## 3. Responsividade

- **Mobile-first.** A base do `className` é a tela pequena; `sm:`, `md:`, `lg:` sobem
  a partir dela. Escrever desktop primeiro e corrigir com `max-` é o caminho que
  produz layout quebrado no celular.
- **Breakpoints são os do Tailwind**, sem inventar: `sm` 640 · `md` 768 · `lg` 1024 ·
  `xl` 1280.
- **Nada de largura fixa** em container: `w-full` + `max-w-*`, `flex` ou `grid`. Px
  fixo só em ícone e em coisa que realmente não escala.
- **Sem rolagem horizontal na página.** Conteúdo largo (tabela, código) rola dentro do
  próprio container: `overflow-x-auto` no wrapper.
- **Alvo de toque** de pelo menos ~40px de altura em controle clicável no mobile — os
  tamanhos padrão do shadcn (`h-9`/`h-10`) já atendem; não reduza abaixo disso.
- **Breakpoint é CSS, não JavaScript.** Nada de detectar dispositivo por user-agent
  para decidir layout.
- **Confira em três larguras**, sempre: **375** (celular), **768** (tablet) e **1280**
  (desktop).

O teste automatizado **não** cobre isso: o jsdom não faz layout. Vitest cobre
comportamento (o menu começa fechado e abre no clique); as três larguras são
verificação humana, no navegador, e entram no "Como testar" da task.

## 4. Movimento e interação

Aprendido no questionário (sprint 2). Movimento aqui tem função — mostrar para onde a
pessoa foi, confirmar um toque — e nunca é enfeite.

### Animação

A biblioteca é o `tw-animate-css` (`animate-in`, `fade-in-*`, `slide-in-from-*`,
`zoom-in-*`, `delay-*`, `fill-mode-*`) mais as transições do Tailwind. Nada de pacote de
animação (§2).

| Regra | Por quê |
|---|---|
| **O que se repete é curto: ~300ms.** O que aparece uma vez (entrada de tela, conclusão) pode ir a 500–700ms | a troca de pergunta acontece dezenas de vezes; 500ms na décima já cansa |
| **Bloco grande entra com opacidade inicial** (`fade-in-50`), não do zero | um bloco de cor forte sumindo e voltando a cada troca é lido como piscada |
| **A direção diz o sentido:** avançar entra pela direita, voltar pela esquerda, tela nova entra de baixo (como o login) | a pessoa sabe para onde foi sem ler nada |
| **Só anima o que mudou.** O `key` que dispara a animação é o conteúdo: entre duas perguntas de escala, os botões de 1 a 5 ficam parados | animar o que é igual é ruído |
| **Sempre `motion-reduce:animate-none`** (e `motion-safe:` em efeitos de toque) | quem pediu menos movimento ao sistema não vê nenhum |
| **`animate-in` não divide elemento com outra animação** (ex.: `animate-brand-giro`). Ponha uma no elemento de fora | as duas usam a propriedade `animation`; no mesmo elemento, uma apaga a outra |
| **Painel que cresce até virar a tela** (View Transitions, `transicao-painel-marca`) só quando boa parte da tela de destino já tem aquela cor | no cadastro → aguarde metade da tela já é roxa e funciona; um bloco pequeno virando a tela inteira fica ruim — ali, um `fade-in` basta |

### Toque e hover

| Regra | Como |
|---|---|
| Hover **só por token do tema**: `hover:bg-accent` no que não está selecionado, `hover:bg-primary-hover` no que está | nada de `primary/10`, `muted/40`: tom com transparência é cor fora do design system |
| `secondary` e `accent` são **a mesma cor** no tema | hover de algo que já é lavanda não se vê com `secondary` — use `hover:bg-border`, um tom acima |
| Opção de resposta afunda ao ser pressionada | `motion-safe:active:scale-95`; em elemento largo, `active:scale-98` — 5% numa opção larga é encolhimento visível |
| Selecionado é **roxo cheio com texto branco**, em qualquer tipo de opção | escala, múltipla escolha e aba atual falam a mesma língua |

### Modais

| Tipo | Componente | Visual |
|---|---|---|
| Comum (informação, contato) | `Dialog` | `bg-background`, fecha clicando fora |
| **Obrigatório** (a pessoa tem que escolher) | `AlertDialog` | o visual padrão dele (fundo `popover`, faixa de botões no `AlertDialogFooter`), para não se confundir com o comum |

No obrigatório, **nem clique fora nem Esc fecham**: ignore o `onOpenChange(false)` e
feche só pelos botões. Clique fora e Esc **destacam a ação principal** (foco + anel), em
vez de não fazer nada — o `AlertDialogContent` aceita `onOverlayClick` para isso.
Os botões dizem a ação ("Revisar dados", "Iniciar questionário"), não "Sim" e "Não".

## 5. Antes de dar o componente por pronto

- [ ] Existe mesmo? (`grep` antes de criar — componente duplicado é o erro mais comum em lote)
- [ ] Mora no lugar certo: usado por mais de uma feature → `src/components/`; só por uma → dentro da feature; primitivo → `src/components/ui/` via CLI do shadcn.
- [ ] Sem texto hardcoded: tudo em `src/i18n/locales/`, nos dois idiomas.
- [ ] Sem cor fora dos tokens do tema — inclusive no hover (nada de `primary/10`).
- [ ] Animação com `motion-reduce:animate-none`, e curta se for se repetir (§4).
- [ ] Conferido em 375, 768 e 1280.
- [ ] Teste ao lado do componente, no molde de `SeletorIdioma.test.tsx`.
- [ ] `npm run check` verde.
- [ ] Nenhuma dependência nova — ou, se houver, justificada no PR.
