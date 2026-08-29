# Checklist de PR

## Antes de abrir

- [ ] Branch no padrão `<slug>/<id-clickup>-<contexto>` 🔒
- [ ] Alvo é `dev` (só release/hotfix vai para `main`)
- [ ] `git diff dev...HEAD` lido **inteiro** pelo autor
- [ ] Suíte local verde
- [ ] Nada fora do escopo da tarefa no diff

## Descrição

```markdown
## O que muda
<uma frase>

## Por quê
<motivo — a tarefa do ClickUp não substitui isto>

## Como verificar
1. <passo>
2. <passo>

## Premissas
- 🟡 P-007 — <interpretação adotada>   (ou "nenhuma")

## Migration
- <arquivo> — revisado linha a linha por @fulano   (ou "nenhuma")

IA: <ferramenta/modelo> — <o que fez> · revisão humana: @fulano
Tarefa: <link ClickUp>
```

## Para mergear 🔒

1 aprovação de outra pessoa · CI `qualidade` verde · check `nome-da-branch` verde ·
conversas resolvidas. Commit novo depois da aprovação **descarta** a aprovação.
