<#
.SYNOPSIS
Setup completo do workspace CREED.ai Educa:
pre-requisitos -> clone dos repos -> dependencias -> adaptadores de IA.

.DESCRIPTION
1. confere pre-requisitos (git, python, node, npm, docker, gh)
2. clona os repos de repos.conf - ou atualiza os que ja existem
3. confere a identidade que os commits de cada repo levariam
4. backend:  .venv + pip install -e ".[dev]" + .env + pre-commit
5. frontend: npm install (o husky se instala junto, via "prepare")
6. instala os adaptadores de IA das ferramentas escolhidas

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

.PARAMETER Identidade
Fixa user.name/user.email locais nos repos que ainda nao tem, no formato
"Nome <email>". Sem isto o script so avisa qual identidade os commits levariam.

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
    [string] $Identidade,
    [switch] $Ssh,
    [Alias('n')][switch] $Simular
)

$ErrorActionPreference = 'Continue'

$ScriptDir = $PSScriptRoot
$Harness   = Split-Path -Parent $ScriptDir
$Conf      = Join-Path $ScriptDir 'repos.conf'
if ($SemAdaptadores) { $Ferramentas = @('nenhuma') }
# chamado com -File, o PowerShell entrega "claude,codex" como UMA string: separa aqui
if ($Ferramentas) {
    $Ferramentas = $Ferramentas | ForEach-Object { $_ -split ',' } |
                   ForEach-Object { $_.Trim() } | Where-Object { $_ }
}
if (-not $Workspace) { $Workspace = Split-Path -Parent $Harness }
if (-not (Test-Path $Workspace)) { New-Item -ItemType Directory -Force -Path $Workspace | Out-Null }
$Workspace = (Resolve-Path $Workspace).Path

$script:Falhas = 0
$script:Avisos = @()

function Titulo($t)  { Write-Host ''; Write-Host "-- $t" }
function Passo($t)   { Write-Host "  $t" }
function Erro($t)    { Write-Host "  ERRO   $t"; $script:Falhas++ }
function Aviso($t)   { Write-Host "  aviso  $t"; $script:Avisos += $t }

$script:Inicio = Get-Date

# Desde $t0 -> "1m35s"
function Desde($T0) {
    $s = [int]((Get-Date) - $T0).TotalSeconds
    if ($s -ge 60) { return ('{0}m{1}s' -f [int]($s / 60), ($s % 60)) }
    return "${s}s"
}

# ComProgresso <dir> <regex-do-que-vale-mostrar> <exe> <argumentos>
#
# Instalar dependencia demora minutos; sem sinal de vida o dev nao sabe se
# travou. Roda o comando em segundo plano e vai imprimindo, conforme saem, so
# as linhas que dizem alguma coisa - mais um tique de tempo quando o comando
# fica quieto. Se falhar, mostra o fim da saida (o erro de verdade). Devolve o
# codigo de saida do processo.
function ComProgresso($Dir, $Filtro, $Exe, $Argumentos) {
    $out = [System.IO.Path]::GetTempFileName()
    $err = [System.IO.Path]::GetTempFileName()
    $p = Start-Process -FilePath $Exe -ArgumentList $Argumentos -WorkingDirectory $Dir `
                       -NoNewWindow -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
    # sem isto o Windows PowerShell 5.1 devolve ExitCode nulo quando nao se usa
    # -Wait, e nulo -ne 0 daria comando bem-sucedido como falho
    $p.EnableRaisingEvents = $true
    $t0 = Get-Date; $vistas = 0; $ultimo = 0

    while ($true) {
        $terminou = $p.HasExited
        if (-not $terminou) { Start-Sleep -Seconds 2 }

        $linhas = @()
        foreach ($f in @($out, $err)) {
            try { $linhas += @(Get-Content -LiteralPath $f -ErrorAction Stop) } catch { }
        }
        $linhas = @($linhas | Where-Object { "$_" -match $Filtro })

        if ($linhas.Count -gt $vistas) {
            foreach ($l in $linhas[$vistas..($linhas.Count - 1)]) {
                $t = "$l"
                if ($t.Length -gt 96) { $t = $t.Substring(0, 96) }
                Write-Host ('         ' + $t)
            }
            $vistas = $linhas.Count
            $ultimo = [int]((Get-Date) - $t0).TotalSeconds
        } elseif (-not $terminou -and (([int]((Get-Date) - $t0).TotalSeconds) - $ultimo) -ge 15) {
            $ultimo = [int]((Get-Date) - $t0).TotalSeconds
            Write-Host ('         . {0}s...' -f $ultimo)
        }

        if ($terminou) { break }
    }

    $p.WaitForExit()
    $codigo = $p.ExitCode
    if ($codigo -ne 0) {
        Write-Host '         - fim da saida -'
        $fim = @()
        foreach ($f in @($out, $err)) {
            try { $fim += @(Get-Content -LiteralPath $f -ErrorAction Stop) } catch { }
        }
        $fim | Select-Object -Last 20 | ForEach-Object { Write-Host ('         ' + $_) }
    }
    Remove-Item $out, $err -Force -ErrorAction SilentlyContinue
    return $codigo
}

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

# Separa "Nome <email>"; devolve $null se o formato nao bate.
function PartirIdentidade($Texto) {
    if ($Texto -match '^\s*(.+?)\s*<\s*([^<>@\s]+@[^<>\s]+)\s*>\s*$') {
        return [pscustomobject]@{ Nome = $Matches[1]; Email = $Matches[2] }
    }
    return $null
}

# Sem user.name/user.email locais, o commit herda o config global - e estes
# repos sao publicos, entao e essa identidade que fica registrada la. Em varias
# maquinas do time o global e uma conta corporativa. O script nao adivinha qual
# voce quer: fixa a que veio em -Identidade, ou mostra a que seria usada.
function IdentidadeDosRepos($Ident) {
    $pendentes = @()

    # O harness tambem recebe commits (PR de harness) e tambem e publico, mas
    # nao esta no repos.conf - entra na lista na mao.
    $lista = @([pscustomobject]@{ Nome = 'creed-ai-context'; Destino = $Harness })
    $lista += LerRepos | ForEach-Object {
        [pscustomobject]@{ Nome = $_.Nome; Destino = (Join-Path $Workspace $_.Pasta) }
    }

    foreach ($r in $lista) {
        $destino = $r.Destino
        if (-not (Test-Path (Join-Path $destino '.git'))) { continue }

        $nLocal = git -C $destino config --local --get user.name 2>$null
        $eLocal = git -C $destino config --local --get user.email 2>$null

        if ($nLocal -and $eLocal) {
            Passo ($r.Nome + " - $nLocal <$eLocal>")
            continue
        }

        if ($Ident) {
            if ($Simular) {
                Passo ($r.Nome + ' - [simular] git config user.name/user.email')
            } else {
                git -C $destino config user.name  $Ident.Nome
                git -C $destino config user.email $Ident.Email
                Passo ($r.Nome + " - fixada: $($Ident.Nome) <$($Ident.Email)>")
            }
            continue
        }

        $nEfet = git -C $destino config --get user.name 2>$null
        $eEfet = git -C $destino config --get user.email 2>$null
        if (-not $nEfet) { $nEfet = '?' }
        if (-not $eEfet) { $eEfet = '?' }
        Passo ($r.Nome + " - sem identidade local; o commit sairia como $nEfet <$eEfet>")
        $pendentes += $r.Nome
    }

    if ($pendentes.Count -eq 0) { return }

    Aviso ("$($pendentes.Count) repo(s) sem identidade local - o commit leva o seu git config global, e estes repos sao publicos")
    Write-Host '         para fixar nos que faltam:'
    Write-Host '           powershell -ExecutionPolicy Bypass -File creed-ai-context\scripts\setup-workspace.ps1 `'
    Write-Host '                -SemClone -SemDeps -SemAdaptadores -Identidade "Fulano <fulano@users.noreply.github.com>"'
}

