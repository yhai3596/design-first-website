# 参考画廊与三参考法

## 用户无参考时：给画廊，让用户挑 1-3 个

按需求类型给对应画廊（给 2-3 个链接即可，别全灌）：

| 画廊 | 地址 | 适合 |
|---|---|---|
| Refero Styles | https://styles.refero.design | 按风格标签（minimal/brutalist/editorial…）浏览真实网站，**首选** |
| Land-book | https://land-book.com | landing page 大全 |
| Lapa Ninja | https://www.lapa.ninja | landing page，带配色标签 |
| Minimal Gallery | https://minimal.gallery | 极简站 |
| Collect UI | https://collectui.com | 单个 UI 元素/组件灵感 |
| Mobbin | https://mobbin.com | App/Web 界面模式库（部分需登录） |
| Page Flows | https://pageflows.com | 交互流程录屏（部分付费） |
| Recent.design | https://recent.design | 最新优秀设计 |

动效实现阶段可参考：React Bits（https://reactbits.dev，React 动效组件）、GSAP（滚动/时间线动效）。

引导话术：「打开 Refero Styles 挑 1-3 个你看着舒服的网站，把网址发我。不用管它是什么行业——我们借的是气质不是内容。」

用户挑不动 → 调 `imagegen-frontend-web` 按问诊结论生成 2-3 张不同方向的首屏意向图，让用户选。

## 三参考法（多参考时必须执行）

超过 1 个参考时，**先分工再拆解**，防止缝合怪：

- **1 个主参考**：定整体气质——颜色体系、留白密度、字体感觉都跟它走。
- **≤2 个局部参考**：各自只认领一件事（如"只学它的首屏排版"/"只学它的卡片悬停动效"/"只学它的字体搭配"）。
- 分工由用户确认：「A 定整体，B 只借首屏，C 只借动效，对吗？」——写入 DESIGN.md 的「参考学什么/不学什么」节。
- 超过 3 个参考 → 请用户砍到 3 个以内。参考越多越平庸。

## 版权红线（拆解前告知用户一次）

参考只借**风格**：色彩关系、留白节奏、字级对比、动效手感。
**不碰**：对方 logo、品牌名与文案、图片/插画素材、完整页面结构 1:1 复刻。同行业参考尤其注意——像素级像同行的站是事故不是效率。
