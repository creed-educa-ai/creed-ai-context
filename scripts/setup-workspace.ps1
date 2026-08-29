<#
.SYNOPSIS
Setup completo do workspace CREED.ai Educa:
pre-requisitos -> clone dos repos -> dependencias -> adaptadores de IA.

.DESCRIPTION
1. confere pre-requisitos (git, python, node, npm, docker, gh)
2. clona os repos de repos.conf - ou atualiza os que ja existem
3. backend:  .venv + pip install -e ".[dev]" + .env + pre-commit
4. frontend: npm install (o husky se instala junto, via "prepare")
5. instala os adaptadores de IA das ferramentas escolhidas

E seguro rodar de novo: nada e sobrescrito sem necessidade.

.PARAMETER Ferramentas
Adaptadores de IA: claude, codex, copilot, cursor, "todas" ou "nenhuma".
Sem este parametro, o script nao instala nada de IA e diz como fazer depois.

.PARAMETER Workspace
Padrao: o diretorio que contem o creed-ai-context.

.PARAMETER SemClone
Nao clona nem atualiza repositorios.

.PARAMETER SemDeps
Nao instala dependencias dos projetos.

.PARAMETER SemAdaptadores
Atalho para -Ferramentas nenhuma.

.PARAMETER Ignorar
Repassado ao instalar-adaptadores: local (padrao) | repo | nao.

.PARAMETER Ssh
Clona por SSH (padrao: https).

.PARAMETER Simular
Mostra o que faria, sem executar.

.EXAMPLE
.\setup-workspace.ps1 -Ferramentas codex

.EXAMPLE
.\setup-workspace.ps1 -SemClone -Ferramentas claude
#>
[CmdletBinding()]
param(
    [Alias('f')][string[]] $Ferramentas,
    [string] $Workspace,
    [switch] $SemClone,
    [switch] $SemDeps,
    [switch] $SemAdaptadores,
    [ValidateSet('local', 'repo', 'nao')][string] $Ignorar = 'local',
    [switch] $Ssh,
    [Alias('n')][switch] $Simular
)

$ErrorActionPreference = 'Continue'

$ScriptDir = $PSScriptRoot
$Harness   = Split-Path -Parent $ScriptDir
$Conf      = Join-Path $ScriptDir 'repos.conf'
if ($SemAdaptadores) { $Ferramentas = @('nenhuma') }
if (-not $Workspace) { $Workspace = Split-Path -Parent $Harness }
if (-not (Test-Path $Workspace)) { New-Item -ItemType Directory -Force -Path $Workspace | Out-Null }
$Workspace = (Resolve-Path $Workspace).Path

$script:Falhas = 0
$script:Avisos = @()

function Titulo($t)  { Write-Host ''; Write-Host "-- $t" }
function Passo($t)   { Write-Host "  $t" }
function Erro($t)    { Write-Host "  ERRO   $t"; $script:Falhas++ }
function Aviso($t)   { Write-Host "  aviso  $t"; $script:Avisos += $t }

# MaiorOuIgual "20.11.0" "20"
function MaiorOuIgual($Versao, $Minima) {
    $a = ($Versao -split '\.'); $b = ($Minima -split '\.')
    for ($i = 0; $i -lt $b.Count; $i++) {
        $x = 0; $y = 0
        [void][int]::TryParse(($a[$i] -replace '\D.*', ''), [ref]$x)
        [void][int]::TryParse($b[$i], [ref]$y)
        if ($x -gt $y) { return $true }
        if ($x -lt $y) { return $false }
    }
    return $true
}

# devolve o comando de um python >= 3.12, ou $null
function AcharPython {
    $tentativas = @(
        @{ Exe = 'py';      Args = @('-3.12') },
        @{ Exe = 'python';  Args = @() },
        @{ Exe = 'python3'; Args = @() },
        @{ Exe = 'py';      Args = @('-3') }
    )
    foreach ($t in $tentativas) {
        if (-not (Get-Command $t.Exe -ErrorAction SilentlyContinue)) { continue }
        $v = & $t.Exe @($t.Args + @('-c', 'import sys;print(sys.version_info[0],sys.version_info[1],sep=chr(46))')) 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $v) { continue }
        if (MaiorOuIgual $v '3.12') {
            return [pscustomobject]@{ Exe = $t.Exe; Args = $t.Args; Versao = $v }
        }
    }
    return $null
}

function UrlRepo($Slug) {
    if ($Ssh) { return "git@github.com:$Slug.git" }
    return "https://github.com/$Slug.git"
}

function LerRepos {
    Get-Content $Conf | Where-Object { $_ -notmatch '^\s*(#|$)' } | ForEach-Object {
        $p = $_ -split '\|' | ForEach-Object { $_.Trim() }
        [pscustomobject]@{ Nome = $p[0]; Slug = $p[1]; Pasta = $p[2]; Branch = $p[3]; Tipo = $p[4] }
    }
}

Write-Host 'CREED.ai Educa - setup do workspace'
Write-Host "workspace: $Workspace"
if ($Simular) { Write-Host 'modo:      simulacao (nada e executado)' }

