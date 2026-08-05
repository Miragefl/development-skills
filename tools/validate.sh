#!/usr/bin/env bash
# 校验 skills/ 下每个 SKILL.md：name 合规、与目录名一致、description 非空
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "${ROOT}/lib/common.sh"
SKILLS_DIR="${ROOT}/skills"

# 校验单个 skill 目录 → 0 通过（打印 OK）/ 1 有问题（已打印 FAIL 原因）
validate_one_skill() {
  local dir="$1"
  local name; name="$(basename "$dir")"
  local skill_file="${dir}/SKILL.md"
  [ -f "$skill_file" ] || { echo "FAIL: ${name} missing SKILL.md"; return 1; }
  validate_skill_name "$name" || { echo "FAIL: ${name} invalid name (must be lowercase kebab-case)"; return 1; }
  local fm_name; fm_name="$(get_frontmatter_field "$skill_file" name)"
  [ "$fm_name" = "$name" ] || { echo "FAIL: ${name}: frontmatter name '${fm_name}' != dir '${name}'"; return 1; }
  local desc; desc="$(get_frontmatter_field "$skill_file" description)"
  [ -n "$desc" ] || { echo "FAIL: ${name} empty description"; return 1; }
  echo "OK: ${name}"
}

main() {
  [ -d "$SKILLS_DIR" ] || { echo "FAIL: no skills/ dir at ${SKILLS_DIR}"; exit 1; }
  local global_fail=0 found=0
  for skill_dir in "$SKILLS_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    found=1
    validate_one_skill "$skill_dir" || global_fail=1
  done
  [ "$found" -eq 1 ] || { echo "FAIL: no skill dirs under skills/"; exit 1; }
  exit "$global_fail"
}

main "$@"
