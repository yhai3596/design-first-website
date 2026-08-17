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

本 skill 是**编排层**，本身不干活——它把活分给一支技能编队。一键装齐编排层 + 全部编队：

```bash
git clone https://github.com/yhai3596/design-first-website.git && bash design-first-website/install.sh
```

装到 `~/.claude/skills/`（`CLAUDE_SKILLS_DIR` 可改）。脚本幂等，已存在的目录默认跳过。

| 参数 | 作用 |
|---|---|
| `--list` | 只打印将要装什么，不写文件 |
| `--force` | 已存在的目录一律覆盖重装（升级用） |
| `--extras` | 额外装 taste-skill 里未被路由表引用的 6 个技能 |

### 编队清单（脚本装的就是这些）

| 安装后的技能名 | 来源仓库 | 仓库内目录 |
|---|---|---|
| `design-taste-frontend` | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) · MIT | `skills/taste-skill` |
| `image-to-code` | 同上 | `skills/image-to-code-skill` |
| `imagegen-frontend-web` | 同上 | `skills/imagegen-frontend-web` |
| `imagegen-frontend-mobile` | 同上 | `skills/imagegen-frontend-mobile` |
| `brandkit` | 同上 | `skills/brandkit` |
| `redesign-existing-projects` | 同上 | `skills/redesign-skill` |
| `minimalist-ui` | 同上 | `skills/minimalist-skill` |
| `website-to-design-md` | [Paidax01/web-to-design-md](https://github.com/Paidax01/web-to-design-md) | 仓库根 |

> ⚠️ taste-skill 里有 4 个子目录名和 SKILL.md frontmatter 的 `name` 对不上（`taste-skill` → `design-taste-frontend`、`redesign-skill` → `redesign-existing-projects`、`minimalist-skill` → `minimalist-ui`、`image-to-code-skill` → `image-to-code`）。Claude Code 按目录名装载，照原目录名 `cp` 会让本 skill 的路由表**静默**调不到它们。install.sh 已按上表重命名。

<details>
<summary>不想用脚本？手动装齐同样的一套</summary>

```bash
git clone https://github.com/yhai3596/design-first-website.git ~/.claude/skills/design-first-website
git clone https://github.com/Paidax01/web-to-design-md.git ~/.claude/skills/website-to-design-md

git clone https://github.com/Leonxlnx/taste-skill.git ./taste-skill-src
for pair in taste-skill:design-taste-frontend image-to-code-skill:image-to-code \
  imagegen-frontend-web:imagegen-frontend-web imagegen-frontend-mobile:imagegen-frontend-mobile \
  brandkit:brandkit redesign-skill:redesign-existing-projects minimalist-skill:minimalist-ui; do
  cp -r "./taste-skill-src/skills/${pair%%:*}" ~/.claude/skills/"${pair##*:}"
done
```

</details>

### 可选增强：agent-browser

```bash
npm i -g agent-browser
agent-browser install     # 两步都要！只装 CLI 不拉 Chrome，open 会报 "Chrome not found"
```

参考站提取（P1）用 [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) 拿真实 DOM + computed styles + CSS 变量。**不装也能跑**，会自动降级到内置浏览器兜底通道（截图 + 有限探针），提取精度低一档。

### 按需：内容平台站的工程蓝图

P3「内容平台站」路线的下游套件 [yhai3596/ai-content-site-kit](https://github.com/yhai3596/ai-content-site-kit)——施工时 clone 到**项目工作区**即可（模板文档库，不装进 skills 目录）；参考实现见 [yhai3596/alan-platform](https://github.com/yhai3596/alan-platform)。做纯展示静态站用不到它。

### 不随本仓库分发的东西

SKILL.md 提到但**不包含**在内，本机没有就自动跳过、不影响主流程：`frontend-ui-design`、`app-dev-guide`（作者本机的其他 skill）。

## 文件地图

- `install.sh` — 一键安装编排层 + 全部编队（含目录名→技能名映射、环境自检）
- `SKILL.md` — 编排主文件：5 阶段、门禁、技能路由表
- `references/intake-questions.md` — P0 问诊题库（缺什么问什么，不轰炸）
- `references/reference-galleries.md` — 参考画廊清单 + 三参考法 + 版权红线
- `references/design-md-checklist.md` — DESIGN.md 十二节清单 + 确认门禁话术
- `references/extraction-fallback.md` — 提取三通道手册 + agent-browser 卡死恢复手册
- `references/review-loop.md` — 五问题走查法 + 素材规格单
- `references/build-handoff.md` — 实现三路线（静态直建 / 平台站交接 / 存量改造）
- `scripts/run-styleprobe.mjs` — 提取驱动器（跨平台）：运行时复用 web-to-design-md 的 styleProbe 探针，产出与原版同构的证据 JSON；Windows 上直调 agent-browser win32 exe，规避原脚本在 Git Bash 下的 which/spawnSync 通病

## 方法论来源

- DESIGN.md 先行 + 确认门禁 + 三参考法 + 五问题走查：来自 [@Jackywxsz 的方法论文章](https://x.com/Jackywxsz/status/2072614425660731498)
- 反 AI 味实现质量：taste-skill 编队
- 参考站逆向：web-to-design-md

## 说明

- **平台**：macOS / Linux / Windows(Git Bash) 都能跑。`install.sh` 只依赖 git + bash。
- **排错手册的来源**：`references/extraction-fallback.md` 里的 stale daemon 恢复、`--debug` 坑位等来自一台 Windows + Git Bash 机器的实测记录。结论本身（上游 [#1118](https://github.com/vercel-labs/agent-browser/issues/1118) 卡死态、spawnSync 管道继承等）平台通用，仅 Windows 特有的部分已在文中标注。
- **升级**：`git pull && bash install.sh --force`。

## License

MIT
