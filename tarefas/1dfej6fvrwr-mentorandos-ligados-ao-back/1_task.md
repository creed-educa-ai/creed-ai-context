# Task 1 — Tabela de mentorandos lendo a M-2

**Repo:** `creed-frontend`
**Depende de:** nenhuma (a M-2 já está no `dev` do back)

## Objetivo

A tabela de mentorandos do painel da administradora lista os vínculos `mentoria` da
organização dela, vindos do back, sem a coluna de status, com "Ver resultados" seguindo
quem já respondeu e "Editar" abrindo o questionário com o período da pessoa.

## Contexto

Hoje a tabela lê um mock (`menteeSeed` em `usersApi.ts`) no formato provisório `Mentee`
(`id`, `name`, `email`, `status`, `hasAnsweredCurrent`). O back agora responde
`GET /api/v1/organizations/{organization_id}/members?type=mentoria` com
`MemberListItem[]`:

```ts
type PeriodStatus = 'past' | 'open' | 'scheduled';

interface MemberPeriod {
  form_id: string;
  opens_at: string;   // ISO
  closes_at: string;  // ISO
  period_status: PeriodStatus;
  has_answered: boolean; // resposta ENVIADA naquele período
}

interface MemberListItem {
  link_id: string;    // o vínculo: a chave da linha
  name: string;
  email: string | null; // nulo em vínculo criado sem convite
  role: Role;
  type: LinkType;
  department: DepartmentType | null;
  updated_at: string | null;
  period: MemberPeriod | null; // o período atual, senão o próximo, senão o último
}
```

Erros: 401, 403 (não é admin nem gestor, ou gestor de outra organização), 404
(organização não existe), 422 (`type` inválido). A tela trata todos como o estado de
erro que já existe (`mentees:loadError`).

A organização vem da sessão: `state.authentication.user?.organization_id`. Para a
administradora, é a da CREED.

## Arquivos que provavelmente mudam

- `src/types/api.ts`
  - na seção `links`: `PeriodStatus`, `MemberPeriod` e `MemberListItem`, como acima;
  - sai `Mentee`.
- `src/features/links/linksApi.ts`: `listMembers(organizationId: string, type?: LinkType)`,
  um `GET` com `?type=` quando vier.
- `src/features/links/linksApi.test.ts`: a rota, com e sem `type`.
- `src/features/users/usersApi.ts`: saem `menteeSeed`, `menteeRegistry` e `listMentees`.
  **`removeMentee` e `resetMenteesMock` ficam até a task 2**, porque a exclusão ainda
  não chama o back.
- `src/features/users/usersSlice.ts`
  - `mentees.items` passa a ser `MemberListItem[]`;
  - `loadMentees(organizationId: string)` chama `linksApi.listMembers(organizationId,
    'mentoria')`;
  - `deleteMentee.fulfilled` filtra por `link_id`.
- `src/features/users/MenteesSection.tsx`
  - lê a organização da sessão e dispara `loadMentees(organizationId)`. Sem organização
    na sessão, não chama o back e mostra o estado de erro;
  - o `editing` passa a ser `MemberListItem`;
  - o diálogo recebe os valores iniciais do `period` da linha (P-082).
- `src/features/users/MenteesTable.tsx`
  - troca `Mentee` por `MemberListItem`, e `id` por `link_id`;
  - sai a coluna de status, com o `StatusBadge`, o `STATUS_ORDER`, a ordenação por
    status e o selo no cartão do celular;
  - "Ver resultados": `disabled={mentee.period?.has_answered !== true}`;
  - e-mail nulo mostra a célula vazia e não quebra a busca:
    `normalizeForSearch(mentee.email ?? '')`.
- `src/features/forms/ManageQuestionnaireDialog.tsx`: aceita valores iniciais opcionais.
  Quando vierem, o formulário abre com eles, separados em data e hora locais a partir
  de `opens_at` e `closes_at`. Sem eles, abre vazio, como hoje.
- `src/i18n/locales/{pt-BR,en,es}.ts`: saem as chaves de status de `mentees`
  (`columns.status`, `status.*`) que não forem mais usadas.
- Testes: `MenteesTable.test.tsx`, `MenteesSection.test.tsx`, `usersSlice.test.ts`,
  `ManageQuestionnaireDialog.test.tsx` e `AdminControlPanelView.test.tsx` deixam de usar
  `resetMenteesMock` e o seed, e montam `MemberListItem` próprios no arquivo de teste.

## Molde

- `linksApi.createLink` em `src/features/links/linksApi.ts`, para a chamada.
- `loadMembers` em `src/features/users/usersSlice.ts`, para o thunk e os três estados.

## Critérios de aceite

- [ ] `linksApi.listMembers('org', 'mentoria')` faz `GET /organizations/org/members?type=mentoria`.
- [ ] A seção carrega com a organização da sessão. Sem organização na sessão, mostra o
      estado de erro e não chama o back.
- [ ] A tabela e os cartões do celular mostram nome e e-mail do que veio do back, sem
      coluna, selo nem ordenação de status. A ordenação por nome continua.
- [ ] "Ver resultados" fica desabilitado com `period` nulo e com `has_answered` falso, e
      habilitado com `has_answered` verdadeiro.
- [ ] "Editar" abre o diálogo com a data e a hora de abertura e de fechamento do `period`
      da linha, e vazio quando `period` é nulo.
- [ ] Uma linha com `email: null` aparece, e a busca por e-mail não quebra.
- [ ] `Mentee`, `menteeSeed` e `listMentees` não existem mais em `src`.
- [ ] `npm run check` passa.

## Como testar

```bash
cd creed-frontend
npx vitest run src/features/users src/features/links src/features/forms src/features/controlPanel
grep -rnE "\bMentee\b|menteeSeed|listMentees" src   # não deve achar nada
npm run check
```

Casos: lista com dois mentorandos, um respondido e um sem período; lista vazia; uma linha
sem e-mail; erro do back (o estado de erro aparece).

Ponta a ponta: back do `dev` local, login como a administradora, `/control-panel/admin`.
A tabela mostra os vínculos `mentoria` da CREED.

## Premissas aplicáveis

- P-082: "Editar" abre o diálogo preenchido com o período da linha. Gravar é da P-5.
- P-064: "Editar" sempre habilitado. Só "Ver resultados" depende de ter respondido.
- P-068 e P-069: qual período aparece, e "respondeu" é resposta enviada. Quem decide é o
  back; a tela não recalcula.
- P-070: sem paginação no back. A paginação continua na tela.

## Como ficou (diferenças do plano acima)

- **O diálogo ganhou a prop `initialPeriod`** (`Pick<MemberPeriod, 'opens_at' | 'closes_at'>`).
  Ao abrir, ele converte as datas ISO do back para data e hora locais. O efeito depende
  das duas datas, e não do objeto, para não apagar o que já foi digitado quando a tela
  de fora desenha de novo.
- **Sem organização na sessão**, a seção mostra a mesma mensagem de erro da carga e não
  chama o back.
- **Saíram as chaves de status** de `mentees` nos três idiomas (`columns.status`,
  `status.*`). `comum:tabela.ordenarPorStatus` ficou, porque outras tabelas usam.
- **O `removeMentee` virou um mock vazio** até a task 2, para a tabela continuar tirando
  a linha.
