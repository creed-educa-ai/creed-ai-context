# Trabalhando com IA no CREED

Vale para **qualquer** modelo e ferramenta: Claude Code, Codex, Copilot, Cursor, chat
avulso. Se uma regra daqui conflita com o comportamento padrão da ferramenta, esta
ganha.

## 1. As seis regras

1. **Ler antes de escrever.** Domínio novo? Abra `app/domains/respondentes/` inteiro
   primeiro. Feature nova? `src/features/respondentes/`. Eles são o molde — copie a
   forma, não invente outra.
2. **Não inventar padrão.** Não documentado aqui e não existente no código = não é
   padrão. Pergunte ou registre premissa (`../conventions/premissas-e-duvidas.md`).
3. **Não versionar por conta própria.** IA implementa e revisa; `git add`/`commit`/
   `push`/PR é ação humana explícita. Comandos git de **leitura** (`status`, `diff`,
   `log`) são livres.
4. **Escopo é o que foi pedido.** Não refatorar de passagem, não subir dependência, não
   "aproveitar para arrumar". Achou problema fora do escopo? Anote no fim da resposta.
5. **O humano é o portão.** Nada entra em PR sem alguém do time ter lido o diff inteiro
   e rodado a suíte local. Ver `../checklists/definition-of-done.md`.
6. **Entender é parte da entrega.** A IA encerra explicando abordagem, alternativas
   descartadas e riscos (`../templates/entrega-didatica.md`), e **para** nas
   bifurcações de design para o humano decidir. Quem não sabe explicar o diff não
   abre o PR. Ver `aprendizado.md`.

## 2. Modo agente × modo copiloto

| | Modo agente | Modo copiloto |
|---|---|---|
| Ferramentas | Claude Code, Codex CLI, Copilot Agent, Cursor Agent | Copilot inline, chat avulso |
| Lê o repo | sim | só o que você colar |
| Escreve arquivo | sim | você aplica |
| Roda testes | sim | você roda |
| Decide nas bifurcações | **você** | **você** |
| Passos humanos obrigatórios | rodar suíte, ler diff, responder à defesa, abrir PR | idem |

Todo workflow deste harness declara o que muda entre os dois modos. Nenhum deles
dispensa os passos humanos — a diferença é só quem digita.

**No modo copiloto**, comece a sessão colando `../adaptadores/prompts/00-contexto.md`.
Sem isso o modelo não tem nada deste harness.

## 3. Diferenças entre ferramentas que importam na prática

| | Claude Code | Codex | Copilot | Cursor |
|---|---|---|---|---|
| Arquivo de entrada | `CLAUDE.md` | `AGENTS.md` | `.github/copilot-instructions.md` | `.cursor/rules/*.mdc` |
| Lê fora do repo aberto | sim (workspace) | sobe na árvore | **não confiável** | sim |
| Comandos prontos | slash commands | prompts colados | prompts colados | prompts colados |
| Onde falha primeiro | contexto longo demais | supõe estrutura genérica | ignora o que não está no repo | aplica edição ampla demais |

Consequência prática: **o adaptador do Copilot embute o essencial** em vez de só
apontar. Se você mudar um princípio inegociável, rode `instalar-adaptadores` de novo.

Os adaptadores são **seus**: você instala só as ferramentas que usa
(`instalar-adaptadores.sh -f codex --lembrar`) e nada disso é versionado — a regra de
ignore fica no `.git/info/exclude` do seu clone. Quem não usa IA não instala nada.
Depois de um pull que mude o harness, rode o instalador de novo; ele é idempotente.

## 4. Rastreabilidade

Na descrição do PR, uma linha:

```
IA: Claude Code (Opus) — spec, tasks e implementação · revisão humana: @fulano
IA: nenhuma
```

Não é burocracia nem culpa: é o que permite ao time saber, quando um bug aparecer,
se ele nasceu de um padrão mal entendido pelo modelo ou de uma decisão nossa. Nome
do modelo quando você souber; a ferramenta já basta quando não souber.

**Não** marque código com comentário `// gerado por IA`. O comentário envelhece no
primeiro edit humano e polui o arquivo; o PR é o lugar certo.

## 5. O que NUNCA vai para o modelo

- Credenciais, `.env` real, connection string, chave de API, token.
- Dado pessoal de respondente real. Fixture e seed usam dado sintético.
- Conteúdo confidencial da cliente que não esteja no repositório.

Se precisar colar um erro que contém segredo, mascare antes.

## 6. Quando o modelo erra

Padrão de erro que se repete = falha do harness, não do modelo. Abra PR corrigindo
o arquivo de contexto que faltou — é assim que este diretório melhora.
Ver `../CONTRIBUTING.md`.

## 7. Ao criar uma automação nova

Comando, skill, subagente ou workflow novo segue `../conventions/skills-e-comandos.md`:
modelo leve declarado no próprio arquivo (peso é exceção justificada) e passos
determinísticos — caminho literal, comando exato, critério explícito, saída em
template. Automação roda muitas vezes; prosa vaga aqui custa dez vezes.
