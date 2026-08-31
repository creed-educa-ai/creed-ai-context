# Defesa do código

Passo **humano**, antes do PR. Você responde **de cabeça, com o diff aberto e o chat
fechado**. Leva de 3 a 10 minutos e é o que separa "entreguei" de "aprendi".

Não é prova, não tem nota e ninguém corrige — mas se você não passa por ela, o
primeiro a descobrir vai ser o revisor, e depois a cliente.

## Sempre

- [ ] Digo, em uma frase, **o que** esta task passou a fazer que antes não fazia.
- [ ] Aponto no diff **onde** a regra de negócio ficou, e por que naquela camada.
- [ ] Sei o que acontece com **entrada vazia ou nula** — e mostro o teste que cobre.
- [ ] Sei qual teste **falharia** se eu revertesse a mudança principal.
- [ ] Sei citar uma alternativa que foi descartada e o motivo.
- [ ] Não há linha no diff que eu não saiba explicar. Nenhuma.
- [ ] Se um colega perguntar "por que assim?", respondo sem abrir o chat.

## Backend, quando o diff toca `app/domains/`

- [ ] `router` sem regra, `service` sem query, `repository` sem decisão — e sei dizer
      qual linha justificaria a acusação contrária.
- [ ] Sei o que a query faz em português, incluindo `join` e `group by`.
- [ ] Sei quais testes precisam de banco real e por quê (`../conventions/testes.md`).

## Frontend, quando o diff toca `src/features/`

- [ ] Nenhuma agregação no front — e sei de onde vem o número já pronto.
- [ ] Sei o que está no slice, o que está na View, e por que a divisão é essa.
- [ ] Sei o que a tela mostra durante o carregamento e no erro do backend.

## Migration, se houver

- [ ] Li o arquivo **linha a linha** e sei o que cada operação faz no banco.
- [ ] Sei dizer se alguma operação perde dado, e o que acontece se rodar duas vezes.
- [ ] Rodei `alembic heads` e veio **um** head.

## Se você não passou

Você não pediu o código de novo — você pergunta melhor:

| Travou em | Peça |
|---|---|
| o que o trecho faz | "explique `arquivo:linha` linha a linha, sem reescrever" |
| por que foi feito assim | "quais alternativas você descartou aqui e por quê" |
| complexidade demais | "reescreva no nível de `../conventions/nivel-de-codigo.md`" |
| não concordo com a decisão | mude você — a decisão é sua, o modelo não assina o PR |

Depois, refaça a defesa. Passar aqui é item da
[`definition-of-done.md`](definition-of-done.md).
