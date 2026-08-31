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
IDENTIDADE=''
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
      --identidade <ident>   fixa user.name/user.email locais nos repos que
                             ainda nao tem, no formato "Nome <email>". Sem
                             isto o script so avisa qual identidade os seus
                             commits levariam
      --ssh                  clona por SSH (padrao: https)
  -n, --simular              mostra o que faria, sem executar
  -h, --ajuda

o que ele faz, em ordem

  1. confere pre-requisitos (git, python, node, npm, docker, gh)
  2. clona os repos de repos.conf — ou atualiza os que ja existem
  3. confere a identidade que os commits de cada repo levariam
  4. backend:  .venv + pip install -e ".[dev]" + .env + pre-commit
  5. frontend: npm install (o husky se instala junto, via "prepare")
  6. instala os adaptadores de IA das ferramentas que voce escolheu

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
    --identidade)      IDENTIDADE="${2:?}";  shift 2 ;;
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

# formata segundos: 95 -> "1m35s"
desde() {
  local s=$(( SECONDS - $1 ))
  [ "$s" -ge 60 ] && echo "$((s/60))m$((s%60))s" || echo "${s}s"
}

# com_progresso <dir> <regex-do-que-vale-mostrar> <comando...>
#
# Instalar dependencia demora minutos; sem sinal de vida o dev nao sabe se
# travou. Roda o comando em segundo plano e vai imprimindo, conforme saem, so
# as linhas que dizem alguma coisa — mais um tique de tempo quando o comando
# fica quieto. Se falhar, mostra o fim da saida (o erro de verdade).
com_progresso() {
  local dir="$1" filtro="$2"; shift 2
  local log pid st novas n vistas=0 ultimo=0 t0=$SECONDS
  log="$(mktemp 2>/dev/null || echo "${TMPDIR:-/tmp}/creed-setup.$$.log")"

  ( cd "$dir" && "$@" ) >"$log" 2>&1 &
  pid=$!

  mostrar_novas() {
    novas="$(grep -aE "$filtro" "$log" 2>/dev/null | tail -n "+$((vistas+1))")"
    [ -n "$novas" ] || return 1
    n="$(printf '%s\n' "$novas" | wc -l)"
    printf '%s\n' "$novas" | cut -c1-96 | sed 's/^/         /'
    vistas=$((vistas + n))
    return 0
  }

  while kill -0 "$pid" 2>/dev/null; do
    sleep 2
    if mostrar_novas; then
      ultimo=$(( SECONDS - t0 ))
    elif [ $(( SECONDS - t0 - ultimo )) -ge 15 ]; then
      ultimo=$(( SECONDS - t0 ))
      printf '         · %ss…\n' "$ultimo"
    fi
  done

  wait "$pid"; st=$?
  mostrar_novas || true
  if [ "$st" -ne 0 ]; then
    echo "         ─ fim da saida ─"
    tail -n 20 "$log" | sed 's/^/         /'
  fi
  rm -f "$log"
  return "$st"
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

# Separa "Nome <email>" em IDENT_NOME e IDENT_EMAIL; 1 se o formato nao bate.
IDENT_NOME=''
IDENT_EMAIL=''
partir_identidade() {
  case "$1" in *'<'*'>'*) ;; *) return 1 ;; esac
  IDENT_NOME="$(echo "${1%%<*}" | xargs)"
  IDENT_EMAIL="$(echo "${1#*<}" | cut -d'>' -f1 | xargs)"
  [ -n "$IDENT_NOME" ] && [ -n "$IDENT_EMAIL" ]
}

