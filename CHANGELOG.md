# CHANGELOG — design-first-website

## v1.0.1 (2026-07-22)

agent-browser 本机修复与提取通道重构。

- **诊断反转**：agent-browser 并非本机不可用——旧「全命令挂死」是上游 #1118 的 stale daemon 卡死态。0.32.3（已是最新）全新会话实测 open/eval/close/跨调用持久化全通（example.com + geopro.cc）。
- **新增** `scripts/run-styleprobe.mjs`：Windows 驱动器，运行时从原版脚本读 styleProbe（零 fork 零漂移）+ 直调 win32 exe。规避原版脚本两大 Windows+Git Bash 通病：① `command -v` 解析出 MSYS 路径 shell shim，spawnSync 无法执行；② 首命令孵化的 daemon 继承 stdio 管道句柄永不退出，spawnSync 等 EOF 死等（stdio:ignore 引导 + 逐命令超时解决）。
- **重写** references/extraction-fallback.md → 三通道手册（CLI 直驱 > run-styleprobe.mjs > 内置浏览器）+ daemon 卡死恢复手册（PID 精确清理）+ `--debug` 绑死控制台警示。
- **验证**：geopro.cc 双端证据 568KB（desktop 1440/48 变量/主标 69.12px；mobile 390×844/38px），与内置浏览器通道同日实测数值互证（docHeight 4420 vs 4423）。

## v1.0.0 (2026-07-22)

初版。设计先行的网站开发端到端编排 skill。

- **来源合成**：X 文章方法论（DESIGN.md 先行 + 确认门禁 + 三参考法 + 五问题走查，https://x.com/Jackywxsz/status/2072614425660731498）+ taste-skill 编队（7 个已装子技能）+ website-to-design-md（参考站提取）+ ai-content-site-kit（平台站工程蓝图，E:\AICoding\templates\ai-content-site-kit\）。
- **结构**：SKILL.md（5 阶段 P0 问诊→P1 参考拆解→P2 DESIGN.md+门禁一→P3 三路线实现→P4 走查+门禁二）+ 6 分册（intake-questions / reference-galleries / design-md-checklist / extraction-fallback / review-loop / build-handoff）。
- **本机适配**：agent-browser daemon 在本 Windows 机 IPC 挂死（上游 bug，2026-07-22 实测 0.32.3 doctor 过但 open/eval 挂起）→ extraction-fallback.md 记录明示降级通道：Claude Code 内置浏览器执行原版 styleProbe（extract-browser-evidence.mjs ~31-207 行），证据 JSON 与合成规则与原版一致。上游修复后删除该通道回归原版。
- **安装**：源 `E:\AICoding\claude-skills\design-first-website\`，装载 `C:\Users\YH\.claude\skills\design-first-website\`。依赖技能均已装于 `~/.claude/skills/`。
