# Workflow: review

Uma camada só — o time tem 1 aprovação obrigatória por PR e não precisa de mais.

## Entrada
`git diff dev...HEAD` (ou o diff da task, quando a review é durante a implementação).

## Passos

1. **Classificar o tier** — Trivial / Padrão / Sensível
   (`../checklists/revisao-de-codigo.md`). Migration é sempre Sensível.
   Sensível → siga até o veredito e **pare** no bloco de escalada (abaixo).
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
Escalada: <exigida — ver bloco abaixo | não se aplica>

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

No tier Sensível ela é também a entrada da escalada: é dela que a passada pesada parte.

## Tier Sensível: pare e escale

A review em modelo médio vai até o veredito e **para ali**. Ela não cumpre sozinha o
que o tier exige (`../checklists/revisao-de-codigo.md`):

| Exigência do tier | Quem faz |
|---|---|
| Checklist aplicado | esta passada |
| Passada com modelo pesado | você, numa sessão com modelo pesado |
| Segunda leitura humana | outra pessoa do time |

**Não re-rode `/revisar`.** O comando declara modelo médio no frontmatter, e o
frontmatter vence o modelo da sessão — rodar de novo devolve a mesma passada. Abra uma
sessão com modelo pesado e peça, em prosa:

```
Revise <alvo> seguindo creed-ai-context/workflows/revisao.md, no papel de
creed-ai-context/roles/revisor.md. Tier Sensível, motivo: <migration | autenticação |
contrato de API | agregação de indicador | infra>. Já houve uma passada em modelo
médio — comece pelo que ela deixou em "Não verificado".
```

Bloco obrigatório no fim do veredito Sensível:

```markdown
### Escalada exigida — tier Sensível
Motivo do tier: <migration | autenticação | contrato de API | agregação | infra>
- [ ] Passada com modelo pesado — <quem vai rodar>
- [ ] Segunda leitura humana — @<pessoa>
Esta passada rodou em modelo médio e não substitui nenhuma das duas.
```

Por que o comando não sobe de modelo sozinho: `../conventions/skills-e-comandos.md`
§1 põe review de migration na linha `pesado`, e o corolário manda **isolar** o passo
pesado em vez de encarecer a automação inteira. O passo pesado é este — e ele é
disparado por gente, não pelo comando. Review de CSS continua barata.

## Para a IA

Não aprove por educação. Se houver item de Corretude, Camadas, Dados ou Segurança
aberto, o veredito é **Mudanças necessárias**, mesmo que o resto esteja bom.
