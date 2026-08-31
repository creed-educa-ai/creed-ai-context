# Entrega didática — formato

Formato **fixo** com que toda implementação encerra
(`../workflows/tasks-to-code.md` → "Encerramento"). A parte didática vem primeiro; o
bloco operacional fecha.

Regras de preenchimento:

- Português, direto, sem repetir o código — explique **decisão**, não sintaxe.
- Seção sem conteúdo real vira `nada` / `nenhuma`. **Não invente** alternativa
  descartada para preencher linha.
- Nada de "implementei conforme solicitado": se a seção não ensina nada, corte a
  seção, não encha de prosa.
- Tamanho alvo: cabe na tela. Task trivial encerra em 10 linhas.

---

## Task N — <título>

### O que a task pedia

<Uma frase, em linguagem de produto — não de código.>

### Abordagem escolhida — e por que esta

<2 a 5 linhas. O caminho tomado e o motivo, ancorado no molde, na convenção ou no
princípio que mandou. Ex.: "A soma por organização vai no `repository.py` com
`GROUP BY` porque agregação é do banco (CONTEXT §1); o service só formata.">

### O que descartei

| Alternativa | Por que não |
|---|---|
| <caminho plausível que alguém tentaria> | <motivo concreto: custo, camada errada, quebra em X> |

<Se não havia alternativa real — o molde só permitia um caminho — escreva
"nenhuma: o molde de `respondentes` já fixa a forma" e siga.>

### Mapa do diff

| Arquivo | Papel na solução |
|---|---|
| `app/domains/<nome>/repository.py` | query agregada nova |
| `tests/domains/<nome>/test_service.py` | caso feliz + lista vazia |

### O que os testes provam — e o que não provam

- **Provam:** <comportamento coberto, em português>
- **Não provam:** <o que ficou de fora e por quê — ex.: "o `GROUP BY` só é exercido
  com banco real; o teste de service usa repository fake">

### Decisões desta task — e quem decidiu

| Parada | Quem decidiu | Escolha | Efeito no código |
|---|---|---|---|
| <bifurcação apresentada> | você / agente | <A ou B> | <o que mudou por causa disso> |

<Se a resposta foi "decide você": a linha entra com "agente" em "Quem decidiu",
junto com o motivo da recomendação. Não se finge consenso.
Nenhuma parada na task: "nenhuma — não houve bifurcação fora do molde".>

### Onde isto pode quebrar depois

<Riscos concretos e verificáveis: volume de dados, índice faltando, contrato que o
front assume, borda não coberta. Se não houver, "nada previsível".>

### Para você conseguir defender

<Três perguntas sobre ESTE diff, com o arquivo e a linha onde está a resposta. Não
responda por ele — aponte onde ler. Checklist completo em
`../checklists/defesa-do-codigo.md`.>

1. <pergunta> → `arquivo:linha`
2. <pergunta> → `arquivo:linha`
3. <pergunta> → `arquivo:linha`

---

```
Arquivos tocados: <lista>
Suíte: <comando> → <resultado, ou "não executada">
Premissas usadas: P-NNN (ou nenhuma)
Fora do escopo, observado mas não mexido: <lista ou "nada">
Próximo passo humano: rodar a suíte, ler o diff, responder à defesa, seguir para a task N+1
```
