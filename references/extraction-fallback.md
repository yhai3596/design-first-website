# 提取通道手册（agent-browser 用法 + 故障恢复）

`website-to-design-md` 的提取在本机（YH 的 Windows 机）按以下优先级执行。2026-07-22 实测：agent-browser 0.32.3 CLI **本机可用**——此前「全命令挂死」是 stale daemon 卡死态（见恢复手册），不是安装或平台问题。

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

运行时从原版脚本提取 styleProbe（零 fork、原版更新自动跟随），直调 win32 真身 exe，产出 `{url, capturedAt, pages:{desktop,mobile}, tooling}`。实测 geopro.cc 双端 568KB。

**为何不用原版自带 extract-browser-evidence.mjs**（Windows+Git Bash 通病，非本机特有）：
① 它用 `bash -lc "command -v agent-browser"` 解析到 MSYS 路径的 shell shim（`/c/.../agent-browser`），`spawnSync` 在 Windows 无法执行该路径；
② 会话首命令孵化的 daemon 会继承调用方 stdio 管道句柄且永不退出 → spawnSync 等管道 EOF 无限挂。驱动器用「`stdio:"ignore"` 引导 daemon + 逐命令超时」解决。

## 通道 3（兜底）：内置浏览器 + 原版 styleProbe

仅当 agent-browser 整体故障且恢复手册无效时，并告知用户一句（明示降级）：
Read 原版脚本取 styleProbe（`const styleProbe = \`...\``，~31-213 行）→ `preview_start {url}` → `resize_window 1440x1400` → `javascript_tool` 执行探针——**结果存 `window.__dfw_evidence` 只回摘要**（完整 JSON 实测 236k 字符，整包过工具返回会爆）→ `resize_window mobile` 再测一轮。合成环节与原版零差异。

## daemon 卡死恢复手册（上游 issue #1118）

**症状**：任何命令（含 `close`）挂起 >20 秒零输出；`--help` 却正常。
**原因**：中断/并发会话留下卡死 daemon，CLI 连上去永久等待，上游无自愈。
**处置**（PID 精确操作，禁止按进程名批杀）：
1. `tr -d '\r\n' < ~/.agent-browser/<会话>.pid` 取 PID
2. `tasklist //FI "PID eq <PID>"` 确认是 agent-browser-win32-x64.exe
3. `taskkill //F //PID <PID>`，然后 `rm ~/.agent-browser/<会话>.*`
4. 重试（daemon 按需重生）。**别动其他会话**（如 idema-*，属其他项目）。

## 已知坑

- **`--debug` 让 daemon 绑死调用控制台**：控制台一关 daemon 即死、页面状态丢（实测）。调试完必须去掉。
- `timeout N` 包装无害（实测不影响持久化）。
- 脚本化调用（spawnSync/execFile）首命令必须 `stdio:"ignore"` 引导（见通道 2 ②）。
- npm 镜像版本可能滞后，装/升级用 `--registry=https://registry.npmjs.org`（本机 0.32.3 已是最新）。
