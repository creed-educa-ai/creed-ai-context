# Workflow: review

Uma camada só — o time tem 1 aprovação obrigatória por PR e não precisa de mais.

## Entrada
`git diff dev...HEAD` (ou o diff da task, quando a review é durante a implementação).

## Passos

1. **Classificar o tier** — Trivial / Padrão / Sensível
   (`../checklists/revisao-de-codigo.md`). Migration é sempre Sensível.
2. **Ler o diff inteiro.** Não revise por resumo: arquivo por arquivo.
3. **Ler o contexto ao redor** do que mudou, não só as linhas do diff — bug de camada
   só aparece no arquivo inteiro.
4. **Aplicar o checklist** do tier.
5. **Rodar a suíte** (modo agente: roda; modo copiloto: você roda).
6. **Emitir veredito**: Aprovado · Aprovado com ressalva · Mudanças necessárias.

## Formato do veredito

```markdown
## Veredito: <Aprovado | Aprovado com ressalva | Mudanças necessárias>
Tier: <Trivial | Padrão | Sensível>

### Exigências
- `arquivo.py:42` — <problema> -> <o que fazer>

### Sugestões
- `arquivo.tsx:17` — <observação>

### Verificado
- <o que foi conferido e está certo>

### Não verificado
- <o que o review não cobriu — seja honesto aqui>
```

A seção **Não verificado** é obrigatória. Review que não diz o que deixou de olhar
dá falsa segurança — e com uma aprovação só, falsa segurança é caro.

## Para a IA

Não aprove por educação. Se houver item de Corretude, Camadas, Dados ou Segurança
aberto, o veredito é **Mudanças necessárias**, mesmo que o resto esteja bom.
