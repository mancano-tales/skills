<#
.SYNOPSIS
    sync-skills.ps1 — Sincronização de skills de governança a partir do repositório mãe (Windows)
.DESCRIPTION
    Compara as skills locais (.claude/skills/*) com as do repositório mãe e reporta
    o status. Oferece suporte a cópia (-Apply) e commit cirúrgico automatizado (-Commit)
    no formato Conventional Commits.
.PARAMETER Apply
    Nome de uma skill específica para puxar da mãe, ou 'all' para puxar todas.
.PARAMETER Commit
    Se presente, realiza o commit cirúrgico das skills atualizadas com mensagem padronizada.
.PARAMETER Quiet
    Se presente, suprime saídas desnecessárias (útil para execução via Git Hooks).
.PARAMETER SourcePath
    Caminho explícito para o repositório mãe.
#>
param(
    [string]$Apply = "",
    [switch]$Commit = $false,
    [switch]$Quiet = $false,
    [string]$SourcePath = ""
)

$RepoRoot = (Get-Item $PSScriptRoot).Parent.FullName

function Resolve-SkillsSource {
    param([string]$Override)
    if ($Override -ne "") { return $Override }

    $configFile = Join-Path $PSScriptRoot ".skills-source"
    if (Test-Path -Path $configFile -PathType Leaf) {
        $configured = (Get-Content -Path $configFile -TotalCount 1).Trim()
        if ($configured -ne "") {
            if (-not [System.IO.Path]::IsPathRooted($configured)) {
                return (Join-Path $PSScriptRoot $configured)
            }
            return $configured
        }
    }

    $siblingDir = Split-Path -Path $RepoRoot -Parent
    return (Join-Path $siblingDir "agentic-research-template")
}

function Get-FolderHash {
    param([string]$FolderPath)
    if (-not (Test-Path -Path $FolderPath -PathType Container)) { return $null }
    $FolderPath = [System.IO.Path]::GetFullPath($FolderPath)
    $files = Get-ChildItem -Path $FolderPath -Recurse -File | Sort-Object FullName
    if ($files.Count -eq 0) { return $null }
    $combined = ($files | ForEach-Object {
        $rel = $_.FullName.Substring($FolderPath.Length).Replace("\", "/")
        $h = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
        "$rel`:$h"
    }) -join "|"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($combined)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    return [System.BitConverter]::ToString($sha.ComputeHash($bytes)).Replace("-", "")
}

$SourceRoot = Resolve-SkillsSource -Override $SourcePath

if (-not (Test-Path -Path $SourceRoot -PathType Container)) {
    if (-not $Quiet) { Write-Warning "⚠ [ERRO] Repositório mãe não encontrado em: $SourceRoot" }
    exit 1
}

$SourceSkillsDir = Join-Path $SourceRoot ".claude\skills"
if (-not (Test-Path -Path $SourceSkillsDir -PathType Container)) {
    if (-not $Quiet) { Write-Warning "⚠ [ERRO] Repositório mãe sem .claude/skills em: $SourceRoot" }
    exit 1
}

$LocalSkillsDir = Join-Path $RepoRoot ".claude\skills"
if (-not (Test-Path -Path $LocalSkillsDir -PathType Container)) {
    New-Item -ItemType Directory -Path $LocalSkillsDir -Force | Out-Null
}

if (-not $Quiet) {
    Write-Host "🔄 Comparando skills locais com a mãe em: $SourceRoot" -ForegroundColor Cyan
    Write-Host ""
}

$motherSkills = Get-ChildItem -Path $SourceSkillsDir -Directory
$toApply = @()

foreach ($skill in $motherSkills) {
    $name = $skill.Name
    $motherHash = Get-FolderHash -FolderPath $skill.FullName
    if ($null -eq $motherHash) { continue }

    $localDir = Join-Path $LocalSkillsDir $name
    $localHash = Get-FolderHash -FolderPath $localDir

    if ($null -eq $localHash) {
        if (-not $Quiet) { Write-Host ("  {0,-28} NOVA (não instalada)" -f $name) -ForegroundColor Yellow }
        $toApply += @{ Name = $name; Status = "nova" }
    } elseif ($localHash -eq $motherHash) {
        if (-not $Quiet) { Write-Host ("  {0,-28} em dia" -f $name) -ForegroundColor Green }
    } else {
        if (-not $Quiet) { Write-Host ("  {0,-28} desatualizada" -f $name) -ForegroundColor Yellow }
        $toApply += @{ Name = $name; Status = "desatualizada" }
    }
}

if (-not $Quiet) { Write-Host "" }

if ($Apply -eq "") {
    if ($toApply.Count -gt 0 -and -not $Quiet) {
        Write-Host "💡 Existem skills com atualizações disponíveis! Rode com -Apply all para atualizar." -ForegroundColor Yellow
    }
    exit 0
}

$targets = if ($Apply -eq "all") { $toApply } else { $toApply | Where-Object { $_.Name -eq $Apply } }

if ($targets.Count -eq 0) {
    if (-not $Quiet) { Write-Host "Nada a aplicar para '$Apply' (já está em dia ou não existe na mãe)." -ForegroundColor Yellow }
    exit 0
}

$appliedNames = @()
foreach ($t in $targets) {
    $srcDir = Join-Path $SourceSkillsDir $t.Name
    $destDir = Join-Path $LocalSkillsDir $t.Name
    if (Test-Path -Path $destDir) { Remove-Item -Path $destDir -Recurse -Force }
    Copy-Item -Path $srcDir -Destination $destDir -Recurse -Force
    if (-not $Quiet) { Write-Host "  ✅ '$($t.Name)' copiada da mãe." -ForegroundColor Green }
    $appliedNames += $t.Name
}

if ($Commit) {
    $appliedList = $appliedNames -join ", "
    $commitMsg = "chore(skills): sync skills from mother template [$appliedList]"
    
    foreach ($name in $appliedNames) {
        $skillPath = Join-Path ".claude\skills" $name
        git -C $RepoRoot add $skillPath
    }

    $newsPath = Join-Path $RepoRoot "NEWS.md"
    if (Test-Path -Path $newsPath) {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
        $entry = @"

## $timestamp — Sincronização de skills de governança

Atualização automatizada das skills: $appliedList.

**Metadados de Execução**:
- **Data/Hora**: $timestamp (Horário Local)
- **Agente**: sync-skills.ps1 / Antigravity
- **Mensagem do Commit**: "$commitMsg"
- **Arquivos afetados**: .claude/skills/, NEWS.md
"@
        Add-Content -Path $newsPath -Value $entry -Encoding UTF8
        git -C $RepoRoot add NEWS.md
    }

    git -C $RepoRoot commit -m $commitMsg
    if (-not $Quiet) { Write-Host "✅ Commit cirúrgico realizado: '$commitMsg'" -ForegroundColor Green }
} else {
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "⚠ Nada foi commitado. Revise as alterações e faça 'git add' explícito antes de commitar." -ForegroundColor Yellow
    }
}
