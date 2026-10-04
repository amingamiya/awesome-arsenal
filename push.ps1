# awesome-arsenal - push to GitHub (PowerShell, ASCII-only)
#
# NOTE: This file is intentionally ASCII-only (no Chinese).
# PowerShell 5.1 on Windows parses .ps1 files without a BOM using the system
# ANSI codepage (GBK here). Non-ASCII text gets corrupted, and characters like
# the Chinese full-width quotes are misread as syntax -> ParserError.
# Keeping this script pure ASCII avoids the problem entirely.
#
# Usage:
#   cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
#   powershell -ExecutionPolicy Bypass -File .\push.ps1
#
# If prompted for Username/Password, browser auth did not kick in:
#   Username: amingamiya
#   Password: your GitHub PAT (https://github.com/settings/tokens/new, repo scope)

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$repoUrl = 'https://github.com/amingamiya/awesome-arsenal.git'
$branch  = 'main'

Write-Host '>> 1/4 Init local repo' -ForegroundColor Cyan
if (-not (Test-Path '.git')) {
    git init | Out-Null
}
# Empty repo has no branch yet, so "git branch -M" fails with
# "refname refs/heads/master not found". Point HEAD at the branch instead.
git symbolic-ref HEAD "refs/heads/$branch"

Write-Host '>> 2/4 Write .gitignore' -ForegroundColor Cyan
$ignore = @(
    '.DS_Store'
    'Thumbs.db'
    '*.tmp'
)
Set-Content -Path '.gitignore' -Value $ignore -Encoding ASCII

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
Write-Host '   A browser window may open for GitHub authorization.' -ForegroundColor DarkGray
git push -u $repoUrl $branch

if ($LASTEXITCODE -eq 0) {
    Write-Host ''
    Write-Host 'DONE: https://github.com/amingamiya/awesome-arsenal' -ForegroundColor Green
} else {
    Write-Host ''
    Write-Host "Push failed (exit code $LASTEXITCODE)." -ForegroundColor Yellow
    Write-Host 'Two likely causes:' -ForegroundColor Yellow
    Write-Host '  A) Remote repo does not exist yet. Create an EMPTY repo at' -ForegroundColor Yellow
    Write-Host '     https://github.com/new  (name: awesome-arsenal, leave' -ForegroundColor Yellow
    Write-Host '     README / .gitignore / license UNCHECKED), then re-run.' -ForegroundColor Yellow
    Write-Host '  B) Auth failed. Use a Personal Access Token as the password.' -ForegroundColor Yellow
    exit 1
}
