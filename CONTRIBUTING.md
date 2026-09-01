# Contribuindo com o creed-ai-context

Este diretório é **lido por modelos que geram código**. Uma frase ambígua aqui vira
um padrão errado replicado por três ferramentas diferentes. Trate com o mesmo rigor
do código.

## Princípios

1. **Toda mudança via PR**, como qualquer código do projeto.
2. **Mudança tem motivo.** O PR explica o "por quê" — normalmente: um modelo errou, e
   errou porque isto aqui não estava escrito.
3. **Conteúdo normativo só no harness.** Se você está escrevendo uma regra dentro de
   `adaptadores/`, ela está no lugar errado.
4. **Decisão grande vira ADR** (`decisoes/adrs/`, template em `templates/adr-template.md`).

## O gatilho mais comum

Modelo errou o mesmo padrão duas vezes = **falha do harness**, não do modelo. O PR
certo não é "avisar no grupo": é o arquivo de contexto que faltava.

## Onde cada coisa mora

| Você quer documentar | Vai em |
|---|---|
| Como o sistema é | `context/` |
| Como se escreve/nomeia/versiona | `conventions/` |
| O que conferir antes de dar por pronto | `checklists/` |
| Passo a passo de uma tarefa técnica recorrente | `playbooks/` |
| Sequência do pipeline (entrada → saída) | `workflows/` |
| Postura de um papel | `roles/` |
| Formato de um artefato | `templates/` |
| Automação nova (comando, skill, subagente) | `conventions/skills-e-comandos.md` — leia antes |
| Repo novo no workspace | `scripts/repos.conf` |
| Decisão com trade-off | `decisoes/adrs/` |
| Interpretação de produto sem a cliente | `decisoes/premissas.md` |

Na dúvida entre `conventions/` e `playbooks/`: convenção é **regra** ("migration
revisada linha a linha"); playbook é **sequência** ("gere, leia, aplique, rode heads").

## Ao mexer em `adaptadores/`

Os arquivos gerados **não são versionados** — são pessoais e locais (ver o README).
Então o PR carrega só a mudança no adaptador-fonte, nunca a saída dele.

O que muda é o aviso: quem já tinha instalado precisa **regenerar** para receber a
mudança. Escreva isso na descrição do PR:

```
Quem usa IA: rode de novo o instalador depois de puxar isto.
  bash creed-ai-context/scripts/instalar-adaptadores.sh
```

Sem o argumento `-f`, o script reusa a preferência gravada em `.creed-ia.local` — cada
pessoa recebe só o que usa.

Ao editar um adaptador, **preserve a linha `GERADO por`**: é a marca que autoriza o
script a sobrescrever e a remover o arquivo. Sem ela, o instalador passa a tratar a
saída como arquivo do usuário e deixa de limpá-la.

## Estilo

- **Português.** É a língua do time e do domínio.
- **Frase curta e afirmativa.** "Router não tem regra de negócio" — não "recomenda-se
  evitar".
- **Exemplo concreto vale mais que princípio abstrato.** Prefira a tabela de "erros que
  este playbook existe para evitar" a um parágrafo sobre separação de responsabilidades.
- **Diga o sinal, não só a regra.** "Sinal de que a camada furou: `router.py`
  importando `models`."
- **Não escreva o que o código já diz.** Harness que repete a estrutura de pastas
  envelhece; harness que explica *por que* ela é assim, não.

## Antes de abrir o PR

- [ ] Links internos funcionam.
- [ ] Nada de credencial, token ou dado pessoal real.
- [ ] Mexeu em `adaptadores/`? O PR avisa quem usa IA para regenerar — e NÃO inclui a
      saída gerada.
- [ ] A regra nova não contradiz `CONTEXT.md` nem os ADRs — e se contradiz de
      propósito, o PR muda os dois.

## Commit

Conventional Commits, como nos repos de código:

```
docs(harness): registrar premissa sobre respondentes inativos
feat(harness): adicionar playbook de criação de feature no front
fix(harness): corrigir comando de teste do backend no prompt 03
```
