# design-first-website

设计先行的网站开发编排 Skill（Claude Code）。核心铁律一句话：**DESIGN.md 未经用户确认，禁止写任何页面代码。**

用户只需给出想法和参考网站，skill 负责把「审美决策」前置成一份可确认的 DESIGN.md，确认后才进入实现，最后按设计文档逐项走查——避免 AI 直接上手写出「AI 味」模板站。

## 流程（5 阶段 · 两道门禁）

```
P0 问诊          缺什么问什么：表达什么/给谁看/站型/参考/动效/素材
P1 参考拆解      URL → website-to-design-md 提取；截图 → image-to-code；
                 无参考 → 画廊挑选或 imagegen 生成意向图；多参考走三参考法
P2 DESIGN.md     十二节合成 → ⛔ 门禁一：逐项确认，不许"顺手先写点代码"
P3 实现          静态直建 / 内容平台交接 / 存量改造；不新增主色、双端适配
P4 走查循环      浏览器双端截图对照 DESIGN.md 列 5 个具体问题 → 逐项修
                 → ⛔ 门禁二：禁止推倒重写，素材问题走素材规格单
```

## 安装

```bash
git clone https://github.com/yhai3596/design-first-website.git ~/.claude/skills/design-first-website
```

本 skill 是**编排层**，调用以下技能编队（需另行安装到 `~/.claude/skills/`）：

| 编队技能 | 来源 |
|---|---|
| design-taste-frontend / image-to-code / imagegen-frontend-web / imagegen-frontend-mobile / brandkit / redesign-existing-projects / minimalist-ui | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| website-to-design-md（参考站 → DESIGN.md 提取） | [Paidax01/web-to-design-md](https://github.com/Paidax01/web-to-design-md) |

参考站提取依赖 [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser)（可选；不装则走内置浏览器兜底通道）。

## 文件地图

- `SKILL.md` — 编排主文件：5 阶段、门禁、技能路由表
- `references/intake-questions.md` — P0 问诊题库（缺什么问什么，不轰炸）
- `references/reference-galleries.md` — 参考画廊清单 + 三参考法 + 版权红线
- `references/design-md-checklist.md` — DESIGN.md 十二节清单 + 确认门禁话术
- `references/extraction-fallback.md` — 提取三通道手册 + agent-browser 卡死恢复手册（真实 Windows 排错沉淀）
- `references/review-loop.md` — 五问题走查法 + 素材规格单
- `references/build-handoff.md` — 实现三路线（静态直建 / 平台站交接 / 存量改造）
- `scripts/run-styleprobe.mjs` — Windows 提取驱动器：运行时复用 web-to-design-md 的 styleProbe 探针、直调 agent-browser win32 exe（规避原脚本在 Windows+Git Bash 的 which/spawnSync 通病）

## 方法论来源

- DESIGN.md 先行 + 确认门禁 + 三参考法 + 五问题走查：来自 [@Jackywxsz 的方法论文章](https://x.com/Jackywxsz/status/2072614425660731498)
- 反 AI 味实现质量：taste-skill 编队
- 参考站逆向：web-to-design-md

## 说明

文档中的排错手册（stale daemon 恢复、`--debug` 坑位等）来自一台真实 Windows + Git Bash 机器的实测记录，个别路径为该机器写法（如 `C:\Users\YH`），换机使用时按自己环境对应即可——结论本身（上游 [#1118](https://github.com/vercel-labs/agent-browser/issues/1118) 卡死态、spawnSync 管道继承等）是平台通用的。

## License

MIT
