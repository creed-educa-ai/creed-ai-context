# Premissas e dúvidas — trabalhando sem a cliente por perto

> **O ponto que quebra qualquer harness corporativo copiado.** Em time corporativo,
> a dúvida vira mensagem e a resposta chega em minutos. Aqui não: a cliente é
> professora e o contato é **em reunião marcada**. Bloquear a tarefa até a próxima
> reunião custa dias de sprint. Improvisar em silêncio custa retrabalho na review.
>
> A saída é a mesma dos dois lados: **decidir, marcar a decisão como premissa, e seguir.**

## A regra

Encontrou dúvida de **produto ou domínio** (não de técnica) no meio da tarefa:

1. **Não pare.** Escolha a interpretação mais provável e mais barata de reverter.
2. **Registre a premissa** em `../decisoes/premissas.md` (template em
   `../templates/premissa-template.md`).
3. **Marque no artefato** onde a premissa foi usada:
   `> 🟡 **Premissa P-007** — <interpretação adotada>. Confirmar na reunião.`
4. **Siga a tarefa** com essa interpretação.
5. Na reunião, a premissa entra na pauta (`../workflows/duvidas-to-pauta.md`).

## O que é e o que não é premissa

| Situação | Premissa? |
|---|---|
| "Prognóstico considera respondentes inativos?" | ✅ produto — cliente decide |
| "O relatório exporta PDF ou CSV?" | ✅ produto |
| "Esse campo é obrigatório na primeira versão?" | ✅ produto |
| "Uso `service` ou `repository` para isso?" | ❌ está em `../context/backend.md` |
| "Que nome dou para a branch?" | ❌ está no `CONTRIBUTING.md` |
| "Uso Redux ou Context?" | ❌ está no ADR-003 |

**Dúvida técnica não vira premissa** — vira leitura do harness ou do código. Se
realmente não estiver documentado, aí sim vira premissa **e** vira PR neste harness.

## Como escolher a interpretação

Nesta ordem:

1. **O que já existe no produto** — se `respondentes` já trata inativo de um jeito,
   `prognosticos` trata igual.
2. **O mais barato de reverter** — entre "guardar o campo e não mostrar" e "não
   guardar", guarde: adicionar coluna depois é migration simples; recuperar dado que
   nunca foi gravado é impossível.
3. **O menor escopo** — na dúvida entre fazer 1 coisa ou 3, faça 1.
4. **O que não trava outra pessoa** — premissa que muda contrato de API bloqueia o
   front; prefira a que mantém o contrato.

Nunca escolha "o que dá mais trabalho porque é mais completo". Premissa errada com
escopo grande é a mais cara de desfazer.

## Ciclo de vida

```
🟡 aberta  ──reunião──▶  ✅ confirmada   (vira regra; some o marcador do artefato)
                    └──▶  ❌ refutada     (vira tarefa de correção no ClickUp)
                    └──▶  🟡 segue aberta (não deu tempo; entra na pauta seguinte)
```

Premissa **refutada não é erro do time** — é o mecanismo funcionando. O erro é a
premissa que nunca foi registrada e virou comportamento silencioso do produto.

## Papel da IA nisso

A IA **deve**:
- Detectar a lacuna e dizer explicitamente: "isto não está definido".
- Propor a interpretação seguindo os 4 critérios acima, com uma linha de justificativa.
- Escrever a premissa no ledger e o marcador no artefato.
- Continuar a tarefa.

A IA **não deve**:
- Perguntar ao usuário e esperar quando a resposta depende da cliente (o usuário não
  tem a resposta).
- Preencher a lacuna em silêncio, sem registrar.
- Registrar como premissa algo que está documentado — isso é preguiça de leitura.

## Ledger

`../decisoes/premissas.md`. Uma linha por premissa, ID sequencial `P-NNN`, nunca
reaproveitado. Premissa fechada **fica no arquivo** com o desfecho — o histórico é o
que evita rediscutir a mesma coisa na sprint seguinte.
