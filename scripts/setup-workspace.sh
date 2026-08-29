#!/usr/bin/env bash
# Setup completo do workspace CREED.ai Educa:
# pré-requisitos -> clone dos repos -> dependências -> adaptadores de IA.
#
#   bash creed-ai-context/scripts/setup-workspace.sh --ajuda
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS="$(cd "$SCRIPT_DIR/.." && pwd)"
CONF="$SCRIPT_DIR/repos.conf"

FERRAMENTAS=''
WORKSPACE=''
CLONE=1
DEPS=1
IGNORAR='local'
PROTOCOLO='https'
SIMULAR=0
FALHAS=0
AVISOS=()

ajuda() {
  cat <<'FIM'
uso: setup-workspace.sh [opcoes]

  -f, --ferramentas <lista>  adaptadores de IA: claude,codex,copilot,cursor,
                             "todas" ou "nenhuma". Padrao: pergunta ao final
                             o que fazer, ou usa .creed-ia.local se existir
      --workspace <caminho>  padrao: o diretorio que contem o creed-ai-context
      --sem-clone            nao clona nem atualiza repositorios
      --sem-deps             nao instala dependencias dos projetos
      --sem-adaptadores      atalho para -f nenhuma
      --ignorar <modo>       repassado ao instalar-adaptadores: local|repo|nao
      --ssh                  clona por SSH (padrao: https)
  -n, --simular              mostra o que faria, sem executar
  -h, --ajuda

o que ele faz, em ordem

  1. confere pre-requisitos (git, python, node, npm, docker, gh)
  2. clona os repos de repos.conf — ou atualiza os que ja existem
  3. backend:  .venv + pip install -e ".[dev]" + .env + pre-commit
  4. frontend: npm install (o husky se instala junto, via "prepare")
  5. instala os adaptadores de IA das ferramentas que voce escolheu

E seguro rodar de novo: nada e sobrescrito sem necessidade.

exemplos

  setup-workspace.sh -f codex           # workspace completo, adaptadores do Codex
  setup-workspace.sh -f nenhuma         # workspace completo, sem nada de IA
  setup-workspace.sh --sem-clone -f claude   # so dependencias e adaptadores
  setup-workspace.sh -n                 # so mostra o que faria
FIM
}

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--ferramentas)  FERRAMENTAS="${2:?}"; shift 2 ;;
    --workspace)       WORKSPACE="${2:?}";   shift 2 ;;
    --sem-clone)       CLONE=0;   shift ;;
    --sem-deps)        DEPS=0;    shift ;;
    --sem-adaptadores) FERRAMENTAS='nenhuma'; shift ;;
    --ignorar)         IGNORAR="${2:?}";     shift 2 ;;
    --ssh)             PROTOCOLO='ssh';      shift ;;
    -n|--simular)      SIMULAR=1; shift ;;
    -h|--ajuda)        ajuda; exit 0 ;;
    *) echo "opcao desconhecida: $1 (veja --ajuda)" >&2; exit 1 ;;
  esac
done

[ -n "$WORKSPACE" ] || WORKSPACE="$(cd "$HARNESS/.." && pwd)"
mkdir -p "$WORKSPACE" 2>/dev/null || true
WORKSPACE="$(cd "$WORKSPACE" && pwd)"

titulo() { echo; echo "── $1 ${2:-}"; }
passo()  { echo "  $1"; }
erro()   { echo "  ERRO   $1"; FALHAS=$((FALHAS+1)); }
aviso()  { echo "  aviso  $1"; AVISOS+=("$1"); }
rodar()  {
  if [ "$SIMULAR" = 1 ]; then echo "  [simular] $*"; return 0; fi
  "$@"
}

# ---------------------------------------------------------------- utilitarios

# maior_ou_igual <versao> <minima>  -> compara "20.11.0" com "20"
maior_ou_igual() {
  local v="$1" min="$2" a b
  a="$(echo "$v"  | cut -d. -f1)"; b="$(echo "$min" | cut -d. -f1)"
  [ "${a:-0}" -gt "${b:-0}" ] && return 0
  [ "${a:-0}" -lt "${b:-0}" ] && return 1
  a="$(echo "$v"  | cut -d. -f2)"; b="$(echo "$min" | cut -d. -f2)"
  [ "${a:-0}" -ge "${b:-0}" ]
}

# procura um python >= 3.12 e devolve o comando no stdout
achar_python() {
  local cmd v
  for cmd in "py -3.12" "python3.12" "python3" "python" "py -3"; do
    v="$($cmd -c 'import sys;print("%d.%d"%sys.version_info[:2])' 2>/dev/null)" || continue
    [ -n "$v" ] || continue
    if maior_ou_igual "$v" "3.12"; then echo "$cmd"; return 0; fi
  done
  return 1
}

# pasta de binarios do venv: Scripts no Windows, bin no resto
venv_bin() {
  [ -d "$1/Scripts" ] && { echo "$1/Scripts"; return; }
  echo "$1/bin"
}

url_repo() {
  if [ "$PROTOCOLO" = 'ssh' ]; then echo "git@github.com:$1.git"; else echo "https://github.com/$1.git"; fi
}

