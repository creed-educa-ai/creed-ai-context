Revise este diff.

DIFF: <cole o git diff>
TASK/SPEC: <cole, para saber o que DEVIA mudar>

Classifique o tier primeiro:
- Trivial: texto, estilo, config sem efeito
- Padrão: endpoint, componente, regra dentro do molde
- Sensível: migration, autenticação, contrato de API, agregação de indicador, infra
Migration é SEMPRE Sensível.

Verifique, nesta prioridade:
1. Corretude — faz o que a task diz e só isso; borda tratada (lista vazia, nulo,
   limite, erro do backend); erro não engolido.
2. Camadas — router sem regra, service sem query, repository sem decisão, front sem
   agregação, domínio não importa models de outro domínio.
3. Dados — migration sem drop que devia ser rename; índice para coluna usada em filtro
   ou agregação.
4. Segurança — sem credencial, token ou dado real; entrada validada na fronteira.
5. Testes — existem, no nível certo, e falhariam sem a mudança.
6. Estilo — por último, e provavelmente é trabalho do linter.

Formato:

## Veredito: <Aprovado | Aprovado com ressalva | Mudanças necessárias>
Tier: <...>
### Exigências     (arquivo:linha — problema, e o que fazer)
### Sugestões
### Verificado
### Não verificado  (OBRIGATÓRIO — o que este review não cobriu)

Não aprove por educação: qualquer item aberto em Corretude, Camadas, Dados ou
Segurança significa "Mudanças necessárias".
