# 推送到 GitHub · 操作指引

本地内容已全部提交完毕（2 个 commit，10 个文件）。**只差推送到远端这一步需要你本人操作**，原因是浏览器授权登录无法代劳。

## 一、先建空仓库（必做，30 秒）

打开 <https://github.com/new>，按下面填：

| 字段 | 填什么 |
|---|---|
| Owner | `amingamiya` |
| Repository name | `awesome-arsenal` |
| Description | 分类收藏的热门 GitHub 项目：实用 / 爬虫 / 逆向破解 / 安全 / 好玩 / 自托管 |
| Visibility | **Public**（想公开就选这个） |
| ☐ Add a README file | **不要勾** |
| ☐ Add .gitignore | **不要勾** |
| ☐ Choose a license | **不要勾** |

> 三个勾选框必须全空。勾了会和本地已有 commit 冲突，导致 push 被拒。

## 二、推送（二选一）

### 方式 A：用 Token 推送（推荐，不弹浏览器）

浏览器授权有个 2 分钟超时，超时就报 `TaskCanceledException`。用 token 更稳。

**1. 生成 token**

打开 <https://github.com/settings/tokens/new>：

| 项 | 填什么 |
|---|---|
| Note | 随便填，如 `push-arsenal` |
| Expiration | 选个期限（如 30 days） |
| Scopes | **勾选 `repo`** ← 不勾推不上去 |

点 Generate token，**立刻复制**——只显示一次，关掉页面就再也看不到。

**2. 设环境变量并推送**

```powershell
$env:GITHUB_TOKEN = '粘贴你的 token'
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
powershell -ExecutionPolicy Bypass -File .\push.ps1
```

脚本检测到 `GITHUB_TOKEN` 就会走 MODE 1，**不弹任何浏览器窗口**。

> token 只存在于当前这个 PowerShell 窗口的环境变量里，**不会**写进 `.git/config`，也**不会**存进 Windows 凭据管理器。关掉窗口就没了。

### 方式 B：浏览器授权

```powershell
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
powershell -ExecutionPolicy Bypass -File .\push.ps1
```

没设 `GITHUB_TOKEN` 时走这个。**需要在 2 分钟内完成浏览器授权**，超时或关掉弹窗就会报 `TaskCanceledException`。这不是脚本坏了，只是认证没走完。

### 方式 C：手动一条命令

```powershell
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
git push -u https://github.com/amingamiya/awesome-arsenal.git main
```

## 三、报错对照表

| 报错 | 原因 | 解决 |
|---|---|---|
| `TaskCanceledException`<br>`已取消一个任务` | 浏览器授权超时或被关掉 | 换方式 A（token），或重跑并在 2 分钟内完成授权 |
| `403` / `Permission denied` | token 缺 `repo` 权限，或不属于 `amingamiya` | 重新生成，确认勾了 `repo` |
| `repository not found` | 远端仓库没建 | 去 <https://github.com/new> 建**空**仓（README / .gitignore / license 三个都不勾） |
| `non-fast-forward` / `fetch first` | 远端已有提交 | `git pull --rebase origin main` 后再推 |
| `libpng warning: iCCP` | 无关的图片库警告 | 忽略，不影响推送 |

> 粘贴 token 时终端**不显示任何字符**，是正常的（防窃听设计），粘完直接回车。

## 四、报错排除法

万一还是推不上去，先单独测连通性：

```powershell
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
git ls-remote https://github.com/amingamiya/awesome-arsenal.git
```

- 正常返回远端分支列表 → 网络和仓库都没问题，问题在认证
- 报 `repository not found` → 仓库名拼错或没建好
- 一直卡住不动 → 在等凭据输入，按 `Ctrl+C` 取消

## 五、验证

推送成功后打开 <https://github.com/amingamiya/awesome-arsenal>，应该能看到：

```
.gitignore
README.md
01-实用工具.md
02-爬虫与数据采集.md
03-逆向与破解.md
04-安全与渗透.md
05-好玩项目.md
06-自托管服务.md
data/repos-2026-10-04.json
push.ps1
push.sh
如何推送到GitHub.md
```

也可以在本地验证：

```powershell
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
git status                     # 应该显示 working tree clean
git log --oneline              # 应该有 6 个 commit
```

## 六、以后更新内容

本地改完文件后，只需要推送增量：

```powershell
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
git add -A
git commit -m "描述本次改动"
git push
```

首次 `git push -u` 之后，origin 已绑定，后续直接 `git push` 即可。

> ⚠️ **以后不要在 PowerShell 里敲 `bash push.sh`**。PowerShell 的 `bash` 指向 WSL，
> 你的 WSL 服务没启用，会报「无法启动服务」。一律用 `push.ps1`。
>
> 另外 `push.ps1` 刻意写成纯英文：PowerShell 5.1 读不带 BOM 的 `.ps1` 时按 GBK 解析，
> 中文注释会变乱码，中文全角引号 `“”` 会被当成语法符号 → `ParserError`。
