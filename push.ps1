# awesome-arsenal - push to GitHub (PowerShell, ASCII-only)
#
# NOTE: This file is intentionally ASCII-only (no Chinese).
# PowerShell 5.1 on Windows parses .ps1 files without a BOM using the system
# ANSI codepage (GBK here). Non-ASCII text gets corrupted, and full-width
# quotes get misread as syntax -> ParserError. Pure ASCII avoids all of it.
#
# ------------------------------------------------------------------
# TWO AUTH MODES (script auto-detects, no editing needed)
#
# MODE 1 - token via env var (recommended, NO browser popup):
#   $env:GITHUB_TOKEN = 'ghp_xxxxxxxxxxxx'
#   powershell -ExecutionPolicy Bypass -File .\push.ps1
#
# MODE 2 - no token: falls back to Git Credential Manager browser auth.
#   If the browser popup times out or you close it, git reports
#   "TaskCanceledException encountered" (localized: a task was cancelled).
#   That is NOT a script bug, it just means auth was never completed.
#   Re-run and finish the browser flow, or use MODE 1 instead.
#
# Token creation: https://github.com/settings/tokens/new
#   - Expiration: any
#   - Scopes: MUST check "repo"
#   - Note: the token is shown only once.
# ------------------------------------------------------------------

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$repoUrl = 'https://github.com/amingamiya/awesome-arsenal.git'
$branch  = 'main'
$user    = 'amingamiya'

Write-Host '>> 1/4 Init local repo' -ForegroundColor Cyan
if (-not (Test-Path '.git')) {
    git init | Out-Null
}
# An empty repo has no branch yet, so "git branch -M" fails with
# "refname refs/heads/master not found". Point HEAD at the branch instead.
git symbolic-ref HEAD "refs/heads/$branch"

Write-Host '>> 2/4 Write .gitignore' -ForegroundColor Cyan
# Write with LF endings to avoid the "CRLF will be replaced by LF" warning.
$ignore = ".DS_Store`nThumbs.db`n*.tmp`n"
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot '.gitignore'), $ignore, (New-Object System.Text.UTF8Encoding $false))

Write-Host '>> 3/4 Commit' -ForegroundColor Cyan
git add -A
$dirty = git status --porcelain
if ([string]::IsNullOrWhiteSpace(($dirty -join ''))) {
    Write-Host '   Nothing to commit, skipped' -ForegroundColor DarkGray
} else {
    git -c user.name='aming' -c user.email='2281210248@qq.com' `
        commit -m 'feat: curated 121 popular GitHub projects (tools/crawler/reverse/security/fun/self-hosted)'
}

Write-Host '>> 4/4 Push to GitHub' -ForegroundColor Cyan

$token = $env:GITHUB_TOKEN
if ([string]::IsNullOrWhiteSpace($token)) {
    # MODE 2: browser auth via Git Credential Manager
    Write-Host '   MODE 2: GITHUB_TOKEN not set, using browser auth.' -ForegroundColor DarkGray
    Write-Host '   Finish the browser flow within ~2 min or it will time out.' -ForegroundColor Yellow
    git push -u $repoUrl $branch
} else {
    # MODE 1: token auth, no popup. Token is passed via env, never written to
    # .git/config or stored in the credential manager.
    Write-Host '   MODE 1: using GITHUB_TOKEN from environment.' -ForegroundColor DarkGray
    $pair = "$user`:$token"
    $b64  = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
    $hdr  = "Authorization: Basic $b64"
    git -c http.extraheader="$hdr" push -u $repoUrl $branch
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ''
    Write-Host 'DONE: https://github.com/amingamiya/awesome-arsenal' -ForegroundColor Green
    exit 0
} else {
    Write-Host ''
    Write-Host "Push failed (exit code $LASTEXITCODE)." -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'How to tell what went wrong:' -ForegroundColor Yellow
    Write-Host '  * "TaskCanceledException" / "task cancelled"' -ForegroundColor Yellow
    Write-Host '    -> auth was cancelled or timed out. Use MODE 1 (GITHUB_TOKEN),' -ForegroundColor Yellow
    Write-Host '       or re-run and complete the browser step within the time limit.' -ForegroundColor Yellow
    Write-Host '  * "403" / "Permission denied"' -ForegroundColor Yellow
    Write-Host '    -> token is missing the "repo" scope, or belongs to another account.' -ForegroundColor Yellow
    Write-Host '  * "repository not found"' -ForegroundColor Yellow
    Write-Host '    -> remote repo missing. Create an EMPTY repo at https://github.com/new' -ForegroundColor Yellow
    Write-Host '       (name awesome-arsenal, leave README / .gitignore / license unchecked).' -ForegroundColor Yellow
    Write-Host '  * "non-fast-forward" / "fetch first"' -ForegroundColor Yellow
    Write-Host '    -> remote already has commits. Run: git pull --rebase origin main' -ForegroundColor Yellow
    exit 1
}
