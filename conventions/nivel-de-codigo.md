# Nível de código: o que "AGES III" significa no diff

Quem implementa aqui — pessoa ou modelo — escreve no nível de **arquiteto de software
/ líder técnico**. Isso é constantemente confundido com "código esperto". É o oposto.

> **Sênior é quem resolve o problema de um jeito que o time consegue manter.**
> Código que só o autor entende é um problema adiado, não uma entrega.

## 1. A régua

> Um colega do time, que não acompanhou a task, entende o arquivo **em uma passada**,
> sem perguntar nada e sem abrir outros três arquivos para descobrir o que aquilo faz.

Não passou na régua? Não entra. Reescreva mais simples — mesmo que a versão complexa
seja mais elegante, mais genérica ou mais curta.

## 2. Onde a senioridade aparece de verdade

| Aparece em | Não aparece em |
|---|---|
| A regra ficar na camada certa | usar um recurso raro da linguagem |
| Nome que diz o que é, no vocabulário do domínio | abreviar para caber em 80 colunas |
| Borda tratada antes de virar bug em produção | abstrair "para quando precisar" |
| Teste que falha no lugar certo | teste que cobre linha sem provar comportamento |
| Erro que aparece cedo e explica o que houve | `try/except` largo que engole tudo |
| Migration que não perde dado | one-liner que faz três coisas |

## 3. Não entra sem justificativa escrita

| Padrão | Por que não | O que fazer |
|---|---|---|
| Abstração para **um** caso de uso | a segunda implementação nunca chega | código direto; abstrai na segunda |
| Factory / Strategy / Registry com uma opção | indireção sem ganho | `if`/`match` explícito |
| Metaprogramação (`__getattr__`, `setattr` dinâmico, decorator novo) | quebra o "ir na definição" e o mypy | função nomeada |
| Genéricos TS com 3+ parâmetros ou tipos condicionais | erro de tipo vira parágrafo ilegível | tipo concreto, ou dois tipos |
| Herança para compartilhar código | acopla e esconde origem do comportamento | composição / função utilitária |
| Comprehension aninhada em 2+ níveis | denso na leitura, difícil de depurar | `for` com nome intermediário |
| Padrão que **nenhum arquivo do repo usa ainda** | vira dialeto pessoal | siga o molde, ou proponha em ADR |
| `any`, `# type: ignore`, `except Exception: pass` | apaga a checagem que o CI faz | trate, ou tipe de verdade |
| Dependência nova | ninguém revisou licença, peso, manutenção | peça antes |

"Justificativa escrita" = uma linha no encerramento didático dizendo o que quebrava
sem aquilo. Não é veto absoluto — é ônus da prova invertido.

## 4. Simples não é primitivo

Estas coisas **são** esperadas, e não contam como complexidade:

- Tipagem completa: Pydantic no back, tipos explícitos no front. Tipo é documentação
  que o CI verifica.
- Função pequena com nome do domínio (`calcular_indice_plasticidade`) em vez de bloco
  de 60 linhas dentro do service.
- Early return em vez de `else` aninhado.
- Constante nomeada em vez de número solto.
- Erro específico (`RespondenteNaoEncontrado`) em vez de `Exception`.
- `select(...).group_by(...)` no repository — agregação **é** SQL aqui, e SQL denso
  no lugar certo é melhor que Python "legível" no lugar errado
  (`../CONTEXT.md` → princípio 1).

## 5. Comentário

Comentário explica **por quê**, nunca **o quê**. Se o "o quê" precisa de comentário, o
nome está errado.

```python
# ruim: incrementa o contador
contador += 1

# bom: a cliente conta reentrada como resposta nova (P-004)
contador += 1
```

Sem `# gerado por IA` (`../context/trabalho-com-ia.md` §4).

## 6. Quando a solução é mesmo complexa

Existe. Agregação de indicador, cálculo de prognóstico, migration com dado em produção
— há casos em que a solução simples está errada. Nesses:

1. A complexidade fica **isolada** em uma função/módulo com nome claro.
2. O resto do diff continua trivial de ler.
3. O encerramento didático explica a lógica em português.
4. O teste cobre o caso de borda que motivou a complexidade.

O que não pode é a complexidade **espalhada** — três arquivos meio difíceis são muito
piores que um difícil e dois óbvios.

## 7. No review

Item de review, não de gosto pessoal. `../checklists/revisao-de-codigo.md` → Legibilidade.
"Não entendi este trecho" é uma **exigência** válida de review, não implicância.
