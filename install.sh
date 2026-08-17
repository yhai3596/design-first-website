#!/usr/bin/env bash
# design-first-website — 一键安装本 skill 及其技能编队
#
#   bash install.sh              安装编排层 + 7 个编队技能 + website-to-design-md
#   bash install.sh --force      已存在的目录一律覆盖重装
#   bash install.sh --extras     额外装上游 taste-skill 里未被路由表引用的技能
#   bash install.sh --list       只打印将要安装什么，不动文件
#
# 安装位置：$CLAUDE_SKILLS_DIR，默认 ~/.claude/skills
# 平台：macOS / Linux / Windows(Git Bash)。依赖：git；agent-browser 为可选增强。

set -euo pipefail

SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
TASTE_REPO="https://github.com/Leonxlnx/taste-skill.git"
W2D_REPO="https://github.com/Paidax01/web-to-design-md.git"

FORCE=0
EXTRAS=0
DRYRUN=0
for arg in "$@"; do
  case "$arg" in
    --force)  FORCE=1 ;;
    --extras) EXTRAS=1 ;;
    --list)   DRYRUN=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "未知参数：$arg（--help 看用法）" >&2; exit 2 ;;
  esac
done

# 上游 taste-skill 的目录名与 SKILL.md frontmatter 里的 name 不一致，
# 而 Claude Code 按目录名装载 —— 必须按 name 重命名，否则路由表调不到。
# 格式：<仓库子目录>:<安装后的技能名>
TASTE_MAP="
taste-skill:design-taste-frontend
image-to-code-skill:image-to-code
imagegen-frontend-web:imagegen-frontend-web
imagegen-frontend-mobile:imagegen-frontend-mobile
brandkit:brandkit
redesign-skill:redesign-existing-projects
minimalist-skill:minimalist-ui
"

TASTE_EXTRAS="
soft-skill:high-end-visual-design
brutalist-skill:industrial-brutalist-ui
stitch-skill:stitch-design-taste
gpt-tasteskill:gpt-taste
output-skill:full-output-enforcement
taste-skill-v1:design-taste-frontend-v1
"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  ✓ %s\n' "$*"; }
skip() { printf '  · %s（已存在，--force 覆盖）\n' "$*"; }

install_dir() { # <源目录> <技能名>
  src="$1"; name="$2"; dst="$SKILLS_DIR/$name"
  if [ ! -f "$src/SKILL.md" ]; then
    printf '  ! %s：源目录没有 SKILL.md，跳过（%s）\n' "$name" "$src" >&2
    return 0
  fi
  if [ -e "$dst" ] && [ "$FORCE" -eq 0 ]; then
    skip "$name"; return 0
  fi
  if [ "$DRYRUN" -eq 1 ]; then ok "$name（--list，未写入）"; return 0; fi
  rm -rf "$dst"
  cp -R "$src" "$dst"
  rm -rf "$dst/.git"
  ok "$name"
}

install_map() { # <仓库根> <映射表>
  root="$1"; map="$2"
  printf '%s\n' "$map" | while IFS= read -r line; do
    [ -z "$line" ] && continue
    install_dir "$root/skills/${line%%:*}" "${line##*:}"
  done
}

command -v git >/dev/null 2>&1 || { echo "需要 git，未找到。" >&2; exit 1; }
mkdir -p "$SKILLS_DIR"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say "安装目标：$SKILLS_DIR"
say ""

# 1. 编排层本身（从当前 clone 就地安装，不再联网拉一遍）
SELF="$(cd "$(dirname "$0")" && pwd)"
say "编排层："
if [ "$SELF" = "$SKILLS_DIR/design-first-website" ]; then
  ok "design-first-website（已在安装位置，原地使用）"
else
  install_dir "$SELF" "design-first-website"
fi
say ""

# 2. taste 编队（7 个，路由表引用）
say "taste 编队（Leonxlnx/taste-skill · MIT）："
git clone --quiet --depth 1 "$TASTE_REPO" "$TMP/taste"
install_map "$TMP/taste" "$TASTE_MAP"
if [ "$EXTRAS" -eq 1 ]; then
  say ""
  say "  额外技能（--extras，路由表未引用）："
  install_map "$TMP/taste" "$TASTE_EXTRAS"
fi
say ""

# 3. 参考站提取
say "参考站提取（Paidax01/web-to-design-md）："
git clone --quiet --depth 1 "$W2D_REPO" "$TMP/w2d"
install_dir "$TMP/w2d" "website-to-design-md"
say ""

# 4. 环境自检
say "环境自检："
if command -v node >/dev/null 2>&1; then
  ok "node $(node -v)"
else
  say "  ! 未装 node —— scripts/run-styleprobe.mjs（提取通道 2）不可用"
fi
if command -v agent-browser >/dev/null 2>&1; then
  ok "agent-browser $(agent-browser --version 2>/dev/null | head -1)"
  if [ -d "$HOME/.agent-browser/browsers" ]; then
    ok "agent-browser 的 Chrome 已就位"
  else
    say "  ! agent-browser 装了但没拉 Chrome —— open 会报 Chrome not found"
    say "    补一步：agent-browser install"
  fi
else
  say "  · 未装 agent-browser —— 参考站提取会走内置浏览器兜底通道（精度降一档）"
  say "    想要完整精度：npm i -g agent-browser && agent-browser install"
fi
say ""

if [ "$DRYRUN" -eq 1 ]; then
  say "（--list 模式，未写入任何文件）"
  exit 0
fi

say "完成。已装技能："
for d in "$SKILLS_DIR"/*/; do
  [ -f "$d/SKILL.md" ] || continue
  n="$(sed -n 's/^name: *//p' "$d/SKILL.md" | head -1)"
  printf '  %-32s %s\n' "$(basename "$d")" "${n:+→ $n}"
done
say ""
say "新开一个 Claude Code 会话即可触发：说「帮我做个个人网站」试试。"
