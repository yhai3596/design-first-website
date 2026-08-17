# 提取通道手册（agent-browser 用法 + 故障恢复）

`website-to-design-md` 的提取按以下优先级执行。开工先自检 `command -v agent-browser`：装了走通道 1/2，没装走通道 3。

> 装 agent-browser：`npm i -g agent-browser` **再** `agent-browser install`（后者下载 Chrome，漏了会在 `open` 时报 `Chrome not found`，`--version` 却正常——别误判成"装好了"）。它不是硬依赖，但通道 1/2 拿到的是真实 DOM + computed styles + CSS 变量，通道 3 只能靠截图和有限探针——设计规则提取的精度差一档。
>
> 下方排错结论来自 Windows + Git Bash 环境的实测记录（agent-browser 0.32.3，2026-07-22）。**平台无关**的部分：上游 [#1118](https://github.com/vercel-labs/agent-browser/issues/1118) 的 stale daemon 卡死态、`--debug` 绑死控制台、脚本化调用的管道 EOF 死等。**仅 Windows** 的部分已单独标注。

## 通道 1（默认）：agent-browser CLI 直驱

按原版 `website-to-design-md/SKILL.md` 流程：
- `agent-browser --session <名> open <url>` → `set viewport 1440 1400` → `wait --load networkidle` → 滚动扫掠 → `eval --stdin` 执行 styleProbe
- 移动端：`set device "iPhone 14"`（=390×844，与原版脚本一致）→ `reload` → 同序列
- 会话用完必须 `close`，不留僵尸；单 shell 链式（`cmd1 && cmd2`）最稳；跨 Bash 调用会话保持（实测 pid 不变）

## 通道 2：结构化落盘 run-styleprobe.mjs

需要与原版同构的证据 JSON 文件时：

```bash
node ~/.claude/skills/design-first-website/scripts/run-styleprobe.mjs <url> [outPath]
```

运行时从原版脚本提取 styleProbe（零 fork、原版更新自动跟随），产出 `{url, capturedAt, pages:{desktop,mobile}, tooling}`。实测双端证据 JSON 约 500KB+。

**跨平台**：macOS/Linux 上直接调 PATH 里的 `agent-browser`；Windows 上绕过 MSYS shim 直调 win32 exe。原版脚本装在别处时用 `VENDOR_SCRIPT=<路径>` 覆盖。

**为何 Windows 上不能用原版自带 extract-browser-evidence.mjs**（Windows+Git Bash 通病）：
① 它用 `bash -lc "command -v agent-browser"` 解析到 MSYS 路径的 shell shim（`/c/.../agent-browser`），`spawnSync` 在 Windows 无法执行该路径；
② 会话首命令孵化的 daemon 会继承调用方 stdio 管道句柄且永不退出 → spawnSync 等管道 EOF 无限挂。驱动器用「`stdio:"ignore"` 引导 daemon + 逐命令超时」解决。

## 通道 3（兜底）：内置浏览器 + 原版 styleProbe

未装 agent-browser，或它整体故障且恢复手册无效时走这条，并告知用户一句（明示降级）：
Read 原版脚本取 styleProbe（`const styleProbe = \`...\``，~31-213 行）→ `preview_start {url}` → `resize_window 1440x1400` → `javascript_tool` 执行探针——**结果存 `window.__dfw_evidence` 只回摘要**（完整 JSON 实测 236k 字符，整包过工具返回会爆）→ `resize_window mobile` 再测一轮。合成环节与原版零差异。

## daemon 卡死恢复手册（上游 issue #1118）

**症状**：任何命令（含 `close`）挂起 >20 秒零输出；`--help` 却正常。
**原因**：中断/并发会话留下卡死 daemon，CLI 连上去永久等待，上游无自愈。
**处置**（PID 精确操作，禁止按进程名批杀——会连带杀掉用户其他项目的会话）：
1. `tr -d '\r\n' < ~/.agent-browser/<会话>.pid` 取 PID
2. 确认这个 PID 真是 agent-browser：macOS/Linux `ps -p <PID> -o comm=`；Windows `tasklist //FI "PID eq <PID>"`（应为 agent-browser-win32-x64.exe）
3. 杀：macOS/Linux `kill -9 <PID>`；Windows `taskkill //F //PID <PID>`。然后 `rm ~/.agent-browser/<会话>.*`
4. 重试（daemon 按需重生）。**只动这一个会话**，`~/.agent-browser/` 下其他会话可能属于别的项目。

## 已知坑

- **`--debug` 让 daemon 绑死调用控制台**：控制台一关 daemon 即死、页面状态丢（实测）。调试完必须去掉。
- `timeout N` 包装无害（实测不影响持久化）。
- 脚本化调用（spawnSync/execFile）首命令必须 `stdio:"ignore"` 引导（见通道 2 ②）。
- npm 镜像版本可能滞后，装/升级用 `--registry=https://registry.npmjs.org`。
