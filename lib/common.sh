#!/usr/bin/env bash
# 共享常量与函数：供 install.sh / tools/validate.sh source
# skill 命名规则（必须与目录名一致；Claude Code / OpenCode 双工具要求）
NAME_RE='^[a-z0-9]+(-[a-z0-9]+)*$'

# 校验 skill 名合规 → 返回 0 合规 / 1 不合规
validate_skill_name() {
  [[ "$1" =~ $NAME_RE ]]
}

# 从 markdown frontmatter（首个 --- 块）取字段值
# 用法: get_frontmatter_field <file> <key>
get_frontmatter_field() {
  awk -v k="$2" '
    /^---$/{c++; next}
    c==1 && $0 ~ "^[[:space:]]*" k ":" {
      sub("^[[:space:]]*" k ":[[:space:]]*", "")
      print; exit
    }' "$1"
}
