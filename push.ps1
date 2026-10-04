<#
  awesome-arsenal 一键推送到 GitHub（PowerShell 原生版）

  为什么不用 push.sh：PowerShell 里的 bash 指向 WSL，若 WSL 服务被禁用会报
  “无法启动服务，原因可能是已被禁用或与其相关的设备没有启动”。本脚本零依赖，
  只用 git 原生命令，不经过 WSL。

  用法：
    # PowerShell（普通权限即可）
    cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
    powershell -ExecutionPolicy Bypass -File .\push.ps1

  若提示输入用户名密码，说明浏览器授权没走通：
    用户名填 amingamiya
    密码填 GitHub Personal Access Token（https://github.com/settings/tokens 生成，
    勾选 repo 权限；不要填 GitHub 登录密码）
#>

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$repoUrl = 'https://github.com/amingamiya/awesome-arsenal.git'
$branch = 'main'

Write-Host '>> 1/4 初始化本地仓库' -ForegroundColor Cyan
if (-not (Test-Path '.git')) {
    git init | Out-Null
}
git branch -M $branch 2>&1 | Out-Null

Write-Host '>> 2/4 写入忽略规则' -ForegroundColor Cyan
@'
.DS_Store
Thumbs.db
*.tmp
'@ | Set-Content -Path '.gitignore' -Encoding UTF8

Write-Host '>> 3/4 提交' -ForegroundColor Cyan
git add -A
if (-not (git status --porcelain)) {
    Write-Host '   没有变更，跳过提交' -ForegroundColor DarkGray
} else {
    git -c user.name='aming' -c user.email='2281210248@qq.com' `
        commit -m 'feat: 分类收藏 121 个热门 GitHub 项目（实用/爬虫/逆向/安全/好玩/自托管）'
}

Write-Host '>> 4/4 推送到 GitHub' -ForegroundColor Cyan
Write-Host '   若弹出浏览器请完成 GitHub 授权，终端会继续' -ForegroundColor DarkGray
git push -u $repoUrl $branch

if ($LASTEXITCODE -eq 0) {
    Write-Host ''
    Write-Host '推送成功： https://github.com/amingamiya/awesome-arsenal' -ForegroundColor Green
} else {
    Write-Host ''
    Write-Host "推送未完成（退出码 $LASTEXITCODE）。" -ForegroundColor Yellow
    Write-Host '两种可能：' -ForegroundColor Yellow
    Write-Host '  A) 远端仓库还没建 —— 去 https://github.com/new 建空仓（名字 awesome-arsenal，'
    Write-Host '     不勾选 README/.gitignore/license），再重跑本脚本。' -ForegroundColor Yellow
    Write-Host '  B) 授权失败 —— 改用 Personal Access Token 作为密码重试。' -ForegroundColor Yellow
}
