# Equipe

Quem é quem no CREED.ai Educa. Usado por [`playbooks/abrir-pr.md`](playbooks/abrir-pr.md)
e por quem precisa saber a quem perguntar.

Levantado da organização `creed-educa-ai` em 2026-08-31.

## Maintainers — review obrigatória

Time do GitHub: **`creed-educa-ai/maintainers`** — "Quem pode mergear em dev e main".

| Papel | GitHub | Nome | Acesso |
|---|---|---|---|
| AGES IV | `@gabriellrmartins` | Gabriel Levasseur Rocha Martins | maintain |
| AGES III | `@Kv1ecz` | Luís Felipe Leal | admin |

`/pr` pede review **do time**, não das pessoas:

```
gh pr create --reviewer creed-educa-ai/maintainers
```

Dois motivos. Pedir review de um time que inclui o autor **não dá erro** — o GitHub
apenas não conta o autor; pedir para a própria pessoa derruba o `gh pr create`. E a
composição do time vira no GitHub quando a turma muda, sem PR neste repositório.

O merge exige **1 aprovação** 🔒 — o time é para não depender de quem está disponível,
não para exigir duas.

## Time

| GitHub | Nome | Acesso |
|---|---|---|
| `@PedroFonseca447` | Pedro B B Fonseca | write |
| `@guamaro` | Gustavo | write |
| `@RicardoGraziato` | — | write |
| `@EnzoVivian` | Enzo Vivian | write |
| `@mariardsilva` | Maria Eduarda Rodrigues da Silva | write |
| `@leoRossol` | Leonardo Rossol | write |
| `@josiassr11` | Josias Rocha | write |
| `@junioorst` | Júnior Stahl | write |
| `@sanx111` | — | write |
| `@gbothr` | Gustavo Both | write |
| `@BryanAlmerindo` | Bryan Leo | write |
| `@pedrosimoes06` | Pedro da Silva Simões | write |
| `@lucoimbra00` | — | write |

## Fora do time

| Papel | Quem | Como falar |
|---|---|---|
| Cliente | Profa. Dra. Naira Maria Lobraico Libermann | só em reunião marcada — dúvida vira premissa (`conventions/premissas-e-duvidas.md`) |
| Professor 🟡 | Marcelo H. Yamaguti — `@mhyamaguti` | acesso `read` nos repos: acompanha, **não aprova PR** |

> 🟡 O papel de `@mhyamaguti` foi inferido do acesso somente-leitura, não confirmado.
> Corrija esta linha se estiver errada.

## Identidade do `gh` — confira antes do primeiro `/pr`

`/pr` abre o PR com a conta que o `gh` estiver usando, e uma variável `GH_TOKEN` no
ambiente **tem prioridade sobre a conta logada**. Se o token for de outra conta sem
push nos repos, o comando falha na abertura do PR.

```bash
gh auth status
```

A conta mostrada precisa aparecer na tabela "Time" ou "Maintainers" acima. Se aparecer
uma conta estranha com `Token: ghp_...`, é `GH_TOKEN` no ambiente — remova a variável
desta sessão para o `gh` voltar à conta do keyring.

## Ao virar o semestre

Turma nova: atualize as tabelas acima **e** o time `maintainers` no GitHub. O comando
lê o time; as tabelas são para gente.
