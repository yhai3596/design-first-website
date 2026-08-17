# P3 实现交接：三条路线

进入前提：DESIGN.md 顶部已有 `> 已确认` 标记。三条路线共同纪律见 SKILL.md P3。

## 路线 A：静态直建（个人站/作品集/落地页/官网）

- **无构建优先**：单 `index.html`（或少数几页）+ `assets/`，语义化 HTML + 原生 CSS + 少量 vanilla JS。不引 React/构建链，除非动效需求明确超出 CSS 能力。
- **CSS 变量先行**：第一步把 DESIGN.md 的颜色/字体/间距写成 `:root` 变量，全文只用变量——这是"不新增主色"的机械保障。
- 字体用系统栈或 1-2 个 webfont（中文注意字重子集与加载体积）。
- 图片就位再写对应区块；没到位的按素材规格单留明确占位并记账。
- 文件预计 >10k 字符 → 先拆（css 独立文件、区块分文件再拼），单次写入 ≤10k（本机规则 5.6）。

## 路线 B：内容平台站 → 交接 ai-content-site-kit

站型=内容平台（文章/工具集/课程/后台）时，工程蓝图不在本 skill——交接 [ai-content-site-kit](https://github.com/yhai3596/ai-content-site-kit)（本地无副本先 `git clone` 到项目工作区）：

1. **先读它的 `README.md`**，按其 AI 使用协议行事（那边有完整的读取顺序）。
2. **DESIGN.md 的落点**：本 skill 产出的 DESIGN.md 映射进 kit 的 `ds.css` 设计变量层（颜色/字体/间距 → CSS 变量；组件规则 → 其组件约定）。DESIGN.md 是设计事实源，kit 是工程事实源，冲突时设计问题以 DESIGN.md 为准、工程问题以 kit 铁律为准。
3. 施工顺序走 kit 的 `04-build-playbook.md`（P0-P7），铁律 `05-iron-laws.md` 全程有效（尤其"内容=数据库行，代码只播种一次"）。
4. 本 skill 的 P4 走查在 kit 的验收步骤之上叠加执行（五问题法照跑）。

## 路线 C：改造存量站

调用 `redesign-existing-projects`：先审计现状（它的 audit 流程），审计结论并入 DESIGN.md 的「参考学什么/不学什么」（现站保留什么/去掉什么），确认门禁照过，然后按其"不破坏功能"纪律定向改造。**不许**借改版之名重写业务逻辑。

## 交付收尾（三条路线通用）

- git 小步提交（每个可验证单元一次）。
- 部署按用户环境定：已有服务器（geopro.cc 模式：push + autopull）/ Vercel / 仅本地。部署验证要正向证据（curl 200 + 关键文案在响应里）。
- 项目根留 `DESIGN.md`（含确认标记）——它就是下次改版的起点文档。