# ------------------------------------------------------- 1. pre-requisitos

Titulo '1. Pre-requisitos'

if (Get-Command git -ErrorAction SilentlyContinue) {
    Passo ("git      " + ((git --version) -split ' ')[2])
} else {
    Erro 'git nao encontrado - https://git-scm.com/downloads'
}

$Py = AcharPython
if ($Py) {
    Passo ("python   " + $Py.Versao + " (" + $Py.Exe + " " + ($Py.Args -join ' ') + ")")
    if (MaiorOuIgual $Py.Versao '3.14') {
        Aviso ("python " + $Py.Versao + " e mais novo que o alvo do projeto (3.12) - se algum pacote nao tiver wheel, use 3.12")
    }
} else {
    Erro 'python 3.12+ nao encontrado (backend exige >=3.12)'
    Write-Host '         Windows: winget install Python.Python.3.12'
}

if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeV = (node -v) -replace '^v', ''
    if (MaiorOuIgual $nodeV '20') { Passo "node     $nodeV" }
    else { Aviso "node $nodeV - o front pede 20+; atualize se der problema no build" }
} else {
    Erro 'node nao encontrado (front) - https://nodejs.org (LTS 20+)'
}

if (Get-Command npm -ErrorAction SilentlyContinue) { Passo ("npm      " + (npm -v)) }
else { Erro 'npm nao encontrado (vem com o node)' }

if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker compose version *> $null
    if ($LASTEXITCODE -eq 0) {
        Passo ("docker   " + (((docker --version) -replace 'Docker version ', '') -split ',')[0] + ' (compose ok)')
    } else {
        Aviso "docker sem 'compose' - o banco local sobe com 'docker compose up -d db'"
    }
} else {
    Aviso 'docker nao encontrado - sem ele nao ha banco local nem teste de repository'
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Passo ("gh       " + (((gh --version) | Select-Object -First 1) -split ' ')[2])
} else {
    Aviso 'gh nao encontrado (opcional - abrir PR pelo terminal)'
}

if ($script:Falhas -gt 0) {
    Write-Host ''
    Write-Host "Faltam $($script:Falhas) pre-requisito(s) obrigatorio(s). Instale e rode de novo."
    exit 1
}

# --------------------------------------------------------- 2. repositorios

if (-not $SemClone) {
    Titulo '2. Repositorios'
    if (-not (Test-Path $Conf)) { Erro "repos.conf nao encontrado em $Conf"; exit 1 }

    foreach ($r in LerRepos) {
        $destino = Join-Path $Workspace $r.Pasta
        $url     = UrlRepo $r.Slug

        if (Test-Path (Join-Path $destino '.git')) {
            $atual = git -C $destino rev-parse --abbrev-ref HEAD 2>$null
            $sujo  = git -C $destino status --porcelain 2>$null
            if ($sujo) {
                Passo ($r.Nome + " - ja existe (branch $atual, com alteracoes locais; nao mexi)")
            } else {
                if ($Simular) {
                    Passo ("[simular] git -C " + $r.Pasta + ' pull --ff-only')
                } else {
                    git -C $destino pull --ff-only *> $null
                    if ($LASTEXITCODE -eq 0) { Passo ($r.Nome + " - atualizado (branch $atual)") }
                    else { Passo ($r.Nome + " - ja existe (branch $atual; pull nao foi fast-forward, nao mexi)") }
                }
            }
            continue
        }

        Passo ($r.Nome + ' - clonando...')
        if ($Simular) { Passo "[simular] git clone $url $destino"; continue }
        git clone --quiet $url $destino
        if ($LASTEXITCODE -ne 0) { Erro ($r.Nome + " - falha no clone de $url"); continue }

        git -C $destino show-ref --verify --quiet ("refs/remotes/origin/" + $r.Branch)
        if ($LASTEXITCODE -eq 0) {
            git -C $destino checkout --quiet $r.Branch
            Passo ($r.Nome + ' - na branch ' + $r.Branch)
        } else {
            $padrao = git -C $destino rev-parse --abbrev-ref HEAD
            Aviso ($r.Nome + " - branch '" + $r.Branch + "' ainda nao existe no remoto; ficou em '$padrao'")
        }
    }
}

# --------------------------------------------------------- 3-4. dependencias

