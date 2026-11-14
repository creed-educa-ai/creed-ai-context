# Task 16 — Front: texto da empresa

**Repo:** `creed-frontend`
**Depende de:** tasks 11 e 14

## Objetivo

A visão consolidada da empresa mostra o insight da empresa com os estados e a data, e a
recomendação ao lado da análise. Os recortes por setor e por pessoa ficam sem texto.

## Arquivos que provavelmente mudam

- `src/features/dashboards/CompanyDashboardView.tsx`
- `src/features/dashboards/dashboardsSlice.ts`: a mesma busca da task 11, para a visão
  da empresa
- `src/features/dashboards/components/ResultText.tsx`, se faltar algo do modo `empresa`
- `src/i18n/locales/pt-BR.ts`, `en.ts` e `es.ts`
- `src/features/dashboards/CompanyDashboardView.test.tsx`

## Molde

A task 11: os mesmos estados no `ResultText`, agora com `empresa`.

## Critérios de aceite

- [ ] Sem recorte, a visão da empresa mostra os quatro estados da task 11, com a
      recomendação ao lado da análise e a data.
- [ ] Com `pending`, a tela busca de novo como na task 11 (15 s, por até 2 min), e
      cancela ao sair.
- [ ] Com recorte por setor ou por pessoa, a seção do Creed.ai fica sem texto, e as
      marcas de destaque e oportunidade continuam.
- [ ] A administradora, ao escolher uma empresa, vê o mesmo que a gestora dela.
- [ ] Os textos novos estão nas três línguas, e a tela funciona no celular.

## Como testar

```bash
npm run test:run -- dashboards
npm run lint && npm run typecheck
```

## Premissas aplicáveis

- P-086: a gestora lê só o agregado
- P-089: insight da empresa por período
