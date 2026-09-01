---
name: feature-front
description: Implementar uma feature completa do creed-frontend — nova pasta em src/features/, tela ligada ao backend, fluxo de ponta a ponta (tipos, chamadas, estado Redux, tela, rota, i18n, testes). Use quando a task pede uma feature ou um caso de uso inteiro, não um componente isolado. Orquestra as skills contrato-front, estado-front, formulario-front e componente-front.
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai implementar uma feature do `creed-frontend` de ponta a ponta.

Leia ANTES de escrever: `creed-ai-context/playbooks/criar-feature-frontend.md` (a
sequência) e `creed-ai-context/conventions/camadas-do-front.md` (as camadas e o que vai
ao Redux). O molde é `src/features/respondentes/` — abra os quatro arquivos.

<critical>PASSO 0, ANTES DE QUALQUER CÓDIGO: abra `creed-backend/app/domains/<dominio>/router.py`. Docstring "STUB" ou diretório inexistente = o contrato NÃO existe. Hoje só `respondentes` está implementado; os outros cinco domínios são stubs registrados no main.py que respondem 404. Nesse caso PARE, diga qual arquivo você abriu, e trate o contrato como decisão de produto: spec + premissa no ledger + tarefa de backend no ClickUp. Nunca invente campo em silêncio.</critical>
<critical>Ordem obrigatória: contrato → integração (`<feature>Api.ts`) → estado (`<feature>Slice.ts`) → UI (`<Feature>View.tsx`) → rota → i18n → teste. Cada camada só conhece a de baixo; os sinais de camada furada estão em `camadas-do-front.md`.</critical>
<critical>REUSE ANTES DE CRIAR. Faça `grep` em `src/components`, `src/lib` e `src/hooks`. Já existem: `apiClient` (nunca `fetch` direto), `cn()`, `useAppDispatch`/`useAppSelector` tipados, `ListaPaginada<T>`, os primitivos de `components/ui/`. Componente novo segue a skill `componente-front`.</critical>
<critical>Estado: só dado de servidor e status vão ao slice, na máquina `idle | carregando | pronto | erro`. Campo de formulário fica no react-hook-form; aberto/fechado fica no componente; valor derivado é seletor, não campo do state.</critical>
<critical>A View cobre os QUATRO estados — inclusive `pronto` com lista vazia, que é mensagem de produto. Feature que só desenha o caso feliz volta na review.</critical>
<critical>Corte por fatia vertical (um caso de uso inteiro por task), nunca por camada horizontal. Task que não entrega comportamento não dá para revisar.</critical>
<critical>Formulário na feature: siga a skill `formulario-front` — zod e react-hook-form são obrigatórios.</critical>
<critical>Encerre com `npm run check` verde e diga: de onde veio o contrato (arquivo do backend ou premissa), o que entrou no store e por quê, e em que larguras conferiu a tela.</critical>