$Ident = $null
if ($Identidade) {
    $Ident = PartirIdentidade $Identidade
    if (-not $Ident) {
        Write-Host "identidade fora do formato: $Identidade"
        Write-Host 'esperado: -Identidade "Nome <email>"'
        exit 1
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

# ------------------------------------------------- 3. identidade dos commits

Titulo '3. Identidade dos commits'
IdentidadeDosRepos $Ident

# --------------------------------------------------------- 4-5. dependencias

if (-not $SemDeps) {
    $Back  = Join-Path $Workspace 'creed-backend'
    $Front = Join-Path $Workspace 'creed-frontend'

    if (Test-Path (Join-Path $Back 'pyproject.toml')) {
        Titulo '4. Backend (creed-backend)'
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
            Passo 'instalando dependencias (pacote a pacote, abaixo)...'
            $tPip  = Get-Date
            $rePip = 'Collecting |Building wheel|Installing collected|Successfully installed|Successfully built|^ERROR'
            $pipBase = @('-m', 'pip', 'install', '--disable-pip-version-check', '--progress-bar', 'off')
            # sem buffer, o pip sai linha a linha mesmo sem terminal do outro lado
            $env:PYTHONUNBUFFERED = '1'
            $st = ComProgresso $Back $rePip $vpy ($pipBase + @('--upgrade', 'pip'))
            if ($st -eq 0) { $st = ComProgresso $Back $rePip $vpy ($pipBase + @('-e', '.[dev]')) }
            if ($st -eq 0) { Passo ('dependencias instaladas ({0})' -f (Desde $tPip)) }
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
        Titulo '5. Front-end (creed-frontend)'
        if ($Simular) {
            Passo '[simular] npm install'
        } else {
            Passo 'npm install (pode demorar)...'
            $tNpm = Get-Date
            # npm e um .cmd: precisa do cmd.exe para virar processo proprio
            $st = ComProgresso $Front 'added |removed |changed |up to date|packages are looking|npm error' `
                               $env:ComSpec @('/c', 'npm', 'install', '--no-fund')
            if ($st -eq 0) { Passo ('dependencias instaladas ({0}) (husky junto, via "prepare")' -f (Desde $tNpm)) }
            else { Erro 'npm install falhou - rode manualmente em creed-frontend' }
        }
    } elseif (-not $SemClone -and -not $Simular) {
        Aviso 'creed-frontend nao encontrado - dependencias do front puladas'
    }
}

# ------------------------------------------------------ 6. adaptadores de IA

Titulo '6. Ferramentas de IA'

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
    # -Workspace: sem ele o instalador cai na pasta que contem o harness, que nem
    # sempre e o workspace escolhido aqui
    $args_ = @{ Ignorar = $Ignorar; Workspace = $Workspace }
    if ($Ferramentas) { $args_['Ferramentas'] = $Ferramentas; $args_['Lembrar'] = $true }
    if ($Simular)     { $args_['Simular'] = $true }
    & $instalador @args_ | ForEach-Object { Write-Host ("  " + $_) }
}

# ------------------------------------------------------------------- resumo

Titulo ('Pronto (em {0})' -f (Desde $script:Inicio))

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
