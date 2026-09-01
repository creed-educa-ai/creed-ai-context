<#
.SYNOPSIS
Instala os arquivos de entrada das ferramentas de IA a partir de
creed-ai-context\adaptadores\ — só das ferramentas que VOCÊ usa.

.PARAMETER Ferramentas
claude, codex, copilot, cursor (ou "todas"). Padrao: $env:CREED_IA_FERRAMENTAS,
senao .creed-ia.local, senao "todas".

.PARAMETER Repos
Padrao: todos os repos presentes no workspace.

.PARAMETER Workspace
Onde escrever os adaptadores. Padrao: a pasta que contem o creed-ai-context.

.PARAMETER SemRaiz
Nao escreve na raiz do workspace.

.PARAMETER Ignorar
local (padrao) -> .git\info\exclude de cada repo (nao sobe)
repo           -> .gitignore do repo (versionado, decisao de time)
nao            -> nao mexe em ignore

.PARAMETER Lembrar
Grava a escolha de ferramentas em .creed-ia.local.

.PARAMETER Remover
Remove os adaptadores gerados (e o bloco de ignore) e sai.

.PARAMETER Simular
Mostra o que faria, sem escrever.

.EXAMPLE
# so o Codex, ignorado localmente (nao sobe para os repos)
.\instalar-adaptadores.ps1 -Ferramentas codex -Lembrar

.EXAMPLE
# Claude Code + Copilot, so no backend
.\instalar-adaptadores.ps1 -Ferramentas claude,copilot -Repos creed-backend

.EXAMPLE
.\instalar-adaptadores.ps1 -Remover
#>
[CmdletBinding()]
param(
    [Alias('f')][string[]] $Ferramentas,
    [Alias('r')][string[]] $Repos,
    [string] $Workspace,
    [switch] $SemRaiz,
    [ValidateSet('local', 'repo', 'nao')][string] $Ignorar = 'local',
    [switch] $Lembrar,
    [switch] $Remover,
    [Alias('n')][switch] $Simular
)

$ErrorActionPreference = 'Stop'

$Harness  = Split-Path -Parent $PSScriptRoot
if ($Workspace) {
    if (-not (Test-Path $Workspace)) { throw "workspace nao encontrado: $Workspace" }
    $WS = (Resolve-Path $Workspace).Path
} else {
    $WS = Split-Path -Parent $Harness
}
$Adp      = Join-Path $Harness 'adaptadores'
$Config   = Join-Path $WS '.creed-ia.local'
$Marca    = 'GERADO por'
$BlocoIni = '# >>> creed-ai-context: adaptadores de IA (gerados, locais) >>>'
$BlocoFim = '# <<< creed-ai-context <<<'
$TodosRepos      = @('creed-backend', 'creed-frontend', 'creed-infrastructure')
$TodasFerramentas = @('claude', 'codex', 'copilot', 'cursor')
$CaminhosIgnore  = @('/CLAUDE.md', '/AGENTS.md', '/.github/copilot-instructions.md', '/.cursor/')

# ferramentas: parametro > variavel de ambiente > arquivo local > todas
if (-not $Ferramentas) {
    if ($env:CREED_IA_FERRAMENTAS) {
        $Ferramentas = $env:CREED_IA_FERRAMENTAS -split ','
    } elseif (Test-Path $Config) {
        $linha = Get-Content $Config | Where-Object { $_ -match '^ferramentas=' } | Select-Object -Last 1
        if ($linha) { $Ferramentas = ($linha -replace '^ferramentas=', '').Trim() -split ',' }
    }
}
if (-not $Ferramentas) { $Ferramentas = @('todas') }
# chamado com -File, o PowerShell entrega "claude,codex" como UMA string: separa aqui
$Ferramentas = $Ferramentas | ForEach-Object { $_ -split ',' } |
               ForEach-Object { $_.Trim() } | Where-Object { $_ }
if ($Ferramentas -contains 'todas') { $Ferramentas = $TodasFerramentas }
foreach ($f in $Ferramentas) {
    if ($TodasFerramentas -notcontains $f) {
        throw "ferramenta desconhecida: $f (use claude, codex, copilot, cursor ou todas)"
    }
}
if (-not $Repos) { $Repos = $TodosRepos }
else { $Repos = $Repos | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ } }

