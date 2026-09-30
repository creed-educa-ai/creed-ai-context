# Tasks — CREED-47 Integração das tabelas e domínios da sprint 2 (backend)

Spec: [`spec.md`](spec.md)

## Progresso

**Um PR só, com um commit por task**, na branch `feat/86e3gurw3-integracao-sprint-2`,
com base na `dev`.

- [x] 1 — [Banco: as cinco FKs e `answer.form_response_id`](1_task.md) · `creed-backend` · revisão `d53324b9b5a2`
- [x] 2 — [Conferências: `links`, `questions` e `form-responses` confirmam o que recebem](2_task.md) · `creed-backend`
- [x] 3 — [`forms` e `questions` com login e organização](3_task.md) · `creed-backend`
- [x] 4 — [`form-responses`: o vínculo vem do login, e só o dono mexe](4_task.md) · `creed-backend`
- [x] 5 — [Gravar e ler respostas individuais](5_task.md) · `creed-backend`
- [x] 6 — [O envio exige as descritivas obrigatórias](6_task.md) · `creed-backend`
- [x] 7 — [Seed de demonstração](7_task.md) · `creed-backend`

Marque aqui ao concluir cada task ([`workflows/tasks-to-code.md`](../../workflows/tasks-to-code.md)).

## Ordem e corte

```
1 (banco) ─────────────────────────────┐
                                        ├──► 5 (respostas) ──► 6 (envio) ──► 7 (seed demo)
2 (conferências) ──► 3 (forms/questions) ──► 4 (form-responses) ┘
```

**Um PR, decidido pelo Luís em 2026-09-30.** O merge precisa acontecer no mesmo dia, e um
PR só é mais fácil de acompanhar do que cinco encadeados. A regra 6 de
[`conventions/migrations.md`](../../conventions/migrations.md) não impede: nada sai do
banco, só entram FKs e uma coluna numa tabela vazia. Nenhum documento do projeto limita o
tamanho do PR.

**Um commit por task** mantém a leitura possível: a `dev` mescla com merge commit (#29,
#30), então quem revisa percorre o PR commit a commit, na ordem acima. Cada commit passa
na suíte sozinho.

**A 1 e a 2 não tocam arquivo em comum.** Da 3 à 7 a ordem é obrigatória: todas mexem nos
`service.py` e `router.py` de `forms`, `questions` e `responses`.

**Se o dia acabar antes:** a 7 sai do PR sem prejuízo, e o formulário de demonstração
pode ser montado pelo Swagger. A 6 também pode sair, mas o envio continua aceitando
formulário incompleto. As tasks 1 a 5 são o mínimo que fecha o fluxo.

**Tamanho:** 1, 2, 3 e 5 levam perto de uma jornada cada; 4, 6 e 7, meia cada.

## Achado ao decompor, que a spec não previa

- **Dois testes afirmam que não há FK:** `tests/domains/links/test_models.py`
  (`test_has_no_foreign_key`) e `tests/domains/responses/test_models.py` (FK vazia e o
  conjunto de colunas de `answer`). Eles registram a decisão de entregar isolado, que
  esta tarefa encerra. A task 1 inverte os dois.
- **Os testes de router de `forms`, `questions` e `responses` não passam pela guarda.**
  Eles só sobrescrevem o service. Com a guarda, tudo vira 401. As tasks 3 e 4 os migram
  para a forma de `tests/domains/participants/test_router.py` (`autenticar_como`, com o
  `validate_token` falso).
- **`responses/service.py` não pode importar `QuestionType`.**
  `test_dominio_nao_importa_dominio` só libera composição por `service` e `dependencies`
  (`SUBMODULOS_DE_COMPOSICAO`). Quem responde "essa pergunta aceita texto?" é o
  `QuestionService` (task 5).

## Fora do escopo desta rodada

O mesmo "Não entra" da spec. Em resumo: FKs de organização e setor (CREED-38/39),
objetiva e `option_id` (CREED-37), renomear `vinculo_id`, transição de status do
formulário, edição de resposta, juntar `questions` e `forms`, front.
