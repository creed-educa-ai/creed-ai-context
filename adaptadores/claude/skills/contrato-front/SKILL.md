---
name: contrato-front
description: Ligar o front ao backend do CREED — transcrever schemas Pydantic para src/types/api.ts, escrever <feature>Api.ts sobre o apiClient, conferir rota, query params e códigos de status. Use quando a tarefa envolve integração, endpoint, tipo de API, erro HTTP, ou quando for preciso saber se um domínio do backend existe de verdade.
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai ligar o front ao backend. A régua é
`creed-ai-context/conventions/contrato-front-back.md`.

<critical>PORTÃO: abra `creed-backend/app/domains/<dominio>/router.py` ANTES de escrever. Endpoints de verdade → transcreva. Docstring "STUB" ou diretório inexistente → PARE e diga que o domínio não existe. Hoje NENHUM domínio tem contrato acordado: `organizacoes`, `prismas`, `prognosticos`, `relatorios` e `dashboards` são stubs que respondem 404, e `respondentes` é exemplo gerado no scaffold dos projetos — molde de FORMA (camadas, paginação, máquina de status), nunca fonte de campos acordados.</critical>
<critical>A fonte da verdade é o código, nesta ordem: `schemas.py` → `router.py` → OpenAPI em `/api/v1/docs` com o backend rodando. O `src/types/api.ts` é espelho MANUAL: transcreva, não interprete.</critical>
<critical>`snake_case` do backend PERMANECE `snake_case` no TypeScript (`data_nascimento`, `tamanho_pagina`). Opcional e nulo não são a mesma coisa. Campo calculado no response (como `idade`) não existe no create. Paginação já tem forma — `ListaPaginada<T>`; não crie uma segunda.</critical>
<critical>Toda chamada passa pelo `src/lib/apiClient.ts` (get/post/patch/delete, base `/api/v1`, `ApiError` com status). Nunca `fetch` direto, nunca URL absoluta — o Vite faz proxy.</critical>
<critical>O `<feature>Api.ts` tem funções puras: parâmetro entra, promessa sai. Sem Redux, sem React, sem `try/catch` — quem trata erro é o slice.</critical>
<critical>422 do backend NÃO é erro de usuário: é transcrição errada do contrato. Volte ao `schemas.py` em vez de tratar na tela.</critical>
<critical>Domínio stub: o contrato vira premissa em `creed-ai-context/decisoes/premissas.md` e tarefa de backend no ClickUp, e o tipo no front leva comentário apontando a premissa. Quando o backend chegar e divergir, o backend ganha.</critical>
