---
name: design-first-website
description: 设计先行的网站开发编排流程——用户想做网站/个人站/官网/落地页/作品集/landing page/portfolio 时使用。核心方法：先引导用户补齐设计必需信息、拆解参考网站（调用 website-to-design-md 提取设计规则）、产出 DESIGN.md 并等用户确认，确认后才写代码（调用 design-taste-frontend 等 taste 技能保证质量），最后浏览器对照走查。当用户说"做个网站""建个人站""帮我做官网/落地页""参考这个网站做一个""重新设计我的网站"时触发。不适用：纯后台/API 项目、已有明确设计稿的纯实现任务。
---

# design-first-website — 设计先行的网站开发编排

**铁律：DESIGN.md 未经用户确认，禁止写任何页面代码。** 本 skill 是编排层——引导、拆解、把关，具体能力调用下表已安装的技能。

## 技能编队（已安装，按需调用）

| 技能 | 何时调用 |
|---|---|
| `website-to-design-md` | 用户给了参考网站 URL → 提取设计规则成 DESIGN.md（⚠ 见下方"本机提取通道"） |
| `design-taste-frontend` | 实现阶段的质量标准（反 AI 味、三旋钮 VARIANCE/MOTION/DENSITY） |
| `image-to-code` | 用户给了参考截图/设计图 → 分析并转实现 |
| `imagegen-frontend-web` | 无任何参考 → 先生成网页意向图再定方向 |
| `imagegen-frontend-mobile` | 移动 App 界面场景 |
| `brandkit` | 需要品牌视觉板/logo 系统 |
| `redesign-existing-projects` | 改造已有网站/项目 |
| `minimalist-ui` | 用户明确要极简编辑风 |

## 工作流（5 阶段，两道门禁）

### P0 · 问诊（缺什么问什么，别轰炸）
读 [references/intake-questions.md](references/intake-questions.md)。用户已说清的**不重复问**；核心缺口用 AskUserQuestion 分组补齐：表达什么/给谁看/站型/参考情况/动效档位/内容清单。
**站型分支**在此定：①纯展示静态站（个人站/作品集/落地页）②内容平台站（带后台/工具集/课程 → 后续交接 ai-content-site-kit）。

### P1 · 参考拆解（按用户拥有的参考类型走）
- **有参考 URL**（1-3 个）：逐个调用 `website-to-design-md` 提取设计规则。多参考时执行**三参考法**：1 个主参考定气质，其余只借局部（首屏/字体/动效各认领）——先问清每个参考的角色。
- **有参考截图**：按 `image-to-code` 的分析流程提取设计语言（只到 DESIGN.md，不直接写码）。
- **无参考**：给用户看 [references/reference-galleries.md](references/reference-galleries.md) 挑 1-3 个；或调 `imagegen-frontend-web` 生成意向图供用户选方向。
- **版权边界（必须告知用户）**：参考只借风格——不复制对方 logo、品牌文案、图片素材和完整页面结构。

### P2 · DESIGN.md 合成 → ⛔ 门禁一
把 P0 需求 + P1 拆解合成一份 DESIGN.md：结构用 `website-to-design-md` 的模板（`~/.claude/skills/website-to-design-md/assets/DESIGN.template.md`），并**必须**补上模板没有的三节：①这个站要表达什么/给谁看 ②每个参考学什么/不学什么 ③不要做什么（AI 味黑名单，取自 `design-taste-frontend`）。
用普通人能懂的话写。**写完即停**，按 [references/design-md-checklist.md](references/design-md-checklist.md) 引导用户逐项确认；用户要改就改 DESIGN.md，不许"顺手先写点代码"。

### P3 · 实现（确认后才进入）
- 施工纪律：严格按 DESIGN.md；**不新增主色**；不抄参考的品牌素材；桌面+移动双端；实现质量执行 `design-taste-frontend` 标准；单次写入 ≤10k 字符（预超先拆分片）；小步 commit。
- **静态站**：直接实现（单页或少页，无构建优先）。
- **内容平台站**：读 [references/build-handoff.md](references/build-handoff.md) 交接 `E:\AICoding\templates\ai-content-site-kit\`（DESIGN.md 喂它的 ds.css 变量层，工程按其 P0-P7 施工）。
- **改造存量**：调 `redesign-existing-projects` 流程。

### P4 · 走查循环 → ⛔ 门禁二
起本地服务 → 用内置浏览器打开 → 按 [references/review-loop.md](references/review-loop.md)：对照 DESIGN.md 截图列 **5 个具体问题**（首屏表达/颜色跑偏/字级层次/卡片模板感/素材占位感/移动端溢出）→ 逐项修改。
**禁止**"不好看→整个重做"；素材问题走素材规格单（review-loop 内），不硬改 CSS 糊弄。
完成标准：双端截图对照 DESIGN.md 无明显违背 + 用户点头。

## 本机提取通道（Windows 机实测，2026-07-22）

`agent-browser` CLI 本机**可用**（0.32.3，open/eval/close/跨调用持久化实测全通）。P1 提取按优先级三通道，用法与故障恢复见 [references/extraction-fallback.md](references/extraction-fallback.md)：
1. **原版 CLI 直驱**（默认）：`agent-browser open/eval` 按原版 SKILL.md 流程走；
2. **结构化落盘**：`scripts/run-styleprobe.mjs <url> [out]`——复用原版 styleProbe，规避原版 .mjs 脚本在 Windows+Git Bash 的 which/spawnSync 通病；
3. **内置浏览器兜底**：仅 agent-browser 整体故障时用（明示降级，告知用户一句）。
命令挂起 >20 秒 = daemon 卡死（上游 #1118），按分册「卡死恢复手册」PID 精确清理后重试；提取时**禁用 `--debug`**（daemon 会随控制台死亡）。

## 与其他技能的边界

- `frontend-ui-design`（已有）：单独的界面实现质量技能；本 skill 是端到端流程，实现阶段的质量标准优先用 taste 编队。
- `app-dev-guide`：通用 App 开发流程；网站类需求走本 skill。
- `ai-content-site-kit`（模板库，非 skill）：内容平台站的工程蓝图，本 skill 的 P3 下游。
