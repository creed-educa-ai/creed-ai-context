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

## 4. Antes de dar o componente por pronto

- [ ] Existe mesmo? (`grep` antes de criar — componente duplicado é o erro mais comum em lote)
- [ ] Mora no lugar certo: usado por mais de uma feature → `src/components/`; só por uma → dentro da feature; primitivo → `src/components/ui/` via CLI do shadcn.
- [ ] Sem texto hardcoded: tudo em `src/i18n/locales/`, nos dois idiomas.
- [ ] Sem cor fora dos tokens do tema.
- [ ] Conferido em 375, 768 e 1280.
- [ ] Teste ao lado do componente, no molde de `SeletorIdioma.test.tsx`.
- [ ] `npm run check` verde.
- [ ] Nenhuma dependência nova — ou, se houver, justificada no PR.