if (-not $SemDeps) {
    $Back  = Join-Path $Workspace 'creed-backend'
    $Front = Join-Path $Workspace 'creed-frontend'

    if (Test-Path (Join-Path $Back 'pyproject.toml')) {
        Titulo '3. Backend (creed-backend)'
        $venv = Join-Path $Back '.venv'
        if (Test-Path $venv) {
            Passo '.venv ja existe'
        } elseif ($Simular) {
            Passo '[simular] python -m venv .venv'
        } else {
            Passo 'criando .venv...'
            & $Py.Exe @($Py.Args + @('-m', 'venv', $venv))
            if ($LASTEXITCODE -ne 0) { Erro 'falha ao criar o .venv' }
        }

        $bin    = Join-Path $venv 'Scripts'
        $vpy    = Join-Path $bin 'python.exe'
        $vprec  = Join-Path $bin 'pre-commit.exe'

        if ($Simular) {
            Passo '[simular] pip install -e ".[dev]"'
        } elseif (Test-Path $vpy) {
            Passo 'instalando dependencias (pode demorar)...'
            Push-Location $Back
            $saida = & $vpy -m pip install --quiet --upgrade pip 2>&1
            if ($LASTEXITCODE -eq 0) { $saida = & $vpy -m pip install --quiet -e '.[dev]' 2>&1 }
            $st = $LASTEXITCODE
            Pop-Location
            # o filtro tira so o ruido conhecido do cache do pip; erro real continua visivel
            $saida | Where-Object { $_ -notmatch 'Cache entry deserialization failed' -and "$_".Trim() } |
                     ForEach-Object { Write-Host ("         " + $_) }
            if ($st -eq 0) { Passo 'dependencias instaladas' }
            else { Erro 'pip install falhou - rode manualmente em creed-backend' }
        }

        $env_  = Join-Path $Back '.env'
        $envEx = Join-Path $Back '.env.example'
        if (Test-Path $env_)        { Passo '.env ja existe' }
        elseif ($Simular)           { Passo '[simular] copiar .env.example para .env' }
        elseif (Test-Path $envEx)   { Copy-Item $envEx $env_; Passo '.env criado a partir do .env.example' }
        else                        { Aviso 'sem .env.example no backend' }

        if ($Simular) {
            Passo '[simular] pre-commit install --hook-type pre-commit --hook-type pre-push'
        } elseif (Test-Path $vprec) {
            Push-Location $Back
            & $vprec install --hook-type pre-commit --hook-type pre-push *> $null
            $st = $LASTEXITCODE
            Pop-Location
            if ($st -eq 0) { Passo 'hooks de pre-commit e pre-push instalados' }
            else { Aviso 'pre-commit install falhou - o check de nome de branch so aparecera no PR' }
        }
    } elseif (-not $SemClone -and -not $Simular) {
        Aviso 'creed-backend nao encontrado - dependencias do backend puladas'
    }

    if (Test-Path (Join-Path $Front 'package.json')) {
        Titulo '4. Front-end (creed-frontend)'
        if ($Simular) {
            Passo '[simular] npm install'
        } else {
            Passo 'npm install (pode demorar)...'
            Push-Location $Front
            npm install --silent
            $st = $LASTEXITCODE
            Pop-Location
            if ($st -eq 0) { Passo 'dependencias instaladas (husky junto, via "prepare")' }
            else { Erro 'npm install falhou - rode manualmente em creed-frontend' }
        }
    } elseif (-not $SemClone -and -not $Simular) {
        Aviso 'creed-frontend nao encontrado - dependencias do front puladas'
    }
}

# ------------------------------------------------------ 5. adaptadores de IA

Titulo '5. Ferramentas de IA'

$instalador = Join-Path $ScriptDir 'instalar-adaptadores.ps1'
$prefSalva  = Test-Path (Join-Path $Workspace '.creed-ia.local')

if ($Ferramentas -and $Ferramentas -contains 'nenhuma') {
    Passo 'nenhum adaptador instalado (-SemAdaptadores)'
    Passo 'quando quiser: .\creed-ai-context\scripts\instalar-adaptadores.ps1 -Ferramentas <ferramenta>'
} elseif (-not $Ferramentas -and -not $prefSalva) {
    Passo 'voce nao passou -Ferramentas, entao nada de IA foi instalado.'
    Passo 'escolha a sua e rode:'
    Write-Host '         powershell -ExecutionPolicy Bypass -File creed-ai-context\scripts\instalar-adaptadores.ps1 -Ferramentas codex -Lembrar'
    Write-Host '         (opcoes: claude, codex, copilot, cursor, todas)'
} else {
    $args_ = @{ Ignorar = $Ignorar }
    if ($Ferramentas) { $args_['Ferramentas'] = $Ferramentas; $args_['Lembrar'] = $true }
    if ($Simular)     { $args_['Simular'] = $true }
    & $instalador @args_ | ForEach-Object { Write-Host ("  " + $_) }
}

# ------------------------------------------------------------------- resumo

Titulo 'Pronto'

if ($script:Avisos.Count -gt 0) {
    Write-Host ''
    Write-Host '  Avisos:'
    foreach ($a in $script:Avisos) { Write-Host "   . $a" }
}

Write-Host @"

  Backend
    cd $Workspace\creed-backend
    docker compose up -d db
    .venv\Scripts\activate
    alembic upgrade head
    uvicorn app.main:app --reload          # docs em http://localhost:8000/api/v1/docs

  Front-end
    cd $Workspace\creed-frontend
    npm run dev                            # faz proxy de /api para o backend

  Antes do primeiro PR
    leia creed-backend\CONTRIBUTING.md (branch, commit, PR - o GitHub cobra)
    leia creed-ai-context\CONTEXT.md   (padroes do projeto e como a IA trabalha aqui)
"@

if ($script:Falhas -gt 0) { exit 1 }
exit 0
