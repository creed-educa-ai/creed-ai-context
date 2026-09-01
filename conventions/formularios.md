# Formulários

Boa parte do CREED é formulário: cadastro de organização, de funcionário, o instrumento
que o respondente preenche. Formulário feito à mão diverge rápido — cada um valida de um
jeito e reporta erro de outro. Esta convenção fecha a forma.

## A pilha, que já está instalada

| Peça | Papel |
|---|---|
| `react-hook-form` | estado dos campos, submit, foco no erro |
| `zod` | o schema: o que é válido |
| `@hookform/resolvers/zod` | liga os dois (`zodResolver`) |
| `src/components/ui/field.tsx`, `input.tsx`, `label.tsx` | os campos |
| `react-i18next` | rótulo, placeholder e **mensagem de erro** |

Nada além disso. Formulário não é motivo para trazer biblioteca nova
(`ui-e-responsividade.md` §2).

## Regras

1. **Todo formulário nasce com schema zod.** Nenhum `useState` por campo, nenhum
   `if (!valor)` espalhado no submit. Sem schema, não é formulário — é rascunho.
2. **O schema mora em `src/lib/validadores.ts`**, um export por schema
   (`organizacaoSchema`, `respondenteSchema`). Schema usado por uma tela só pode nascer
   na feature e sobe no segundo uso (`camadas-do-front.md`).
3. **O tipo vem do schema**, não é escrito duas vezes:
   `type OrganizacaoForm = z.infer<typeof organizacaoSchema>`.
4. **O schema espelha o contrato**, não o inventa: campo obrigatório no Pydantic é
   obrigatório no zod; `max_length=200` vira `.max(200)`. Divergiu, o backend ganha
   (`contrato-front-back.md`).
5. **Mensagem de erro é i18n**, como qualquer texto visível. O schema guarda a **chave**,
   a tela traduz — schema não fala português cravado.
6. **O estado do formulário não vai para o Redux.** Ele vive no `react-hook-form` até o
   submit; o que vai para o slice é o **resultado** da chamada.
7. **Erro do backend cai no campo certo.** 409 de e-mail duplicado vira erro no campo
   e-mail (`setError('email', ...)`), não um alerta solto no topo. Erro que não é de
   campo (5xx) vira mensagem de formulário.
8. **Botão de submit desabilitado enquanto envia**, e o estado de envio sai do
   `formState.isSubmitting` — não de um `useState` paralelo.

## Acessibilidade — que aqui é lint

O `eslint-plugin-jsx-a11y` roda no `npm run check`. Na prática:

- todo input tem `<Label htmlFor>` ligado ao `id`;
- a mensagem de erro é associada ao campo (`aria-describedby`) e anunciada
  (`role="alert"`);
- campo inválido carrega `aria-invalid`;
- o foco vai para o primeiro campo com erro no submit — o `react-hook-form` já faz,
  desde que os campos estejam registrados.

## Teste

Com Testing Library e `user-event`, no mínimo:

- submete vazio → aparece a mensagem de cada campo obrigatório;
- preenche válido → a função de submit é chamada **uma vez**, com os dados já validados;
- backend devolve 409 → a mensagem aparece **no campo**, não no topo.

Validação é lógica, e lógica se testa. Formulário sem teste de validação volta na review.

## Erros que esta convenção existe para evitar

| Erro | Sinal |
|---|---|
| Validação na mão | `if (!email.includes('@'))` dentro do componente |
| Schema duplicando o tipo | `interface Form` escrita ao lado de um `z.object` igual |
| Mensagem cravada | `'Campo obrigatório'` no `z.string().min(1, ...)` sem passar por i18n |
| Estado de campo no Redux | `dispatch(setNome(e.target.value))` |
| Erro do backend no lugar errado | 409 virando toast genérico com o campo intacto |