function Rel($Caminho) { $Caminho.Replace($WS + '\', '').Replace($WS + '/', '') }

function EhGerado($Caminho) {
    if (-not (Test-Path $Caminho)) { return $false }
    return ((Get-Content $Caminho -TotalCount 8) -join "`n") -match [regex]::Escape($Marca)
}

# O prefixo reescreve "creed-ai-context/" para "../creed-ai-context/": dentro de um
# repo o harness fica um nivel acima da raiz onde a ferramenta trabalha.
function Escrever($Origem, $Destino, $Prefixo) {
    if ($Simular) { Write-Host ("  [simular] escrever  " + (Rel $Destino)); return }
    $dir = Split-Path -Parent $Destino
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if ([string]::IsNullOrEmpty($Prefixo)) {
        Copy-Item -Path $Origem -Destination $Destino -Force
    } else {
        $texto = Get-Content -Path $Origem -Raw -Encoding UTF8
        $texto = $texto -replace '(?<![./\w])creed-ai-context/', ($Prefixo + 'creed-ai-context/')
        Set-Content -Path $Destino -Value $texto -Encoding UTF8 -NoNewline
    }
    Write-Host ("  ok        " + (Rel $Destino))
}

function Descartar($Destino) {
    if (-not (EhGerado $Destino)) { return }
    if ($Simular) { Write-Host ("  [simular] remover   " + (Rel $Destino)); return }
    Remove-Item -Path $Destino -Force
    Write-Host ("  removido  " + (Rel $Destino))
    $dir = Split-Path -Parent $Destino
    while ($dir -and $dir -ne $WS -and (Test-Path $dir) -and -not (Get-ChildItem $dir -Force)) {
        Remove-Item $dir -Force
        $dir = Split-Path -Parent $dir
    }
}

function AlvoIgnore($RepoDir, $Modo) {
    if ($Modo -eq 'repo') {
        return [pscustomobject]@{
            Alvo   = Join-Path $RepoDir '.gitignore'
            Rotulo = (Split-Path -Leaf $RepoDir) + '/.gitignore'
        }
    }
    $gitdir = & git -C $RepoDir rev-parse --absolute-git-dir 2>$null
    if (-not $gitdir) { return $null }
    $info = Join-Path $gitdir 'info'
    if (-not (Test-Path $info)) { New-Item -ItemType Directory -Force -Path $info | Out-Null }
    return [pscustomobject]@{
        Alvo   = Join-Path $info 'exclude'
        Rotulo = (Split-Path -Leaf $RepoDir) + '/.git/info/exclude'
    }
}

function SemBloco($Alvo) {
    if (-not (Test-Path $Alvo)) { return @() }
    $fora = @(); $dentro = $false
    foreach ($linha in Get-Content $Alvo) {
        if ($linha -eq $BlocoIni) { $dentro = $true; continue }
        if ($linha -eq $BlocoFim) { $dentro = $false; continue }
        if (-not $dentro) { $fora += $linha }
    }
    return $fora
}

function IgnorarBloco($RepoDir, $Modo) {
    if ($Modo -eq 'nao') { return }
    $x = AlvoIgnore $RepoDir $Modo
    if (-not $x) {
        Write-Host ("  aviso     " + (Split-Path -Leaf $RepoDir) + " nao e repo git - ignore pulado")
        return
    }
    if ($Simular) { Write-Host ("  [simular] ignorar   " + $x.Rotulo); return }
    $conteudo = @(SemBloco $x.Alvo) + @($BlocoIni) + $CaminhosIgnore + @($BlocoFim)
    Set-Content -Path $x.Alvo -Value $conteudo -Encoding UTF8
    Write-Host ("  ignore    " + $x.Rotulo)
}

function LimparIgnore($RepoDir) {
    foreach ($modo in @('local', 'repo')) {
        $x = AlvoIgnore $RepoDir $modo
        if (-not $x -or -not (Test-Path $x.Alvo)) { continue }
        if (-not (Select-String -Path $x.Alvo -Pattern ([regex]::Escape($BlocoIni)) -Quiet)) { continue }
        if ($Simular) { Write-Host ("  [simular] ignore-   " + $x.Rotulo); continue }
        Set-Content -Path $x.Alvo -Value (SemBloco $x.Alvo) -Encoding UTF8
        Write-Host ("  ignore-   " + $x.Rotulo)
    }
}

Write-Host "workspace:   $WS"
if ($Remover) {
    Write-Host 'acao:        remover adaptadores gerados'
} else {
    Write-Host ("ferramentas: " + ($Ferramentas -join ','))
    Write-Host "ignore:      $Ignorar"
    if ($Simular) { Write-Host 'modo:        simulacao (nada e escrito)' }
}

# ---------- raiz do workspace ----------
if (-not $SemRaiz) {
    Write-Host ''
    Write-Host 'raiz do workspace'
    $cmdDir = Join-Path $WS '.claude\commands'
    if ($Remover -or ($Ferramentas -notcontains 'claude')) {
        Descartar (Join-Path $WS 'CLAUDE.md')
        Get-ChildItem (Join-Path $Adp 'claude\commands') -Filter *.md | ForEach-Object {
            Descartar (Join-Path $cmdDir $_.Name)
        }
    } else {
        Escrever (Join-Path $Adp 'CLAUDE.md') (Join-Path $WS 'CLAUDE.md') $null
        Get-ChildItem (Join-Path $Adp 'claude\commands') -Filter *.md | ForEach-Object {
            Escrever $_.FullName (Join-Path $cmdDir $_.Name) $null
        }
    }
    $skillsOrigem = Join-Path $Adp 'claude\skills'
    $skillsDir    = Join-Path $WS '.claude\skills'
    if (Test-Path $skillsOrigem) {
        Get-ChildItem $skillsOrigem -Directory | ForEach-Object {
            $origem  = Join-Path $_.FullName 'SKILL.md'
            $destino = Join-Path (Join-Path $skillsDir $_.Name) 'SKILL.md'
            if (-not (Test-Path $origem)) { return }
            if ($Remover -or ($Ferramentas -notcontains 'claude')) { Descartar $destino }
            else { Escrever $origem $destino $null }
        }
    }
    if ($Remover -or ($Ferramentas -notcontains 'codex')) {
        Descartar (Join-Path $WS 'AGENTS.md')
    } else {
        Escrever (Join-Path $Adp 'AGENTS.md') (Join-Path $WS 'AGENTS.md') $null
    }
}

# ---------- repos ----------
foreach ($repo in $Repos) {
    $dir = Join-Path $WS $repo
    if (-not (Test-Path $dir)) {
        Write-Host ''
        Write-Host "$repo - ausente, pulando"
        continue
    }
    Write-Host ''
    Write-Host $repo

    $mapa = @(
        @{ Ferramenta = 'claude';  Origem = 'CLAUDE.md';               Destino = 'CLAUDE.md' },
        @{ Ferramenta = 'codex';   Origem = 'AGENTS.md';               Destino = 'AGENTS.md' },
        @{ Ferramenta = 'copilot'; Origem = 'copilot-instructions.md'; Destino = '.github\copilot-instructions.md' },
        @{ Ferramenta = 'cursor';  Origem = 'cursor-rules.mdc';        Destino = '.cursor\rules\creed.mdc' }
    )
    foreach ($m in $mapa) {
        $destino = Join-Path $dir $m.Destino
        if ($Remover -or ($Ferramentas -notcontains $m.Ferramenta)) {
            Descartar $destino
        } else {
            Escrever (Join-Path $Adp $m.Origem) $destino '../'
        }
    }

    if ($Remover) { LimparIgnore $dir } else { IgnorarBloco $dir $Ignorar }
}

# ---------- preferencia ----------
if ($Lembrar -and -not $Remover -and -not $Simular) {
    $texto = "# preferencia local de ferramentas de IA - nao versionado`nferramentas=" +
             ($Ferramentas -join ',') + "`n"
    Set-Content -Path $Config -Value $texto -Encoding UTF8 -NoNewline
    Write-Host ''
    Write-Host ("preferencia gravada em " + (Rel $Config) + " - proximas execucoes usam ela sem -Ferramentas")
}

Write-Host ''
if ($Remover) {
    Write-Host 'Removido. Nada do harness em si foi apagado - so os arquivos gerados.'
    return
}

Write-Host 'Pronto.'
Write-Host ''
Write-Host 'Os arquivos acima sao GERADOS - nao edite nenhum deles. Mudanca de conteudo vai em'
Write-Host 'creed-ai-context\adaptadores\ e este script roda de novo.'
Write-Host ''
Write-Host 'Dentro dos repos os caminhos apontam ../creed-ai-context/, para o adaptador funcionar'
Write-Host 'tambem com o repo aberto sozinho.'
Write-Host ''
switch ($Ignorar) {
    'local' {
        Write-Host 'Ignore em .git\info\exclude: vale so no SEU clone e nao sobe para o repo.'
        Write-Host 'Cada pessoa roda o script com as proprias ferramentas; ninguem ve as dos outros.'
    }
    'repo' {
        Write-Host 'Ignore no .gitignore: e um arquivo VERSIONADO - a regra sobe para o repo.'
        Write-Host 'So use este modo se o time decidiu isso em conjunto.'
    }
    'nao' {
        Write-Host 'Nenhuma regra de ignore aplicada: os adaptadores aparecem no git status.'
    }
}
