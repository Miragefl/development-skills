#!/usr/bin/env bash
# 安装 Java 开发 skills 到 Claude Code / OpenCode 共认目录
# 用法: ./install.sh [--opencode] [--project <path>] [--uninstall]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

SKILLS_SRC="${ROOT}/skills"
TEMPLATE="${ROOT}/PROJECT-CONTEXT.template.md"

OPENCODE=0
UNINSTALL=0
PROJECT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --opencode)  OPENCODE=1; shift;;
    --uninstall) UNINSTALL=1; shift;;
    --project)   PROJECT="${2:?--project needs a path}"; shift 2;;
    -h|--help)   sed -n '2,3p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

# 项目绝对路径只解析一次（消除重复 cd+pwd）
PROJECT_ABS=""
[ -n "$PROJECT" ] && PROJECT_ABS="$(cd "$PROJECT" && pwd)"

# 决定目标目录集合（写入全局 TARGETS）
# 全局: ~/.claude/skills（CC+OpenCode 共认）；--opencode 或卸载时加 OpenCode 专有目录
# 安装 opencode 是 opt-in；卸载是 sweep-all（两路径都清，避免装时带 --opencode、卸时忘带而残留）
resolve_targets() {
  TARGETS=()
  if [ -n "$PROJECT_ABS" ]; then
    TARGETS+=("${PROJECT_ABS}/.claude/skills")
  else
    TARGETS+=("${HOME}/.claude/skills")
    if [ "$OPENCODE" -eq 1 ] || [ "$UNINSTALL" -eq 1 ]; then
      TARGETS+=("${HOME}/.config/opencode/skills")
    fi
  fi
}

install_one() {
  local src="$1" dest_dir="$2"
  local name; name="$(basename "$src")"
  validate_skill_name "$name" || { echo "SKIP: ${name} 不符合命名规则" >&2; return 1; }
  mkdir -p "$dest_dir"
  rm -rf "${dest_dir}/${name}"
  if ln -s "$src" "${dest_dir}/${name}" 2>/dev/null; then
    echo "linked: ${dest_dir}/${name} -> ${src}"
  else
    cp -R "$src" "${dest_dir}/${name}"
    echo "copied: ${dest_dir}/${name} (软链不可用，回退复制)"
  fi
}

uninstall_one() {
  local src="$1" dest_dir="$2"
  local name; name="$(basename "$src")"
  validate_skill_name "$name" || return 1
  rm -rf "${dest_dir}/${name}"
  echo "removed: ${dest_dir}/${name}"
}

# 元信息模板：--project 模式拷到项目根；全局模式只提示
provision_template() {
  [ "$UNINSTALL" -eq 0 ] && [ -f "$TEMPLATE" ] || return 0
  if [ -n "$PROJECT_ABS" ]; then
    local dest_pc="${PROJECT_ABS}/PROJECT-CONTEXT.md"
    # ${dest_pc} 必须花括号：后跟全角"（"，否则 bash 把其字节并入变量名
    [ -f "${dest_pc}" ] || { cp "$TEMPLATE" "${dest_pc}"; echo "已创建: ${dest_pc}（请填写）"; }
  else
    echo "提示: 在你的 Java 项目根运行 'cp ${TEMPLATE} <project>/PROJECT-CONTEXT.md' 并填写"
  fi
}

main() {
  echo "== Java Skills $([ "$UNINSTALL" -eq 1 ] && echo 卸载 || echo 安装) =="
  local fail=0
  resolve_targets
  for src in "$SKILLS_SRC"/*/; do
    [ -d "$src" ] || continue
    [ -f "${src}SKILL.md" ] || { echo "SKIP: $(basename "$src") 无 SKILL.md" >&2; continue; }
    for t in "${TARGETS[@]}"; do
      if [ "$UNINSTALL" -eq 1 ]; then
        uninstall_one "$src" "$t" || fail=1
      else
        install_one "$src" "$t" || fail=1
      fi
    done
  done
  provision_template
  echo "== 完成 =="
  return "$fail"
}

main "$@"
