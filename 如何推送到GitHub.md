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

### 方式 A：跑脚本（推荐）

```powershell
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
powershell -ExecutionPolicy Bypass -File .\push.ps1
```

会弹出浏览器让你登录 GitHub，授权完自动完成推送。

> ⚠️ **两个已踩过的坑，脚本都已规避，你不用再操心：**
>
> 1. **不要在 PowerShell 里敲 `bash push.sh`**。PowerShell 的 `bash` 指向 WSL，
>    WSL 服务被禁用时会报「无法启动服务，原因可能是已被禁用或与其相关的设备没有启动」。
>    所以改用了 `push.ps1`（PowerShell 原生，零 WSL 依赖）。
>
> 2. **`push.ps1` 已改成纯英文**。PowerShell 5.1 读不带 BOM 的 `.ps1` 时按系统 ANSI
>    码页（中文系统是 GBK）解析，脚本里的中文会变成乱码，连中文引号
>    `“”` 都会被误判成语法符号，直接报 `ParserError`。纯 ASCII 就没这个问题。

### 方式 B：手动三条命令

```powershell
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
git push -u https://github.com/amingamiya/awesome-arsenal.git main
```

## 三、如果卡在登录

**现象**：终端提示 `Username for 'https://github.com':` 和 `Password for ...:`

**原因**：浏览器授权没走通，退回到基础认证模式。

**做法**：

1. 打开 <https://github.com/settings/tokens/new>
2. Note 随便填个名字，Expiration 选个期限
3. **勾选 `repo` 权限**（这是关键，不勾无法推送）
4. 生成后复制 token
5. 终端里粘贴：
   - Username：`amingamiya`
   - Password：**粘贴那个 token**（不是 GitHub 登录密码）

token 只显示一次，关掉页面就再也看不到了。粘贴时终端不显示任何字符，是正常的，粘完直接回车。

## 四、验证

推送成功后打开 <https://github.com/amingamiya/awesome-arsenal>，应该能看到：

```
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
```

## 五、以后更新内容

本地改完文件后，只需要推送增量：

```powershell
cd E:\ai\workbuddy\2026-10-04-14-24-30\awesome-arsenal
git add -A
git commit -m "描述本次改动"
git push
```

首次 `git push -u` 之后，origin 已绑定，后续直接 `git push` 即可。
