#!/usr/bin/env bash
# Instala os arquivos de entrada das ferramentas de IA a partir de
# creed-ai-context/adaptadores/ — só das ferramentas que VOCÊ usa.
#
#   bash creed-ai-context/scripts/instalar-adaptadores.sh --ajuda
#
set -euo pipefail

HARNESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS="$(cd "$HARNESS/.." && pwd)"
ADP="$HARNESS/adaptadores"
CONFIG="$WS/.creed-ia.local"
MARCA='GERADO por'
BLOCO_INI='# >>> creed-ai-context: adaptadores de IA (gerados, locais) >>>'
BLOCO_FIM='# <<< creed-ai-context <<<'

TODOS_REPOS=(creed-backend creed-frontend creed-infrastructure)
TODAS_FERRAMENTAS=(claude codex copilot cursor)

ajuda() {
  cat <<'FIM'
uso: instalar-adaptadores.sh [opcoes]

  -f, --ferramentas <lista>  claude,codex,copilot,cursor  (ou "todas")
                             padrao: $CREED_IA_FERRAMENTAS, senao .creed-ia.local,
                             senao "todas"
  -r, --repos <lista>        padrao: todos os repos presentes no workspace
      --workspace <caminho>  onde escrever os adaptadores
                             padrao: a pasta que contem o creed-ai-context
      --sem-raiz             nao escreve na raiz do workspace
      --ignorar <modo>       local (padrao) | repo | nao
                               local -> .git/info/exclude de cada repo (nao sobe)
                               repo  -> .gitignore do repo (versionado, decisao de time)
                               nao   -> nao mexe em ignore
      --lembrar              grava a escolha de ferramentas em .creed-ia.local
      --remover              remove os adaptadores gerados (e o bloco de ignore) e sai
  -n, --simular              mostra o que faria, sem escrever
  -h, --ajuda

ferramenta -> arquivos que ela le

  claude   <raiz>/CLAUDE.md · <raiz>/.claude/commands/*.md · <repo>/CLAUDE.md
  codex    <raiz>/AGENTS.md · <repo>/AGENTS.md
  copilot  <repo>/.github/copilot-instructions.md
  cursor   <repo>/.cursor/rules/creed.mdc

Adaptador de ferramenta NAO selecionada e removido, desde que carregue a marca
"GERADO por" — trocar de ferramenta nao deixa arquivo velho para tras.

exemplos

  # so o Codex, ignorado localmente (nao sobe para os repos)
  instalar-adaptadores.sh -f codex --lembrar

  # Claude Code + Copilot, so no backend
  instalar-adaptadores.sh -f claude,copilot -r creed-backend

  # o time decidiu versionar: escreve tudo e poe a regra no .gitignore
  instalar-adaptadores.sh -f todas --ignorar repo

  # limpar
  instalar-adaptadores.sh --remover
FIM
}

FERRAMENTAS=''
REPOS_ARG=''
WORKSPACE_ARG=''
RAIZ=1
IGNORAR='local'
LEMBRAR=0
REMOVER=0
SIMULAR=0

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--ferramentas) FERRAMENTAS="${2:?lista de ferramentas}"; shift 2 ;;
    -r|--repos)       REPOS_ARG="${2:?lista de repos}";         shift 2 ;;
    --workspace)      WORKSPACE_ARG="${2:?caminho do workspace}"; shift 2 ;;
    --sem-raiz)       RAIZ=0;      shift ;;
    --ignorar)        IGNORAR="${2:?local|repo|nao}";           shift 2 ;;
    --lembrar)        LEMBRAR=1;   shift ;;
    --remover)        REMOVER=1;   shift ;;
    -n|--simular)     SIMULAR=1;   shift ;;
    -h|--ajuda)       ajuda; exit 0 ;;
    *) echo "opcao desconhecida: $1" >&2; echo "veja --ajuda" >&2; exit 1 ;;
  esac
done

case "$IGNORAR" in
  local|repo|nao) ;;
  *) echo "--ignorar aceita: local | repo | nao" >&2; exit 1 ;;
esac

# o padrao (a pasta que contem o harness) so vale quando ninguem disse outra coisa
if [ -n "$WORKSPACE_ARG" ]; then
  WS="$(cd "$WORKSPACE_ARG" 2>/dev/null && pwd)" \
    || { echo "workspace nao encontrado: $WORKSPACE_ARG" >&2; exit 1; }
  CONFIG="$WS/.creed-ia.local"
fi

# ferramentas: argumento > variavel de ambiente > arquivo local > todas
if [ -z "$FERRAMENTAS" ]; then
  FERRAMENTAS="${CREED_IA_FERRAMENTAS:-}"
fi
if [ -z "$FERRAMENTAS" ] && [ -f "$CONFIG" ]; then
  FERRAMENTAS="$(grep -E '^ferramentas=' "$CONFIG" | tail -1 | cut -d= -f2- | tr -d '[:space:]')"
fi
[ -n "$FERRAMENTAS" ] || FERRAMENTAS='todas'
[ "$FERRAMENTAS" = 'todas' ] && FERRAMENTAS="$(IFS=,; echo "${TODAS_FERRAMENTAS[*]}")"

IFS=',' read -r -a SEL <<< "$FERRAMENTAS"
for f in "${SEL[@]}"; do
  case "$f" in
    claude|codex|copilot|cursor) ;;
    *) echo "ferramenta desconhecida: $f (use claude, codex, copilot, cursor ou todas)" >&2; exit 1 ;;
  esac
done

if [ -n "$REPOS_ARG" ]; then
  IFS=',' read -r -a REPOS <<< "$REPOS_ARG"
else
  REPOS=("${TODOS_REPOS[@]}")
fi

selecionada() {
  local alvo="$1" f
  for f in "${SEL[@]}"; do [ "$f" = "$alvo" ] && return 0; done
  return 1
}

rel() { echo "${1#$WS/}"; }

gerado() { [ -f "$1" ] && head -8 "$1" | grep -q "$MARCA"; }

# escrever <origem> <destino> [prefixo]
# O prefixo reescreve "creed-ai-context/" para "<prefixo>creed-ai-context/": dentro de
# um repo o harness fica um nivel acima da raiz onde a ferramenta trabalha.
escrever() {
  local origem="$1" destino="$2" prefixo="${3:-}"
  if [ "$SIMULAR" = 1 ]; then echo "  [simular] escrever  $(rel "$destino")"; return; fi
  mkdir -p "$(dirname "$destino")"
  if [ -z "$prefixo" ]; then
    cp "$origem" "$destino"
  else
    sed -e "s#@creed-ai-context/#@${prefixo}creed-ai-context/#g" \
        -e "s#\`creed-ai-context/#\`${prefixo}creed-ai-context/#g" \
        -e "s#\*\*\`*creed-ai-context/#**\`${prefixo}creed-ai-context/#g" \
        -e "s# creed-ai-context/# ${prefixo}creed-ai-context/#g" "$origem" > "$destino"
  fi
  echo "  ok        $(rel "$destino")"
}

# remove o destino apenas se ele for arquivo gerado por este script
descartar() {
  local destino="$1"
  gerado "$destino" || return 0
  if [ "$SIMULAR" = 1 ]; then echo "  [simular] remover   $(rel "$destino")"; return; fi
  rm -f "$destino"
  echo "  removido  $(rel "$destino")"
  rmdir -p "$(dirname "$destino")" 2>/dev/null || true
}

# bloco idempotente de ignore, em .git/info/exclude (local) ou .gitignore (versionado)
ignorar_bloco() {
  local repo_dir="$1" modo="$2" alvo tmp rotulo
  case "$modo" in
    local)
      local gitdir
      gitdir="$(git -C "$repo_dir" rev-parse --absolute-git-dir 2>/dev/null || true)"
      [ -n "$gitdir" ] || { echo "  aviso     $(rel "$repo_dir") nao e repo git — ignore pulado"; return; }
      mkdir -p "$gitdir/info"; alvo="$gitdir/info/exclude"; rotulo="$(basename "$repo_dir")/.git/info/exclude" ;;
    repo)  alvo="$repo_dir/.gitignore"; rotulo="$(basename "$repo_dir")/.gitignore" ;;
    nao)   return ;;
  esac

  if [ "$SIMULAR" = 1 ]; then echo "  [simular] ignorar   $rotulo"; return; fi

  tmp="$(mktemp)"
  if [ -f "$alvo" ]; then
    awk -v ini="$BLOCO_INI" -v fim="$BLOCO_FIM" '
      $0==ini {dentro=1; next} $0==fim {dentro=0; next} !dentro' "$alvo" > "$tmp"
  fi
  {
    [ -s "$tmp" ] && cat "$tmp"
    echo "$BLOCO_INI"
    echo "/CLAUDE.md"
    echo "/AGENTS.md"
    echo "/.github/copilot-instructions.md"
    echo "/.cursor/"
    echo "$BLOCO_FIM"
  } > "$alvo"
  rm -f "$tmp"
  echo "  ignore    $rotulo"
}

limpar_ignore() {
  local repo_dir="$1" alvo gitdir tmp rotulo
  gitdir="$(git -C "$repo_dir" rev-parse --absolute-git-dir 2>/dev/null || true)"
  for alvo in "${gitdir:+$gitdir/info/exclude}" "$repo_dir/.gitignore"; do
    [ -f "$alvo" ] || continue
    grep -qF "$BLOCO_INI" "$alvo" || continue
    case "$alvo" in
      *.gitignore) rotulo="$(basename "$repo_dir")/.gitignore" ;;
      *)           rotulo="$(basename "$repo_dir")/.git/info/exclude" ;;
    esac
    if [ "$SIMULAR" = 1 ]; then echo "  [simular] ignore-   $rotulo"; continue; fi
    tmp="$(mktemp)"
    awk -v ini="$BLOCO_INI" -v fim="$BLOCO_FIM" '
      $0==ini {dentro=1; next} $0==fim {dentro=0; next} !dentro' "$alvo" > "$tmp"
    mv "$tmp" "$alvo"
    echo "  ignore-   $rotulo"
  done
}

echo "workspace:   $WS"
if [ "$REMOVER" = 1 ]; then
  echo "acao:        remover adaptadores gerados"
else
  echo "ferramentas: $(IFS=,; echo "${SEL[*]}")"
  echo "ignore:      $IGNORAR"
  [ "$SIMULAR" = 1 ] && echo "modo:        simulacao (nada e escrito)"
fi

# ---------- raiz do workspace ----------
if [ "$RAIZ" = 1 ]; then
  echo
  echo "raiz do workspace"
  if [ "$REMOVER" = 1 ] || ! selecionada claude; then
    descartar "$WS/CLAUDE.md"
    for cmd in "$ADP/claude/commands"/*.md; do descartar "$WS/.claude/commands/$(basename "$cmd")"; done
  else
    escrever "$ADP/CLAUDE.md" "$WS/CLAUDE.md"
    for cmd in "$ADP/claude/commands"/*.md; do
      escrever "$cmd" "$WS/.claude/commands/$(basename "$cmd")"
    done
  fi
  if [ "$REMOVER" = 1 ] || ! selecionada codex; then
    descartar "$WS/AGENTS.md"
  else
    escrever "$ADP/AGENTS.md" "$WS/AGENTS.md"
  fi
fi

# ---------- repos ----------
for repo in "${REPOS[@]}"; do
  dir="$WS/$repo"
  [ -d "$dir" ] || { echo; echo "$repo — ausente, pulando"; continue; }
  echo
  echo "$repo"

  if [ "$REMOVER" = 1 ] || ! selecionada claude; then descartar "$dir/CLAUDE.md"
  else escrever "$ADP/CLAUDE.md" "$dir/CLAUDE.md" "../"; fi

  if [ "$REMOVER" = 1 ] || ! selecionada codex; then descartar "$dir/AGENTS.md"
  else escrever "$ADP/AGENTS.md" "$dir/AGENTS.md" "../"; fi

  if [ "$REMOVER" = 1 ] || ! selecionada copilot; then descartar "$dir/.github/copilot-instructions.md"
  else escrever "$ADP/copilot-instructions.md" "$dir/.github/copilot-instructions.md" "../"; fi

  if [ "$REMOVER" = 1 ] || ! selecionada cursor; then descartar "$dir/.cursor/rules/creed.mdc"
  else escrever "$ADP/cursor-rules.mdc" "$dir/.cursor/rules/creed.mdc" "../"; fi

  if [ "$REMOVER" = 1 ]; then limpar_ignore "$dir"; else ignorar_bloco "$dir" "$IGNORAR"; fi
done

# ---------- preferencia ----------
if [ "$LEMBRAR" = 1 ] && [ "$REMOVER" = 0 ] && [ "$SIMULAR" = 0 ]; then
  printf '# preferencia local de ferramentas de IA — nao versionado\nferramentas=%s\n' \
    "$(IFS=,; echo "${SEL[*]}")" > "$CONFIG"
  echo
  echo "preferencia gravada em $(rel "$CONFIG") — proximas execucoes usam ela sem -f"
fi

echo
if [ "$REMOVER" = 1 ]; then
  echo "Removido. Nada do harness em si foi apagado — so os arquivos gerados."
  exit 0
fi

cat <<'FIM'
Pronto.

Os arquivos acima sao GERADOS — nao edite nenhum deles. Mudanca de conteudo vai em
creed-ai-context/adaptadores/ e este script roda de novo.

Dentro dos repos os caminhos apontam ../creed-ai-context/, para o adaptador funcionar
tambem com o repo aberto sozinho.
FIM

case "$IGNORAR" in
  local) echo
         echo "Ignore em .git/info/exclude: vale so no SEU clone e nao sobe para o repo."
         echo "Cada pessoa roda o script com as proprias ferramentas; ninguem ve as dos outros." ;;
  repo)  echo
         echo "Ignore no .gitignore: e um arquivo VERSIONADO — a regra sobe para o repo."
         echo "So use este modo se o time decidiu isso em conjunto." ;;
  nao)   echo
         echo "Nenhuma regra de ignore aplicada: os adaptadores aparecem no git status." ;;
esac
