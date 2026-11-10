# Task 7 — Tabela de empresas ligada ao back

**Repo:** `creed-frontend`
**Subtarefa:** [694 · Integração (E4-E5)](https://app.clickup.com/t/1dfej6fvrvu)
**Branch:** a mesma da task 6 (`feat/694-integracao-empresas`), em outro commit
**Depende de:** task 6 (tipos novos de `OrganizationResponse`). Para o teste no navegador:
tasks 1, 4 e 5 na `dev` do back. Para a verificação do "Esqueci minha senha": o
**[creed-backend#52](https://github.com/creed-educa-ai/creed-backend/pull/52) na `dev`**.

## Objetivo

O painel da administradora lista as empresas reais e aprova, rejeita e exclui pelo back,
sem nenhum mock.

## Contexto

A seção "Empresas" do painel da super adm (`/control-panel/admin`) mostra nome, e-mail,
resultados, status e excluir. A pendente aparece com um botão "Pendente" que abre o
modal de aceite: nome, documento, e-mail, responsável e telefone, e os botões aceitar e
rejeitar. Hoje tudo isso lê a lista fictícia do `organizationsApi.ts`, com o tipo
provisório `Company` (`nomeEmpresa`, `documento`…), que só existia até o back ter o
contrato (`conventions/contrato-front-back.md`, "Onde a tela diverge do back").

Com o back pronto, a tela passa a ler `OrganizationResponse` direto. Aceitar chama a
aprovação, que manda o convite de gestor; rejeitar e excluir chamam a mesma exclusão
(P-078). A lista não mostra a organização da própria CREED, que é a da sessão da
administradora (P-081).

"Ver resultados" **não** muda: o dashboard da empresa para a administradora não tem rota
no back.

## Contrato (visto do front)

| Chamada | Rota | Sucesso | Erros que a tela trata |
|---|---|---|---|
| listar | `GET /organizacoes?pagina=N&tamanho_pagina=200` | `ListaPaginada<OrganizationResponse>` | qualquer erro: o estado de erro da seção |
| aprovar | `POST /organizations/{id}/approval` | 200 `OrganizationResponse` (ativa) | 409 (já não está pendente, ou o e-mail já tem acesso) · 503 |
| rejeitar / excluir | `DELETE /organizations/{id}` | 204 | 409 (a própria organização) · 503 (nada foi apagado) |

## Arquivos que provavelmente mudam

- `src/types/api.ts`: saem `Company`, `CompanyRegistration` e `CompanyStatus` (bloco
  "PROVISÓRIOS DA TELA").
- `src/features/organizations/organizationsApi.ts`
  - Sai todo o bloco MOCK (`companySeed`, `companyRegistry`, `resetCompaniesMock`,
    `listCompanies`, `approveCompany`, `rejectCompany`, `removeCompany`) e o comentário
    do topo que o explica.
  - `approveOrganization(id)` →
    `apiClient.post<OrganizationResponse>(`/organizations/${id}/approval`, undefined)`.
    A rota não tem corpo, e o `post` do `apiClient` exige o segundo argumento.
  - `deleteOrganization(id)` → `apiClient.delete(`/organizations/${id}`)` (o `delete`
    não tem genérico: 204 sem corpo).
  - Comentário: `GET`/`PATCH` em `/organizacoes`, `DELETE` e aprovação em
    `/organizations` (spec, Abordagem técnica, item 5).
- `src/features/organizations/organizationsSlice.ts`
  - Estado: `organizations: OrganizationResponse[]`, mais `status` e `error` como hoje.
  - `loadOrganizations`: pede a página 1 com `tamanho_pagina=200` e segue pedindo
    enquanto a soma dos itens for menor que o `total`.
  - `approveOrganization`: troca o item pela resposta. `rejectValue`: 409 →
    `'empresas:toasts.naoAprovadaDescricao'`, o resto → `'tenteNovamenteEmInstantes'`.
    Depois de um 409, a seção recarrega a lista, porque outra pessoa pode ter aprovado
    antes.
  - `deleteOrganization`: tira o item. Rejeitar usa o mesmo thunk.
- `src/features/organizations/CompaniesSection.tsx`
  - Filtra `organization.id !== state.authentication.user?.organization_id` (P-081),
    com o marcador 🟡.
  - Os toasts de aprovar, rejeitar e excluir no sucesso e na falha, com a chave que o
    slice devolveu.
- `src/features/organizations/CompanyTable.tsx`: props com `OrganizationResponse[]`;
  `name`, `email ?? ''` na busca e na coluna; status: `pending` → botão "Pendente",
  `active` → `StatusPill tone="success"` "Ativo", `inactive` → `StatusPill` sem tom
  "Inativo". As pendentes continuam no topo.
- `src/components/modals/CompanyApprovalModal.tsx`: `empresa: OrganizationResponse |
  null`; mostra `name`, `document.value`, `email`, `contact_name`, `phone`, com "—" no
  nulo.
- `src/i18n/locales/pt-BR.ts`, `en.ts`, `es.ts`
  - `empresas.status.inativo`.
  - `empresas.toasts.naoAprovadaDescricao`: "Ela pode já ter sido aprovada, ou o e-mail
    informado já tem acesso à plataforma. Se for o e-mail, rejeite o cadastro."
  - `empresas.toasts.erroExcluir`.
  - `empresas.confirmarExclusao.descricao`: "Excluir {{nome}} apaga a empresa, todos os
    membros dela, as respostas e os questionários. Não dá para desfazer."
- Testes: `organizationsApi.test.ts`, `CompaniesSection.test.tsx`,
  `CompanyTable.test.tsx` e um `organizationsSlice.test.ts` novo.
- `creed-ai-context/conventions/contrato-front-back.md`: a linha "Empresas (super adm) e
  cadastro público" sai da tabela de divergências e vira um "Resolvido em ...", como os
  que já existem abaixo dela.
- `creed-ai-context/catalogo.md`: a linha da feature `organizations` deixa de dizer
  "mock".

## Molde

- `requestPasswordReset` em `src/features/authentication/authenticationSlice.ts`:
  `rejectWithValue` com chave de i18n a partir do `ApiError.status`.
- `src/test/stubFetch.ts` e os testes atuais de `organizationsApi.test.ts`.
- `StatusPill` em `src/components/table/tablePills.tsx` (sem `tone` é o neutro).

## Critérios de aceite

- [ ] Nenhum `Company`, `CompanyRegistration`, `CompanyStatus` ou mock de empresa no
      `src/` (`grep` vazio).
- [ ] Com `total: 250`, o slice faz duas chamadas (`pagina=1` e `pagina=2`) e guarda as
      250.
- [ ] A organização da sessão não aparece na tabela. As outras aparecem com "Pendente",
      "Ativo" ou "Inativo".
- [ ] O modal mostra o número do documento e os dados de contato que vieram do back.
- [ ] Aceitar: `POST .../approval`, a linha vira "Ativo", toast de sucesso. 409: toast
      com o texto de "não aprovada" e a lista recarregada. 503: toast de tentar de novo.
- [ ] Rejeitar e excluir: `DELETE /organizations/{id}`, a linha some. 503: toast de
      erro, e a linha fica.
- [ ] A confirmação de exclusão diz que não dá para desfazer, nos três idiomas.
- [ ] `npm run check` passa.

## Como testar

```bash
cd creed-frontend
npx vitest run src/features/organizations src/components/modals
npm run check
```

No navegador (`npm run dev`, back com as tasks 1 a 5, Mailpit de pé), o fluxo da spec:

1. `/sign-up` com um e-mail novo → `/awaiting-confirmation`.
2. Entre como admin, abra `/control-panel/admin`, clique em "Pendente", aceite.
3. Abra o convite em `http://localhost:8025`, defina a senha, entre como gestor.
4. **"Esqueci minha senha"** (com o #52 na `dev`): em `/login`, clique no link, peça com
   o e-mail do gestor, confira o segundo e-mail no Mailpit e defina uma senha nova.
5. Cadastre outra empresa e rejeite. Exclua a primeira e confira que o gestor não entra
   mais.
6. Repita a tabela e o modal em 375 px de largura.

**O que os testes não provam:** o passo 4, que depende de um PR de outra tarefa. E o
caso da sessão sem `organization_id` (login desligado): aí nada é filtrado, e a
organização da CREED aparece na tabela. O back continua recusando excluí-la (409).

## Premissas aplicáveis

- P-078 — rejeitar é a exclusão.
- P-079 — só a administradora vê e usa esta tabela (o back barra os outros papéis).
- P-081 — sem a organização da sessão; "Inativo" para a inativa.
- P-053 — aceitar manda o convite de gestor ao e-mail do cadastro.
