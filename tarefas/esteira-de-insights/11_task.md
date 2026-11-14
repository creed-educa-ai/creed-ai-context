# Task 11 — Front: estados do Creed.ai

**Repo:** `creed-frontend`
**Depende de:** task 10

## Objetivo

O `ResultText` mostra o insight quando ele está pronto, "em preparo" enquanto a esteira
trabalha, e "não ficou disponível" quando ela desiste, sempre com a data. A confirmação
do envio avisa que o insight vem a seguir.

## Arquivos que provavelmente mudam

- `src/types/api.ts`: transcrição do `CreedSummaryRead` e do `InsightStatusRead`
- `src/features/dashboards/dashboardsApi.ts`
- `src/features/dashboards/dashboardsSlice.ts`: busca de novo enquanto o status é
  `pending`
- `src/features/dashboards/components/ResultText.tsx`
- `src/features/dashboards/UserDashboardView.tsx`
- `src/features/responses/SubmissionConfirmationView.tsx`, com chamada ao
  `GET /form-responses/{id}/insight`
- `src/i18n/locales/pt-BR.ts`, `en.ts` e `es.ts`
- os testes desses arquivos

## Molde

- `src/features/authentication/`: a forma de uma feature.
- As skills `contrato-front`, `estado-front` e `componente-front`.

## Critérios de aceite

- [ ] O `ResultText` mostra cada estado assim:
  - `done`: os textos e "gerado em <data>";
  - `pending`: "em preparo", no lugar dos textos;
  - `failed`: "não ficou disponível", **sem** botão de tentar de novo (P-044);
  - `none`: a seção fica sem texto, e as marcas de destaque e oportunidade continuam.
- [ ] No dashboard, com `pending`, a tela busca de novo a cada 15 s por até 2 min. Ao
      sair da tela, a busca é cancelada (`abort`).
- [ ] A confirmação do envio:
  - diz que o insight está em preparo;
  - consulta o `GET /form-responses/{id}/insight` a cada 5 s, por até 2 min;
  - quando o status vira `done`, mostra o link para o dashboard;
  - se o teto chegar antes, diz que o insight aparece no dashboard quando ficar pronto.
- [ ] O resultado do cálculo continua na tela em todos os estados.
- [ ] Os textos estão nas três línguas, e a tela funciona no celular.
- [ ] Os testes cobrem os quatro estados e o cancelamento da busca.

## Como testar

```bash
npm run test:run -- dashboards responses
npm run lint && npm run typecheck
```

## Premissas aplicáveis

- P-044: sem "tentar de novo"
- P-088: a tela individual mostra análise e prismas; a recomendação fica gravada
