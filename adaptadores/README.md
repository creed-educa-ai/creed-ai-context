# adaptadores/

**Nada normativo mora aqui.** Cada arquivo é um ponteiro para `creed-ai-context/`,
escrito no formato que uma ferramenta específica lê.

| Fonte | Vira | Lido por |
|---|---|---|
| `CLAUDE.md` | `<workspace>/CLAUDE.md` e `<repo>/CLAUDE.md` | Claude Code |
| `AGENTS.md` | `<workspace>/AGENTS.md` e `<repo>/AGENTS.md` | Codex, Cursor, Jules, Amp |
| `copilot-instructions.md` | `<repo>/.github/copilot-instructions.md` | GitHub Copilot |
| `cursor-rules.mdc` | `<repo>/.cursor/rules/creed.mdc` | Cursor |
| `claude/commands/*.md` | `<workspace>/.claude/commands/` | slash commands do Claude Code |
| `prompts/*.md` | nada — são para copiar e colar | qualquer chat |

Gerar (só as suas ferramentas): `bash ../scripts/instalar-adaptadores.sh -f codex --lembrar`

## Regras

1. **Editou aqui → rode o script.** Editar o arquivo gerado é perda de tempo: o
   próximo `instalar-adaptadores` sobrescreve.
2. **Adaptador não inventa regra.** Se você está prestes a escrever um padrão aqui,
   ele pertence a `context/` ou `conventions/`.
3. **Exceção única:** o adaptador do Copilot **duplica** os princípios inegociáveis,
   porque o Copilot não lê arquivo fora do repositório de forma confiável. É
   duplicação gerada, não escrita à mão — e está registrada no ADR-0001.
4. **O que é gerado é pessoal e local.** Cada pessoa instala as ferramentas que usa; o
   script mantém a regra de ignore em `.git/info/exclude`, então nada disso sobe para
   os repos. Ferramenta não selecionada tem o adaptador removido, para não ficar
   arquivo velho apontando padrão antigo.
5. **Toda saída deste diretório carrega a marca `GERADO por`** na primeira linha (ou
   logo após o frontmatter). É por ela que o script sabe o que pode apagar — não
   remova a marca ao editar o adaptador-fonte.
6. **Comando novo segue `../conventions/skills-e-comandos.md`:** modelo leve declarado
   no frontmatter e passos determinísticos. O comando é ponteiro fino — a regra mora
   no harness.
