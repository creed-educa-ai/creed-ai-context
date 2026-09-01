---
name: formulario-front
description: Construir formulário no creed-frontend — cadastro, edição, o instrumento respondido, qualquer tela com campos e validação. Use quando a tarefa envolve formulário, validação, zod, react-hook-form, campo obrigatório, mensagem de erro de campo ou submit.
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai construir um formulário. A régua é
`creed-ai-context/conventions/formularios.md`; os campos vêm de `src/components/ui/`
(`field.tsx`, `input.tsx`, `label.tsx`).

<critical>TODO formulário nasce com schema zod mais `zodResolver` do `@hookform/resolvers`. Nada de `useState` por campo nem validação à mão no submit. A pilha já está instalada — react-hook-form, zod, @hookform/resolvers — e não se traz biblioteca nova.</critical>
<critical>O schema mora em `src/lib/validadores.ts`, um export por schema. Schema de uma tela só pode nascer na feature e sobe no segundo uso.</critical>
<critical>O tipo do formulário vem do schema, por `z.infer` — nunca escreva a interface duas vezes.</critical>
<critical>O schema ESPELHA o contrato do backend: obrigatório no Pydantic é obrigatório no zod, `max_length=200` vira `.max(200)`. Confira em `creed-backend/app/domains/<dominio>/schemas.py`; se o domínio for stub, vale a premissa registrada (skill `contrato-front`).</critical>
<critical>Mensagem de erro é i18n: o schema guarda a CHAVE e a tela traduz. Nada de português cravado dentro do schema.</critical>
<critical>Estado do formulário NÃO vai para o Redux. Fica no react-hook-form até o submit; ao slice vai o resultado da chamada.</critical>
<critical>Erro do backend cai no campo certo: 409 de duplicado vira `setError` no campo, não alerta solto no topo. Só o que não é de campo vira mensagem de formulário.</critical>
<critical>Acessibilidade aqui é lint (`jsx-a11y` no `npm run check`): Label com `htmlFor` ligado ao `id`, erro associado por `aria-describedby` e anunciado com `role="alert"`, `aria-invalid` no campo inválido.</critical>
<critical>Teste com Testing Library e `user-event`: submete vazio, as mensagens aparecem; preenche válido, o submit é chamado UMA vez com os dados validados; backend devolve 409, a mensagem aparece NO CAMPO. Formulário sem teste de validação volta na review.</critical>
