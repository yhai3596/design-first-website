# CHANGELOG — design-first-website

## v1.1.0 (2026-08-16)

可移植化：从"作者本机能跑"变成"别人 clone 下来就能跑"。

- **新增** `install.sh`：一键装编排层 + 7 个 taste 编队技能 + website-to-design-md，含 `--list` / `--force` / `--extras`，装点可用 `CLAUDE_SKILLS_DIR` 覆盖。幂等（已存在默认跳过），末尾打印 目录名→frontmatter name 对照表 + 环境自检。macOS 实测装载 9 个技能、复跑全部正确跳过。
- **修复安装陷阱**：上游 taste-skill 有 4 个子目录名与 SKILL.md 的 `name` 不一致（`taste-skill`→`design-taste-frontend`、`redesign-skill`→`redesign-existing-projects`、`minimalist-skill`→`minimalist-ui`、`image-to-code-skill`→`image-to-code`）。Claude Code 按目录名装载，照原名 `cp` 会导致本 skill 路由表全部调不到——install.sh 按 name 重命名，README 也把手动安装的对照表列全。
- **去本机化**：承接 v1.0.2 的 kit 公开发布，build-handoff 路线 B 重写为「公开仓库 URL 优先 → `$AI_CONTENT_SITE_KIT` 本地 clone → 都没有时的显式降级方案」（原先只有 `E:\` 硬编码）；「本机规则 5.6/5.7/5.8」等外部引用 → 就地写清规则本身；SKILL.md「本机提取通道（Windows 机实测）」→ 平台无关的「提取通道」+ 开工自检；`frontend-ui-design`/`app-dev-guide`/模板库 三项明确标注不随仓库分发、缺失即跳过。
- **run-styleprobe.mjs 正名**：本就有非 win32 分支（`resolveAgentBrowser` 直接返回 PATH 里的 `agent-browser`），文档却一路称"Windows 驱动器"劝退了其他平台的用户。头注释与 README 改为跨平台，`tooling.mode` 改 `agent-browser-cli-driver` 并记录 `platform`。
- **新坑记录**：`npm i -g agent-browser` 之后必须再跑 `agent-browser install` 拉 Chrome。漏了这步 `--version` 正常但 `open` 报 `Chrome not found`（macOS 实测），极易误判成"装好了"。install.sh 自检 `~/.agent-browser/browsers` 并提示补装。

## v1.0.2 (2026-08-17)

第三方完整化：外部环境可完整安装并调用全链路。

- **发布依赖套件**：ai-content-site-kit 公开至 https://github.com/yhai3596/ai-content-site-kit（本地 E:\AICoding\templates\ 目录在仓库重组中已消失，自会话转录重放 Write/Edit 恢复全部 9 文件后发布；kit 内本地路径引用全部改为公开仓库 URL，参考实现指向 yhai3596/alan-platform）。
- **去本地化**：SKILL.md P3 与 build-handoff.md 对 kit 的 E:\ 本地路径 → GitHub URL；「与其他技能的边界」节标注按作者环境划界。
- **README 完整安装清单**：本体 + web-to-design-md + taste 编队 7 技能（上游子目录名→技能名的映射安装命令，实测目录名核对）+ agent-browser（可选）+ kit（按需）。

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