# Sem user.name/user.email locais, o commit herda o config global — e estes
# repos sao publicos, entao e essa identidade que fica registrada la. Em varias
# maquinas do time o global e uma conta corporativa. O script nao adivinha qual
# voce quer: fixa a que veio em --identidade, ou mostra a que seria usada.
identidade_dos_repos() {
  local nome destino n_local e_local n_efet e_efet
  local pendentes=()

  # O harness tambem recebe commits (PR de harness) e tambem e publico, mas nao
  # esta no repos.conf — entra na lista na mao.
  local lista
  lista="$(printf 'creed-ai-context|%s
' "$HARNESS"; ler_repos | while IFS='|' read -r n _ pa _ _; do
    [ -n "$n" ] && printf '%s|%s
' "$n" "$WORKSPACE/$pa"
  done)"

  while IFS='|' read -r nome destino; do
    [ -n "$nome" ] || continue
    [ -d "$destino/.git" ] || continue

    n_local="$(git -C "$destino" config --local --get user.name  2>/dev/null || true)"
    e_local="$(git -C "$destino" config --local --get user.email 2>/dev/null || true)"

    if [ -n "$n_local" ] && [ -n "$e_local" ]; then
      passo "$nome — $n_local <$e_local>"
      continue
    fi

    if [ -n "$IDENTIDADE" ]; then
      rodar git -C "$destino" config user.name  "$IDENT_NOME"
      rodar git -C "$destino" config user.email "$IDENT_EMAIL"
      passo "$nome — fixada: $IDENT_NOME <$IDENT_EMAIL>"
      continue
    fi

    n_efet="$(git -C "$destino" config --get user.name  2>/dev/null || true)"
    e_efet="$(git -C "$destino" config --get user.email 2>/dev/null || true)"
    passo "$nome — sem identidade local; o commit sairia como ${n_efet:-?} <${e_efet:-?}>"
    pendentes+=("$nome")
  done <<< "$lista"

  [ ${#pendentes[@]} -gt 0 ] || return 0

  aviso "${#pendentes[@]} repo(s) sem identidade local — o commit leva o seu git config global, e estes repos sao publicos"
  echo "         para fixar nos que faltam:"
  echo "           bash creed-ai-context/scripts/setup-workspace.sh --sem-clone --sem-deps \\"
  echo "                --sem-adaptadores --identidade \"Fulano <fulano@users.noreply.github.com>\""
}

# --------------------------------------------------------- 1. pre-requisitos

if [ -n "$IDENTIDADE" ] && ! partir_identidade "$IDENTIDADE"; then
  echo "identidade fora do formato: $IDENTIDADE" >&2
  echo 'esperado: --identidade "Nome <email>"' >&2
  exit 1
fi

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

# ------------------------------------------------- 3. identidade dos commits

titulo "3. Identidade dos commits"
identidade_dos_repos

# ------------------------------------------------------------- 4. dependencias

if [ "$DEPS" = 1 ]; then
  BACK="$WORKSPACE/creed-backend"
  FRONT="$WORKSPACE/creed-frontend"

  if [ -f "$BACK/pyproject.toml" ]; then
    titulo "4. Backend" "(creed-backend)"
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
      passo "instalando dependencias (pacote a pacote, abaixo)…"
      t_pip=$SECONDS
      re_pip='Collecting |Building wheel|Installing collected|Successfully installed|Successfully built|^ERROR'
      PIP=(-m pip install --disable-pip-version-check --progress-bar off)
      # sem buffer, o pip sai linha a linha mesmo quando nao ha terminal do outro lado
      export PYTHONUNBUFFERED=1
      com_progresso "$BACK" "$re_pip" "$BIN/python" "${PIP[@]}" --upgrade pip \
        && com_progresso "$BACK" "$re_pip" "$BIN/python" "${PIP[@]}" -e ".[dev]"
      if [ $? -eq 0 ]; then
        passo "dependencias instaladas ($(desde $t_pip))"
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
    titulo "5. Front-end" "(creed-frontend)"
    if [ "$SIMULAR" = 1 ]; then
      passo "[simular] npm install"
    else
      passo "npm install (pode demorar)…"
      t_npm=$SECONDS
      if com_progresso "$FRONT" 'added |removed |changed |up to date|packages are looking|npm error' \
           npm install --no-fund; then
        passo "dependencias instaladas ($(desde $t_npm)) (husky junto, via \"prepare\")"
      else
        erro "npm install falhou — rode manualmente em creed-frontend"
      fi
    fi
  elif [ "$CLONE" = 1 ] && [ "$SIMULAR" = 0 ]; then
    aviso "creed-frontend nao encontrado — dependencias do front puladas"
  fi
fi

# --------------------------------------------------------- 6. adaptadores de IA

titulo "6. Ferramentas de IA"

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
  # --workspace: sem ele o instalador cai na pasta que contem o harness, que nem
  # sempre e o workspace escolhido aqui
  ARGS=(--ignorar "$IGNORAR" --workspace "$WORKSPACE")
  [ "$FERRAMENTAS" = '(preferencia salva)' ] || ARGS+=(-f "$FERRAMENTAS" --lembrar)
  [ "$SIMULAR" = 1 ] && ARGS+=(-n)
  bash "$SCRIPT_DIR/instalar-adaptadores.sh" "${ARGS[@]}" | sed 's/^/  /'
fi

# ------------------------------------------------------------------- 7. resumo

titulo "Pronto" "(em $(desde 0))"

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
