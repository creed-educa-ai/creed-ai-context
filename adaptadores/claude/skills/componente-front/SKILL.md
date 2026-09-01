---
name: componente-front
description: Criar ou alterar componente de interface no creed-frontend — componente compartilhado, primitivo do shadcn/ui, tela de feature, formulário, menu, tabela, modal. Use sempre que a tarefa mexer em UI do front: componente novo, ajuste visual, responsividade, layout, tema ou i18n de rótulo. Carrega as regras do projeto sobre responsividade obrigatória e biblioteca fechada.
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai criar ou alterar um componente de UI do `creed-frontend`.

Leia ANTES de escrever qualquer linha:

- `creed-ai-context/playbooks/criar-componente-frontend.md` — a sequência, os moldes e a tabela de erros.
- `creed-ai-context/conventions/ui-e-responsividade.md` — as regras de UI, responsividade e dependências.
- O molde que o playbook indicar, no próprio repo. O molde é a fonte; os arquivos acima são lembrete.

<critical>RESPONSIVO DESDE O PRIMEIRO RASCUNHO. Base mobile, `md:` para cima, sem largura fixa em container, sem rolagem horizontal na página. Portabilidade entre dispositivos é entrega combinada com a cliente, não melhoria futura.</critical>
<critical>BIBLIOTECA FECHADA. Resolva com o que já está no `package.json`: shadcn/ui (estilo `radix-nova`), radix-ui, lucide-react, cva, `cn()` de `@/lib/utils`, react-hook-form + zod, tw-animate-css. Primitivo que o shadcn tem e o projeto ainda não instalou vem por `npx shadcn@latest add <nome>` — é a mesma registry já configurada, NÃO é dependência nova.</critical>
<critical>PACOTE NOVO DE UI É PARADA, não escolha sua. Só passa se for extremamente importante e sem equivalente no que já existe — e aí vira justificativa no PR, não `npm install` silencioso.</critical>
<critical>Tailwind aqui é v4, configurado em CSS: tokens em `@theme`, dentro de `src/index.css`. NÃO crie `tailwind.config.js`. Cor só por token do tema — nada de hex no componente.</critical>
<critical>Nenhum texto visível hardcoded: tudo por `useTranslation()`, com o rótulo em `src/i18n/locales/pt-BR.ts` E `en.ts`.</critical>
<critical>Procure antes de criar (`grep` em `src/components` e `src/features`). Em fase de muitos componentes, o erro campeão é criar o segundo botão de ação.</critical>
<critical>Teste ao lado do componente, com Testing Library e `user-event`. O que some por permissão ou estado se afirma com `queryBy...` devolvendo `null` — jsdom não faz layout, então as três larguras (375 · 768 · 1280) são conferência humana no navegador.</critical>
<critical>Encerre com `npm run check` verde e diga em que larguras conferiu.</critical>
