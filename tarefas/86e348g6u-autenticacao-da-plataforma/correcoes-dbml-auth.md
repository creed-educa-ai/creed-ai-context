# [C27] e [C28] — o que a autenticação muda no `User`

> Trecho pronto para colar em `context/modelo-de-dados.proposta.dbml`, no lugar do bloco
> `// --- Usuários ---` inteiro (hoje nas linhas 86–116). Segue o formato do arquivo:
> marca `[CNN]` no comentário, motivo antes da tabela.
>
> **Não colei por você de propósito** — o próprio `.dbml` diz que a correção é feita no
> dbdiagram e reexportada por cima. Editar o arquivo aqui criaria uma terceira cópia
> divergente. Este documento é o insumo da sua revisão com o time.

## O trecho

```dbml
// --- Usuários ---

// [C2] o ciclo obrigatório era User.vinculo_id not null + Vinculo.user_id not null:
// a primeira linha de qualquer das duas tabelas é impossível de inserir. Quem cai é
// Vinculo.user_id — o unique que o diagrama já trazia aqui diz que 1 usuário = 1
// vínculo era intenção. Consequências, que precisam ser defensáveis:
//   · pessoa com dois vínculos precisa de dois logins (email é unique);
//   · usuário não nasce antes do vínculo: a ordem de cadastro é
//     Organization + Participant -> Vinculo -> User, e o admin da plataforma
//     também precisa de um vínculo com alguma organização;
//   · ao trocar de vínculo o ponteiro se move e o vínculo antigo fica sem login.
//     A pessoa não se perde: FormResponse -> Vinculo -> Participant continua inteiro.
// Se alguma das três incomodar, o ajuste barato é vinculo_id nullable.
//
// [C26] status: é assim que se desliga um login, e não se confunde com end_at.
//   status = inactive -> o login não entra mais. Decisão de ACESSO.
//   Vinculo.end_at    -> o vínculo com a organização acabou. Fato de CADASTRO.
// São coisas separadas de propósito: alguém pode sair da organização e a conta
// continuar respondendo por outro vínculo mais tarde, e alguém pode ter o acesso
// suspenso sem que o vínculo tenha terminado. Apagar a linha do User não é
// alternativa: Dashboard.user_id aponta para cá.
//
// [C27] password SAI. A credencial passa a viver no Keycloak — é a razão de ele
// existir no desenho. Guardar hash também aqui cria duas fontes de senha e a pergunta
// que não tem resposta boa: qual das duas vale no login? Fora isso, senha no nosso
// banco é dado que o time precisa proteger, rotacionar e justificar; sem a coluna,
// não há o que vazar daqui.
// Fecha a pendência que este arquivo deixou aberta em "A v1 e a autenticação"
// ("password é nulável — login precisa saber o que fazer com senha nula"): não há
// senha nossa. O backend guarda QUEM a pessoa é e o que ela pode; QUEM ELA DIZ SER
// é do Keycloak.
//
// [C28] keycloak_id ENTRA — é o `sub` do JWT, a única ligação entre o token que chega
// na requisição e a linha desta tabela. Sem ele o backend acharia o usuário por
// email, e email é dado que muda: alguém troca o email no realm e a pessoa se
// desliga do próprio histórico.
//   · not null porque não existe User sem credencial. O provisionamento cria no
//     Keycloak primeiro, pega o sub, e só então insere aqui; se o INSERT falhar, o
//     usuário é apagado do realm (compensação explícita, ver spec da CREED-23).
//   · unique já cria o índice — não precisa de bloco indexes.
//   · NÃO é FK: aponta para fora do banco. A contagem de FKs do cabeçalho não muda.
// email fica: continua sendo o que a pessoa digita para entrar, espelhado no realm.
Table User {
  id uuid [pk, default: `uuid()`]
  vinculo_id uuid [unique, not null]
  keycloak_id uuid [unique, not null]
  email string [unique, not null]
  status RecordStatus [not null, default: 'active']
  created_at datetime [default: `now()`]
  updated_at datetime
}
```

## O que muda no resto do arquivo

| Onde | Muda? |
|---|---|
| Cabeçalho `14 tabelas · 9 enums · 21 FKs` | **não** — `keycloak_id` não é FK, e nenhuma tabela nasce ou morre |
| `Ref: User.vinculo_id > Vinculo.id` | **não** |
| `Ref: Dashboard.user_id > User.id` | **não** |
| Qualquer outra tabela | **não** — as duas correções são locais ao `User` |

Nenhuma tabela nova de autenticação. Reset de senha, verificação de e-mail e sessão são
do Keycloak, não nossos — e é isso que faz a auth caber numa v1 sem inchar o modelo.

## Depois que o time aceitar

1. Colar o trecho no dbdiagram, reexportar por cima de `context/modelo-de-dados.dbml`.
2. Acrescentar duas linhas à tabela **"Decisões já tomadas"** de
   `context/modelo-de-dados.md` (C27 e C28, com data da reunião).
3. Na seção **"A v1 e a autenticação"** do mesmo arquivo, riscar a linha
   *"`User.password` é nulável"* como resolvida por [C27] — igual ao que já foi feito
   com o `~~Não há como desativar um login~~` de [C26].
4. Só então: `models.py` do domínio `usuarios` → `alembic revision --autogenerate` →
   leitura linha a linha.

## O argumento curto, para a reunião

> Senha no nosso banco é responsabilidade que a gente não precisa ter. Colocamos o
> Keycloak justamente para não guardar credencial — se a coluna `password` ficar, ele
> vira um serviço a mais com o mesmo risco de antes. O que sobra do lado de cá é o `sub`
> do token, que não abre porta nenhuma sozinho.

E o custo: **zero hoje**, porque o banco não tem uma linha. Se o reexport sair com
`password` ainda lá, alguém preenche, e tirar depois é migration de correção com dado
gravado em cima.