# le repos.conf ignorando comentarios e linhas vazias
ler_repos() {
  grep -vE '^[[:space:]]*(#|$)' "$CONF" | while IFS='|' read -r nome slug pasta branch tipo; do
    echo "$(echo "$nome"|xargs)|$(echo "$slug"|xargs)|$(echo "$pasta"|xargs)|$(echo "$branch"|xargs)|$(echo "$tipo"|xargs)"
  done
}

# --------------------------------------------------------- 1. pre-requisitos

echo "CREED.ai Educa — setup do workspace"
echo "workspace: $WORKSPACE"
[ "$SIMULAR" = 1 ] && echo "modo:      simulacao (nada e executado)"

titulo "1. Pré-requisitos"

if command -v git >/dev/null 2>&1; then
  passo "git      $(git --version | awk '{print $3}')"
else
  erro "git nao encontrado — https://git-scm.com/downloads"
fi

PY="$(achar_python || true)"
if [ -n "$PY" ]; then
  passo "python   $($PY -c 'import sys;print("%d.%d.%d"%sys.version_info[:3])') ($PY)"
  PY_V="$($PY -c 'import sys;print("%d.%d"%sys.version_info[:2])')"
  maior_ou_igual "$PY_V" "3.14" && \
    aviso "python $PY_V e mais novo que o alvo do projeto (3.12) — se algum pacote nao tiver wheel, use 3.12"
else
  erro "python 3.12+ nao encontrado (backend exige >=3.12)"
  echo "         Windows: winget install Python.Python.3.12"
  echo "         Linux:   sudo apt install python3.12 python3.12-venv"
  echo "         macOS:   brew install python@3.12"
fi

if command -v node >/dev/null 2>&1; then
  NODE_V="$(node -v | tr -d 'v')"
  if maior_ou_igual "$NODE_V" "20"; then passo "node     $NODE_V"
  else aviso "node $NODE_V — o front pede 20+; atualize se der problema no build"; fi
else
  erro "node nao encontrado (front) — https://nodejs.org (LTS 20+)"
fi

command -v npm >/dev/null 2>&1 && passo "npm      $(npm -v)" || erro "npm nao encontrado (vem com o node)"

if command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    passo "docker   $(docker --version | sed 's/Docker version //; s/,.*//') (compose ok)"
  else
    aviso "docker sem 'compose' — o banco local sobe com 'docker compose up -d db'"
  fi
else
  aviso "docker nao encontrado — sem ele nao ha banco local nem teste de repository"
fi

command -v gh >/dev/null 2>&1 && passo "gh       $(gh --version | head -1 | awk '{print $3}')" \
                              || aviso "gh nao encontrado (opcional — abrir PR pelo terminal)"

if [ "$FALHAS" -gt 0 ]; then
  echo
  echo "Faltam $FALHAS pre-requisito(s) obrigatorio(s). Instale e rode de novo."
  exit 1
fi

# ------------------------------------------------------------ 2. repositorios

if [ "$CLONE" = 1 ]; then
  titulo "2. Repositórios"
  [ -f "$CONF" ] || { erro "repos.conf nao encontrado em $CONF"; exit 1; }

  while IFS='|' read -r nome slug pasta branch tipo; do
    [ -n "$nome" ] || continue
    destino="$WORKSPACE/$pasta"
    url="$(url_repo "$slug")"

    if [ -d "$destino/.git" ]; then
      atual="$(git -C "$destino" rev-parse --abbrev-ref HEAD 2>/dev/null)"
      sujo="$(git -C "$destino" status --porcelain 2>/dev/null | head -1)"
      if [ -n "$sujo" ]; then
        passo "$nome — ja existe (branch $atual, com alteracoes locais; nao mexi)"
      else
        if rodar git -C "$destino" pull --ff-only >/dev/null 2>&1; then
          passo "$nome — atualizado (branch $atual)"
        else
          passo "$nome — ja existe (branch $atual; pull nao foi fast-forward, nao mexi)"
        fi
      fi
      continue
    fi

    passo "$nome — clonando…"
    if ! rodar git clone --quiet "$url" "$destino"; then
      erro "$nome — falha no clone de $url"
      continue
    fi
    [ "$SIMULAR" = 1 ] && continue

    if git -C "$destino" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      git -C "$destino" checkout --quiet "$branch"
      passo "$nome — na branch $branch"
    else
      padrao="$(git -C "$destino" rev-parse --abbrev-ref HEAD)"
      aviso "$nome — branch '$branch' ainda nao existe no remoto; ficou em '$padrao'"
    fi
  done <<< "$(ler_repos)"
fi

# ------------------------------------------------------------- 3. dependencias

if [ "$DEPS" = 1 ]; then
  BACK="$WORKSPACE/creed-backend"
  FRONT="$WORKSPACE/creed-frontend"

  if [ -f "$BACK/pyproject.toml" ]; then
    titulo "3. Backend" "(creed-backend)"
    VENV="$BACK/.venv"
    if [ -d "$VENV" ]; then
      passo ".venv ja existe"
    else
      passo "criando .venv…"
      rodar $PY -m venv "$VENV" || erro "falha ao criar o .venv"
    fi
    BIN="$(venv_bin "$VENV")"

    if [ "$SIMULAR" = 1 ]; then
      passo "[simular] pip install -e \".[dev]\""
    elif [ -x "$BIN/python" ] || [ -x "$BIN/python.exe" ]; then
      passo "instalando dependencias (pode demorar)…"
      saida="$( cd "$BACK" \
                && "$BIN/python" -m pip install --quiet --upgrade pip 2>&1 \
                && "$BIN/python" -m pip install --quiet -e ".[dev]" 2>&1 )"
      status=$?
      # o filtro tira so o ruido conhecido do cache do pip; erro real continua visivel
      echo "$saida" | grep -v 'Cache entry deserialization failed, entry ignored' \
                    | sed '/^[[:space:]]*$/d; s/^/         /'
      if [ "$status" -eq 0 ]; then
        passo "dependencias instaladas"
      else
        erro "pip install falhou — rode manualmente em creed-backend"
      fi
    fi

    if [ -f "$BACK/.env" ]; then
      passo ".env ja existe"
    elif [ -f "$BACK/.env.example" ]; then
      rodar cp "$BACK/.env.example" "$BACK/.env" && passo ".env criado a partir do .env.example"
    else
      aviso "sem .env.example no backend"
    fi

    if [ "$SIMULAR" = 1 ]; then
      passo "[simular] pre-commit install --hook-type pre-commit --hook-type pre-push"
    elif [ -x "$BIN/pre-commit" ] || [ -x "$BIN/pre-commit.exe" ]; then
      if ( cd "$BACK" && "$BIN/pre-commit" install --hook-type pre-commit --hook-type pre-push >/dev/null 2>&1 ); then
        passo "hooks de pre-commit e pre-push instalados"
      else
        aviso "pre-commit install falhou — o check de nome de branch so aparecera no PR"
      fi
    fi
  elif [ "$CLONE" = 1 ] && [ "$SIMULAR" = 0 ]; then
    aviso "creed-backend nao encontrado — dependencias do backend puladas"
  fi

  if [ -f "$FRONT/package.json" ]; then
    titulo "4. Front-end" "(creed-frontend)"
    if [ "$SIMULAR" = 1 ]; then
      passo "[simular] npm install"
    else
      passo "npm install (pode demorar)…"
      if ( cd "$FRONT" && npm install --silent ); then
        passo "dependencias instaladas (husky junto, via \"prepare\")"
      else
        erro "npm install falhou — rode manualmente em creed-frontend"
      fi
    fi
  elif [ "$CLONE" = 1 ] && [ "$SIMULAR" = 0 ]; then
    aviso "creed-frontend nao encontrado — dependencias do front puladas"
  fi
fi

# --------------------------------------------------------- 4. adaptadores de IA

titulo "5. Ferramentas de IA"

if [ -z "$FERRAMENTAS" ] && [ -f "$WORKSPACE/.creed-ia.local" ]; then
  FERRAMENTAS='(preferencia salva)'
fi

if [ "$FERRAMENTAS" = 'nenhuma' ]; then
  passo "nenhum adaptador instalado (--sem-adaptadores)"
  passo "quando quiser: bash creed-ai-context/scripts/instalar-adaptadores.sh -f <ferramenta>"
elif [ -z "$FERRAMENTAS" ]; then
  passo "voce nao passou -f, entao nada de IA foi instalado."
  passo "escolha a sua e rode:"
  echo "         bash creed-ai-context/scripts/instalar-adaptadores.sh -f codex --lembrar"
  echo "         (opcoes: claude, codex, copilot, cursor, todas)"
else
  ARGS=(--ignorar "$IGNORAR")
  [ "$FERRAMENTAS" = '(preferencia salva)' ] || ARGS+=(-f "$FERRAMENTAS" --lembrar)
  [ "$SIMULAR" = 1 ] && ARGS+=(-n)
  bash "$SCRIPT_DIR/instalar-adaptadores.sh" "${ARGS[@]}" | sed 's/^/  /'
fi

# ------------------------------------------------------------------- 5. resumo

titulo "Pronto"

if [ ${#AVISOS[@]} -gt 0 ]; then
  echo
  echo "  Avisos:"
  for a in "${AVISOS[@]}"; do echo "   · $a"; done
fi

cat <<FIM

  Backend
    cd $WORKSPACE/creed-backend
    docker compose up -d db
    source .venv/bin/activate      # Windows: .venv\Scripts\activate
    alembic upgrade head
    uvicorn app.main:app --reload          # docs em http://localhost:8000/api/v1/docs

  Front-end
    cd $WORKSPACE/creed-frontend
    npm run dev                            # faz proxy de /api para o backend

  Antes do primeiro PR
    leia creed-backend/CONTRIBUTING.md (branch, commit, PR — o GitHub cobra)
    leia creed-ai-context/CONTEXT.md   (padroes do projeto e como a IA trabalha aqui)
FIM

[ "$FALHAS" -gt 0 ] && exit 1
exit 0
