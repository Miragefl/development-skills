# Java 开发 Skills 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 交付一套精简的自有 Java 后端开发 skills（context / doc / flow），含跨工具安装脚本，Claude Code 与 OpenCode 双通用，作为独立 git 仓库分发。

**Architecture:** 三个职责单一的极简 SKILL.md（学 grill-me）+ 共享元信息底座 `PROJECT-CONTEXT.md`（学 grill-with-docs 的约定式文档）+ 一个分发到 `~/.claude/skills/`（双工具共认目录）的 install.sh。重的格式规范外置为 reference 文件，按需读取。

**Tech Stack:** Bash（install.sh / validate.sh）、Markdown（SKILL.md / 模板 / 文档）、YAML frontmatter（skill 元信息）。

## Global Constraints

- **Skill 命名规则**：`name` 必须 `^[a-z0-9]+(-[a-z0-9]+)*$`，1–64 字符，且与所在目录名完全一致（双工具一致要求）。本仓库三个 skill 名定为 `context`、`doc`、`flow`。
- **Frontmatter**：每个 SKILL.md 必须以 YAML frontmatter 开头，含 `name`（必填）与 `description`（必填，1–1024 字符，需具体到能正确触发）。未知字段两工具均忽略。
- **跨工具发现**：OpenCode 原生扫描 `~/.claude/skills/<name>/SKILL.md` 与 `.claude/skills/<name>/SKILL.md`，故默认装到 `~/.claude/skills/` 即双工具通用；`--opencode` 额外写入 `~/.config/opencode/skills/` 做双保险。
- **精简原则**：主 SKILL.md 控制在数十行；格式规范等重内容外置 reference 文件；懒加载（有料才建文件）。
- **元信息权威源**：目标项目根的 `PROJECT-CONTEXT.md` 是所有 skill 的唯一项目事实来源；能扫代码确认的事实不向用户发问。
- **文档路径约定（写死）**：接口→`<doc_root>/api/`、数据模型→`<doc_root>/data-model/`、DB脚本→`<doc_root>/db/`；`doc_root` 默认 `docs/`。
- **多栈兼容**：构建工具（Maven/Gradle）、DB 方言、ORM（JPA/MyBatis/MyBatis-Plus）须自动识别。
- **Git 约束**：本仓库当前**非 git 仓库**，且用户全局规则要求**不主动执行 git 操作**。各 task 末尾的 Commit 步骤为**可选**——仅当用户已授权 `git init` 并允许提交时执行；否则跳过 commit，仅保留文件落地。
- **LICENSE**：默认 MIT，copyright holder 取 `git config user.name`（无 git 时用 `Contributors`），年份 2026。

---

## File Structure

| 文件 | 职责 | 创建于 Task |
|---|---|---|
| `tools/validate.sh` | 校验所有 SKILL.md 的 name 合规、与目录名一致、description 非空；后续 task 的"测试"基础 | Task 1 |
| `LICENSE` | MIT 协议 | Task 1 |
| `.gitignore` | 忽略 OS/编辑器临时文件 | Task 1 |
| `install.sh` | 跨工具安装（软链/复制、--opencode/--project/--uninstall、name 校验、幂等） | Task 2 |
| `PROJECT-CONTEXT.template.md` | 元信息模板（拷到目标项目根改填） | Task 3 |
| `skills/context/SKILL.md` | 元信息守护 skill | Task 3 |
| `skills/doc/SKILL.md` | 文档自动生成 skill（主文件） | Task 4 |
| `skills/doc/DOC-FORMATS.md` | 三类文档格式规范（reference，按需读取） | Task 4 |
| `skills/flow/SKILL.md` | 轻量开发流程 skill | Task 5 |
| `README.md` | 项目说明 / 安装 / 使用 / 触发场景 | Task 6 |
| `docs/design/specs/2026-08-05-java-skills-design.md` | 设计文档（已存在） | — |
| `docs/design/plans/2026-08-05-java-skills.md` | 本计划（已存在） | — |

**分解理由**：每个 task 产出可独立校验的交付物，且能被 `validate.sh` 或显式检查点验证。Task 间依赖线性：骨架(1) → install.sh(2) → 三个 skill(3,4,5) → README(6) → 端到端验证(7)。

---

### Task 1: 仓库骨架与 skill 校验脚本

**Files:**
- Create: `tools/validate.sh`
- Create: `LICENSE`
- Create: `.gitignore`

**Interfaces:**
- Produces: `tools/validate.sh` —— 退出码 0 表示所有 skill 合规，非 0 表示有违规；被 Task 3/4/5 当作"测试"调用。

- [ ] **Step 1: 创建目录骨架**

```bash
cd /Users/viscum/Documents/code/justfun/ai/java-development-skills
mkdir -p skills/context skills/doc skills/flow tools
```

- [ ] **Step 2: 写校验脚本 `tools/validate.sh`**

```bash
cat > tools/validate.sh <<'EOF'
#!/usr/bin/env bash
# 校验 skills/ 下每个 SKILL.md：name 合规、与目录名一致、description 非空
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
fail=0
[ -d "$SKILLS_DIR" ] || { echo "FAIL: no skills/ dir at $SKILLS_DIR"; exit 1; }
shopt -s nullglob
found=0
for skill_dir in "$SKILLS_DIR"/*/; do
  found=1
  name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || { echo "FAIL: $name missing SKILL.md"; fail=1; continue; }
  if ! echo "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    echo "FAIL: $name invalid name (must match ^[a-z0-9]+(-[a-z0-9]+)*$)"; fail=1; continue
  fi
  fm_name="$(awk '/^---$/{c++; next} c==1 && /^[[:space:]]*name:/{sub(/^[[:space:]]*name:[[:space:]]*/,""); print; exit}' "$skill_file")"
  [ "$fm_name" = "$name" ] || { echo "FAIL: $name: frontmatter name '$fm_name' != dir '$name'"; fail=1; }
  desc="$(awk '/^---$/{c++; next} c==1 && /^[[:space:]]*description:/{sub(/^[[:space:]]*description:[[:space:]]*/,""); print; exit}' "$skill_file")"
  [ -n "$desc" ] || { echo "FAIL: $name empty description"; fail=1; }
  [ "$fail" -eq 0 ] && echo "OK: $name"
done
[ "$found" -eq 1 ] || { echo "FAIL: no skill dirs under skills/"; exit 1; }
exit $fail
EOF
chmod +x tools/validate.sh
```

- [ ] **Step 3: 运行校验脚本，验证它在空 skill 目录上"失败"**

```bash
./tools/validate.sh
```
Expected: `FAIL: context missing SKILL.md`（及 doc/flow 同样报错），退出码非 0。这确认测试本身能捕获缺失。

- [ ] **Step 4: 写 `.gitignore`**

```bash
cat > .gitignore <<'EOF'
.DS_Store
*.swp
*.swo
.idea/
.vscode/
EOF
```

- [ ] **Step 5: 写 `LICENSE`（MIT）**

```bash
HOLDER="$(git config user.name 2>/dev/null || echo Contributors)"
cat > LICENSE <<EOF
MIT License

Copyright (c) 2026 $HOLDER

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

- [ ] **Step 6: （可选，需 git 授权）Commit**

```bash
git add tools/validate.sh LICENSE .gitignore
git commit -m "chore: add repo skeleton and skill validator"
```

---

### Task 2: install.sh 跨工具安装脚本

**Files:**
- Create: `install.sh`

**Interfaces:**
- Consumes: `skills/<name>/SKILL.md`（Task 3/4/5 产出，本 task 先用占位目录测安装逻辑）
- Produces: `install.sh` —— 支持 `./install.sh [--opencode|--project <path>|--uninstall]`，退出码 0 成功。

- [ ] **Step 1: 写 `install.sh`**

```bash
cat > install.sh <<'EOF'
#!/usr/bin/env bash
# 安装 Java 开发 skills 到 Claude Code / OpenCode 共认目录
# 用法: ./install.sh [--opencode] [--project <path>] [--uninstall]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$ROOT/skills"
TEMPLATE="$ROOT/PROJECT-CONTEXT.template.md"
NAME_RE='^[a-z0-9]+(-[a-z0-9]+)*$'

OPENCODE=0
UNINSTALL=0
PROJECT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --opencode) OPENCODE=1; shift;;
    --uninstall) UNINSTALL=1; shift;;
    --project) PROJECT="${2:?--project needs a path}"; shift 2;;
    -h|--help)
      sed -n '2,4p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

# 决定目标根目录列表
TARGETS=()
if [ -n "$PROJECT" ]; then
  TARGETS+=("$(cd "$PROJECT" && pwd)/.claude/skills")
else
  TARGETS+=("$HOME/.claude/skills")
  [ "$OPENCODE" -eq 1 ] && TARGETS+=("$HOME/.config/opencode/skills")
fi

link_one() {
  local src="$1" dest_dir="$2"
  local name; name="$(basename "$src")"
  if ! echo "$name" | grep -Eq "$NAME_RE"; then
    echo "SKIP: $name 不符合命名规则" >&2; return 1
  fi
  mkdir -p "$dest_dir"
  if [ "$UNINSTALL" -eq 1 ]; then
    rm -f "$dest_dir/$name" "$dest_dir/$name/SKILL.md" 2>/dev/null
    rm -rf "$dest_dir/$name" 2>/dev/null
    echo "removed: $dest_dir/$name"; return 0
  fi
  rm -rf "$dest_dir/$name"
  if ln -s "$src" "$dest_dir/$name" 2>/dev/null; then
    echo "linked: $dest_dir/$name -> $src"
  else
    cp -R "$src" "$dest_dir/$name"
    echo "copied: $dest_dir/$name (软链不可用，回退复制)"
  fi
}

echo "== Java Skills $([ "$UNINSTALL" -eq 1 ] && echo 卸载 || echo 安装) =="
for src in "$SKILLS_SRC"/*/; do
  [ -d "$src" ] || continue
  [ -f "$src/SKILL.md" ] || { echo "SKIP: $(basename "$src") 无 SKILL.md" >&2; continue; }
  for t in "${TARGETS[@]}"; do link_one "$src" "$t" || true; done
done

# 拷贝元信息模板到目标项目根（仅安装、仅 --project 或默认全局时提示）
if [ "$UNINSTALL" -eq 0 ] && [ -f "$TEMPLATE" ]; then
  if [ -n "$PROJECT" ]; then
    dest_pc="$(cd "$PROJECT" && pwd)/PROJECT-CONTEXT.md"
    [ -f "$dest_pc" ] || { cp "$TEMPLATE" "$dest_pc"; echo "已创建: $dest_pc（请填写）"; }
  else
    echo "提示: 在你的 Java 项目根运行 'cp $TEMPLATE <project>/PROJECT-CONTEXT.md' 并填写"
  fi
fi
echo "== 完成 =="
EOF
chmod +x install.sh
```

- [ ] **Step 2: 用临时假目录测安装逻辑（此时 skills/ 下尚无 SKILL.md，应 SKIP）**

```bash
./install.sh
```
Expected: 输出含 `SKIP: context 无 SKILL.md`（三个都 SKIP），`== 完成 ==`，退出码 0。确认脚本本身可运行、参数解析正常。

- [ ] **Step 3: 测 `--project` 与幂等（建一个最小假 skill 验证软链）**

```bash
# 临时造一个合规 skill 用于测安装机制
mkdir -p /tmp/jstk-test-skill
printf -- '---\nname: jstk-test-skill\ndescription: temp test\n---\ntmp\n' > skills/context/SKILL.md.testonly
# 用真实机制验证：临时给 context 放真 SKILL.md
printf -- '---\nname: context\ndescription: temp\n---\ntmp\n' > skills/context/SKILL.md
TESTPROJ="$(mktemp -d)"
./install.sh --project "$TESTPROJ"
test -d "$TESTPROJ/.claude/skills/context" && echo "PASS: 装入成功"
# 幂等：再装一次不报错
./install.sh --project "$TESTPROJ" && echo "PASS: 幂等"
# 卸载
./install.sh --project "$TESTPROJ" --uninstall
test ! -e "$TESTPROJ/.claude/skills/context" && echo "PASS: 卸载干净"
# 清理临时真 SKILL.md（Task 3 会写正式版）
rm -f skills/context/SKILL.md skills/context/SKILL.md.testonly
rm -rf /tmp/jstk-test-skill "$TESTPROJ"
```
Expected: 三处 `PASS`。验证安装/幂等/卸载机制正常。

- [ ] **Step 4: （可选，需 git 授权）Commit**

```bash
git add install.sh
git commit -m "feat: add cross-tool install.sh (claude code + opencode)"
```

---

### Task 3: context skill + PROJECT-CONTEXT 模板

**Files:**
- Create: `PROJECT-CONTEXT.template.md`
- Create: `skills/context/SKILL.md`
- Test: `./tools/validate.sh`（应从 FAIL 转 OK）

**Interfaces:**
- Consumes: 目标项目根 `PROJECT-CONTEXT.md`（运行期由 AI 读取）
- Produces: `skills/context/SKILL.md`（name=`context`）；`PROJECT-CONTEXT.template.md`（被 install.sh 拷贝）

- [ ] **Step 1: 写 `PROJECT-CONTEXT.template.md`**

```bash
cat > PROJECT-CONTEXT.template.md <<'EOF'
# Project Context

> 本文件是项目的唯一元信息来源，供 context / doc / flow 读取。
> 拷到项目根目录改填；能从代码确认的字段（build/package）可留空让 AI 扫码补。

- jdk: 17                      # 如 8 / 11 / 17 / 21
- build: maven                 # maven | gradle
- build_cmd: ./mvnw clean package
- run_cmd: ./mvnw spring-boot:run
- test_cmd: ./mvnw test
- db: mysql 8                  # mysql | postgresql | oracle | sqlserver | mariadb | ...
- orm: mybatis-plus            # jpa | mybatis | mybatis-plus
- package: com.example.app
- doc_root: docs/              # 文档统一输出根（api/ data-model/ db/ 在其下）
- modules: []                  # 业务模块列表，如 [user, order, payment]
- notes: ""                    # 其他约定：缓存/MQ/网关/鉴权方式/特殊规范
EOF
```

- [ ] **Step 2: 写 `skills/context/SKILL.md`（极简，grill-me 调性）**

```bash
cat > skills/context/SKILL.md <<'EOF'
---
name: context
description: Use at the start of any Java backend task, or when project setup (JDK, build tool, database, ORM, package) info is needed. Reads PROJECT-CONTEXT.md from the repo root; if missing, creates it once from the template by scanning the code. Ensures project facts are never asked twice.
---

<what-to-do>

Before any Java backend work, read `PROJECT-CONTEXT.md` at the repo root.

If it does not exist:
1. Scan the code to fill what you can — `pom.xml` → `build: maven`, `build.gradle` → `build: gradle`; `@Entity` → `orm: jpa`, `@TableName` → `orm: mybatis-plus`; detect JDK from `pom.xml` `<maven.compiler.release>` or `build.gradle` `sourceCompatibility`; detect package from the top-level `package` statement.
2. Create `PROJECT-CONTEXT.md` from the template (`PROJECT-CONTEXT.template.md`) with those values filled; leave the rest as guided prompts.
3. Ask the user only for what code cannot reveal (e.g. `db` type/version, `notes`), one question at a time.

On every task, reuse this file. Never re-ask JDK / build tool / database / ORM / package — read it here.

</what-to-do>

<supporting-info>

If `PROJECT-CONTEXT.md` contradicts the code (e.g. says `gradle` but `pom.xml` exists), point it out and fix the file. Keep entries as a flat bullet list of `- key: value`. Fields: jdk, build, build_cmd, run_cmd, test_cmd, db, orm, package, doc_root, modules, notes.

</supporting-info>
EOF
```

- [ ] **Step 3: 运行 validate.sh 验证从 FAIL 转 OK**

```bash
./tools/validate.sh
```
Expected: `OK: context`；但 `doc` / `flow` 仍报 missing SKILL.md，整体退出码非 0。确认 context 本身合规。

- [ ] **Step 4: 校验 frontmatter name 与目录名一致**

```bash
awk '/^---$/{c++; next} c==1 && /^name:/{print $2; exit}' skills/context/SKILL.md
```
Expected: 输出 `context`。

- [ ] **Step 5: （可选，需 git 授权）Commit**

```bash
git add PROJECT-CONTEXT.template.md skills/context/SKILL.md
git commit -m "feat: add context skill and PROJECT-CONTEXT template"
```

---

### Task 4: doc skill + DOC-FORMATS reference

**Files:**
- Create: `skills/doc/SKILL.md`
- Create: `skills/doc/DOC-FORMATS.md`
- Test: `./tools/validate.sh`

**Interfaces:**
- Consumes: `PROJECT-CONTEXT.md`（build / db / orm / doc_root / package）；目标项目源码与 SQL。
- Produces: 文档到 `<doc_root>/api/`、`<doc_root>/data-model/`、`<doc_root>/db/`（懒加载）。

- [ ] **Step 1: 写 `skills/doc/DOC-FORMATS.md`（三类文档格式规范）**

```bash
cat > skills/doc/DOC-FORMATS.md <<'EOF'
# Java 文档格式规范

供 doc 生成三类文档时遵循。固定路径根 = PROJECT-CONTEXT.md 的 `doc_root`（默认 `docs/`）。

## 1. 接口文档 `<doc_root>/api/<模块>.md`

按业务模块聚合。每个接口一段：

```md
## POST /api/orders

创建订单

- **Method**: POST
- **入参** (`OrderCreateReq`):
  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | userId | Long | 是 | 用户ID |
  | amount | BigDecimal | 是 | 金额 |
- **出参** (`OrderVO`): 见 data-model/orders.md#OrderVO
- **示例**:
  请求: `{"userId":1,"amount":"99.00"}`
  响应: `{"code":0,"data":{"orderId":"O123"}}`
```

若项目有 springdoc-openapi，优先以 `/v3/api-docs` 的 JSON 为准生成，并在文件头注明来源。

## 2. 数据模型文档 `<doc_root>/data-model/<实体名>.md`

```md
# Order

对应表: `t_order` （ORM: mybatis-plus）

| 字段 | Java 类型 | 列名 | DB 类型 | 说明 | 约束 |
|---|---|---|---|---|---|
| id | Long | id | bigint | 主键 | PK, 自增 |
| userId | Long | user_id | bigint | 用户ID | 非空, 索引 |
| amount | BigDecimal | amount | decimal(12,2) | 金额 | 非空 |
```

DTO/VO 同格式，列名列写 `—`（无映射）。

## 3. DB 脚本 `<doc_root>/db/`

- `schema.sql`: 全量建表 DDL（按 `db` 方言生成类型与自增/序列）。
- `migrations/`: 每次结构变更追加 `V<日期>_<简述>.sql` 迁移记录。

```sql
-- schema.sql (mysql 8)
CREATE TABLE `t_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 类型映射（默认）

Java → DB（按 `db` 方言调整）：
- Long → bigint / BIGINT
- String → varchar(n) / VARCHAR
- BigDecimal → decimal(p,s) / NUMERIC
- LocalDateTime → datetime / TIMESTAMP
- Boolean → tinyint(1) / BOOLEAN

## 懒加载

仅当确有内容时创建文件/目录；不预生成空骨架。
EOF
```

- [ ] **Step 2: 写 `skills/doc/SKILL.md`**

```bash
cat > skills/doc/SKILL.md <<'EOF'
---
name: doc
description: Use whenever writing or modifying Java Controllers, DTOs/Entities, or SQL/DDL in a Spring backend. Auto-generates and keeps in sync three doc types at fixed paths under doc_root — REST docs in api/, data-model docs in data-model/, DB scripts in db/. Adapts to Maven/Gradle and the project DB dialect. Reads PROJECT-CONTEXT.md for the stack.
---

<what-to-do>

When the user writes or modifies any of these, offer (and on approval, write) the matching doc:

- `@RestController` / `@Controller` / `@*Mapping` → `api/<模块>.md`
- `@Entity` / `@TableName` / DTO / VO → `data-model/<实体名>.md`
- 建表/改表 SQL or Entity 字段变更 → `db/schema.sql` (+ `db/migrations/V*.sql`)

Read `PROJECT-CONTEXT.md` first for `doc_root`, `db` (方言), `orm`, `package`, `modules`. Generate docs under `<doc_root>/api`, `<doc_root>/data-model`, `<doc_root>/db`.

Follow the formats in [DOC-FORMATS.md](./DOC-FORMATS.md).

</what-to-do>

<supporting-info>

## 多栈适配

- **构建**: `pom.xml` → Maven (`./mvnw`); `build.gradle` → Gradle (`./gradlew`).
- **DB 方言**: 按 `db` 字段生成对应 DDL（类型、自增/序列差异）。
- **ORM**: `@Entity` → JPA 解析; `@TableName` → MyBatis-Plus 解析.
- **OpenAPI**: 若依赖含 `springdoc-openapi`，优先读 `/v3/api-docs` JSON 生成接口文档。

## 懒加载

有内容才建文件，不空建目录。生成前用一句话说明意图；不擅自删除已有文档，只追加/更新对应段落。

</supporting-info>
EOF
```

- [ ] **Step 3: 运行 validate.sh**

```bash
./tools/validate.sh
```
Expected: `OK: context`、`OK: doc`；`flow` 仍报 missing。退出码非 0。

- [ ] **Step 4: 校验 SKILL.md 引用的 reference 路径存在**

```bash
grep -q 'DOC-FORMATS.md' skills/doc/SKILL.md && test -f skills/doc/DOC-FORMATS.md && echo "PASS: reference 可达"
```
Expected: `PASS: reference 可达`。

- [ ] **Step 5: （可选，需 git 授权）Commit**

```bash
git add skills/doc/SKILL.md skills/doc/DOC-FORMATS.md
git commit -m "feat: add doc skill and DOC-FORMATS reference"
```

---

### Task 5: flow skill

**Files:**
- Create: `skills/flow/SKILL.md`
- Test: `./tools/validate.sh`（应全部 OK，退出码 0）

**Interfaces:**
- Consumes: `PROJECT-CONTEXT.md`；调用 `doc` 同步文档。
- Produces: `skills/flow/SKILL.md`（name=`flow`）。

- [ ] **Step 1: 写 `skills/flow/SKILL.md`**

```bash
cat > skills/flow/SKILL.md <<'EOF'
---
name: flow
description: Use for Java backend feature/bug work when you want a lightweight flow instead of heavy multi-stage processes. Minimal spine — understand need, brief design only if complex, implement, self-check (compile/test), sync docs via doc. Always read PROJECT-CONTEXT.md first; never re-ask known project facts.
---

<what-to-do>

Run this lightweight spine for Java backend work:

1. **读上下文**: 读 `PROJECT-CONTEXT.md`（不存在则先按 context 创建）。绝不重问已知项目事实。
2. **理解需求**: 用一句话复述要做什么；模糊处一次问一个。
3. **设计要点**: 仅当任务复杂才写几条设计要点；简单任务直接做，不套流程。
4. **实现**: 改代码前先读相关现有代码；遵循现有模式。
5. **自检**: 跑 `test_cmd`（编译/测试），基于结果而非猜测。
6. **同步文档**: 若动了 Controller/Entity/DTO/SQL，按 doc 更新对应文档。

</what-to-do>

<supporting-info>

不做这些（对比重型流程）：多轮方案对比、spec 自检 gate、用户复核 gate、独立的 writing-plans 阶段、强制分模块逐段确认。

简单任务（一处小改、一个 bug）跳过设计要点，直接实现→自检。复杂任务才补设计要点。

</supporting-info>
EOF
```

- [ ] **Step 2: 运行 validate.sh 验证全部 OK**

```bash
./tools/validate.sh
```
Expected: 三行 `OK: context` / `OK: doc` / `OK: flow`，退出码 0。

- [ ] **Step 3: （可选，需 git 授权）Commit**

```bash
git add skills/flow/SKILL.md
git commit -m "feat: add flow lightweight dev process skill"
```

---

### Task 6: README

**Files:**
- Create: `README.md`
- Test: 检查 README 含必要章节、内部链接可达。

**Interfaces:**
- Consumes: 所有已建 skill 与 install.sh。

- [ ] **Step 1: 写 `README.md`**

```bash
cat > README.md <<'EOF'
# Java Development Skills

一套精简的自有 Java 后端开发 Skills，给 Claude Code 与 OpenCode 双工具通用。三个职责单一的 skill + 一个共享元信息底座。

## Skills

| Skill | 干啥 | 触发 |
|---|---|---|
| `context` | 守护项目元信息（JDK/构建/DB/ORM…）于 `PROJECT-CONTEXT.md`，绝不重复问 | Java 任务开始时 |
| `doc` | 写代码时自动生成/同步 接口/数据模型/DB脚本 三类文档到固定路径 | 写改 Controller/Entity/DTO/SQL 时 |
| `flow` | 轻量开发流程主干，替代重型多阶段流程 | Java 功能/bug 开发时 |

## 安装

```bash
git clone <repo-url> java-development-skills
cd java-development-skills

./install.sh                 # 默认装到 ~/.claude/skills/（Claude Code + OpenCode 都能发现）
./install.sh --opencode      # 额外装到 ~/.config/opencode/skills/（双保险）
./install.sh --project /path/to/your-java-app   # 装到指定项目的 .claude/skills/
./install.sh --uninstall     # 卸载
```

> OpenCode 原生扫描 `~/.claude/skills/` 与 `.claude/skills/`，所以默认安装即双工具通用，无需格式转换。

## 使用

1. 在你的 Java 项目根创建 `PROJECT-CONTEXT.md`（`--project` 安装会自动拷模板；否则 `cp PROJECT-CONTEXT.template.md 你的项目/PROJECT-CONTEXT.md`），填好 JDK/构建/DB/ORM。
2. 正常开聊——AI 会按场景自动触发对应 skill。
3. 文档会生成在项目的 `<doc_root>/`（默认 `docs/`）下：`api/`、`data-model/`、`db/`。

## 设计

见 [docs/design/specs/2026-08-05-java-skills-design.md](docs/design/specs/2026-08-05-java-skills-design.md)。

## License

MIT
EOF
```

- [ ] **Step 2: 校验 README 内部链接可达**

```bash
test -f docs/design/specs/2026-08-05-java-skills-design.md && echo "PASS: spec 链接可达"
grep -q 'install.sh' README.md && grep -q 'PROJECT-CONTEXT' README.md && echo "PASS: 含安装与使用说明"
```
Expected: 两行 `PASS`。

- [ ] **Step 3: （可选，需 git 授权）Commit**

```bash
git add README.md
git commit -m "docs: add README"
```

---

### Task 7: 端到端验证

**Files:**
- 无新建；仅运行验证。

**Interfaces:**
- Consumes: Task 1–6 全部产物。

- [ ] **Step 1: 全量校验**

```bash
./tools/validate.sh
```
Expected: 三个 skill 全 `OK`，退出码 0。

- [ ] **Step 2: 在临时目标项目模拟安装与模板拷贝**

```bash
TESTPROJ="$(mktemp -d)"
./install.sh --project "$TESTPROJ"
# 三个 skill 装入
for s in context doc flow; do
  test -e "$TESTPROJ/.claude/skills/$s/SKILL.md" && echo "PASS: $s 装入" || echo "FAIL: $s"
done
# 模板拷贝
test -f "$TESTPROJ/PROJECT-CONTEXT.md" && echo "PASS: 模板已拷" || echo "FAIL: 模板未拷"
# OpenCode 兼容路径（默认装的 ~/.claude/skills 已被 OpenCode 扫描，这里只验证文件就位）
ls -la "$HOME/.claude/skills" | grep -q context && echo "PASS: 全局已装（OpenCode 可发现）"
# 清理
./install.sh --project "$TESTPROJ" --uninstall >/dev/null
rm -rf "$TESTPROJ"
```
Expected: 五处 `PASS`。

- [ ] **Step 3: 手工冒烟（人工）**

在一个真实 Java 项目里：装 skill → 填 `PROJECT-CONTEXT.md` → 让 AI 写一个 Controller，确认它主动触发 doc 在 `docs/api/` 生成接口文档。确认无报错。

- [ ] **Step 4: （可选，需 git 授权）Commit 任何验证中的修正**

```bash
git add -A
git commit -m "test: e2e verification"
```

---

## Self-Review

**1. Spec coverage**（对照 spec §2.1 痛点 & §4 三 skill）：
- 痛点①（自动生成文档）→ Task 4。✅
- 痛点②（路径固定）→ Task 4 的 SKILL.md + DOC-FORMATS 固定路径；Global Constraints 写死。✅
- 痛点③（元信息）→ Task 3。✅
- 痛点④（流程精简）→ Task 5。✅
- 跨工具安装（spec §5）→ Task 2。✅
- 多栈适配（spec §7）→ Task 4 的 SKILL.md supporting-info + DOC-FORMATS 类型映射。✅
- README / LICENSE / 校验（spec §8）→ Task 1/6。✅

**2. Placeholder scan**：无 TBD/TODO；LICENSE holder 用 `git config user.name || Contributors` 动态获取（非占位）。✅

**3. Type/名称一致性**：三个 skill 名 `context` / `doc` / `flow` 在目录、frontmatter、install.sh、README、validate.sh 中完全一致。DOC-FORMATS.md 引用路径在 Task 4 Step 4 校验。✅

---

## Execution Handoff

Plan complete and saved to `docs/design/plans/2026-08-05-java-skills.md`.

---

## 实现修订记录（2026-08-06 同步）

本计划执行中，部分 task 实现与原计划有偏差（bug 修复 + 质量重构 + 规范增强）。**代码以仓库当前实际文件为准**，此记录说明偏差与演进：

### Bug 修复（执行 Task 2/7 时发现并修）
- **validate.sh `set -e` 短路**：原 `[ ] && echo` 在首个非 OK 时让脚本崩溃 → 改局部判定（后重构为 early-return）。
- **install.sh `$dest_pc（` 全角括号并入变量名**：bash 把 `（` 字节并入变量名致 unbound → `${dest_pc}` 花括号定界。
- **install.sh 卸载残留**：`--uninstall` 漏清 `~/.config/opencode/skills` → 卸载时两路径都清。

### 质量重构（simplify 4-agent 审查后）
- 新增 **`lib/common.sh`** 共享层：`NAME_RE` / `validate_skill_name()` / `get_frontmatter_field()`，两脚本 source（消除跨脚本 DRY）。
- **install.sh** 拆分：`install_one` / `uninstall_one`（干掉 link_one 的 UNINSTALL 开关分支）+ `resolve_targets` + `provision_template` + `main()` 包裹；`PROJECT_ABS` 一次解析；`echo|grep` → `[[ =~ ]]`；错误处理升级（不合规 name 非0退出）。
- **validate.sh** 抽 `validate_one_skill` + early-return 删 `this_ok`；改用 common 的函数。
- **跳过的过度设计**（记录在案）：工具表数据驱动、统一遍历器、ROOT 抽函数、BASH_SOURCE 测试守卫、合并 1 次 awk、getopts。

### 规范增强（2026-08-06）
- 新增 **`skills/flow/CODING-STANDARDS.md`**（可维护性总则 / SOLID / 后端分层 / GoF 模式 / 测试友好），flow「实现」步骤硬性引用——回应"代码要可维护、注重设计模式"的要求。

> git 历史：`5195c00`（init）→ `670a173`（CODING-STANDARDS）。

### 架构演进（2026-08-06，三件套 → 四件套）
- 拆出独立 **`plan`** skill（大需求规划：精简 spec+plan 落盘 `docs/specs`、`docs/plans`）。
- **flow 撤掉内嵌双模式**，回归纯轻量流程（小需求）；`PLAN-SPEC-FORMAT.md` 从 flow 移到 plan/。
- README 更新为四件套。理由：SOLID-S 单一职责——flow 不再既管轻量流程又管大需求规划。

> 完整 git 历史：`5195c00`(init) → `670a173`(CODING-STANDARDS) → `e782f7c`(docs 同步) → `96ce984`(四件套 plan)。

### 架构演进（2026-08-06，四件套 → 五件套）
- 新增独立 **`debug`** skill（系统化排查修 bug：复现→隔离→假设→验证→治本修复→回归），三铁律焊死（不复现不改 / 先定位根因 / 治本不治标）；附 `DEBUG-METHODS.md`（排查手法 + 常见 Java bug 速查）。
- flow 不再背"修 bug"职责，专注 feature。理由：debug 与 feature 是不同心智模型，按 SOLID-S 拆分（与 plan 同款逻辑）。
- README / spec 同步为五件套。

> 完整 git 历史：`5195c00`(init) → `670a173`(CODING-STANDARDS) → `e782f7c`(docs同步) → `96ce984`(四件套) → `341d7d9`(docs同步四件套) → `52766f2`(确认gate) → 本次(debug)。

### 架构演进（2026-08-06，五件套 → 六件套）
- 新增独立 **`test`** skill（测试策略 + TDD + 边界 + 覆盖），三原则焊死（测行为不测实现 / 一测试一件事 / 全绿才重构）；附 `TEST-STRATEGIES.md`（分层 / Mock / TDD / Java 测试速查）。
- flow「自检」只保留跑 test_cmd 验证，写测试交给 test；flow supporting-info 加指向。
- 理由：测试是独立方法论，按 SOLID-S 拆分（与 plan/debug 同款逻辑）。
- README / spec(§4.6/§8/§12) 同步六件套。

> 完整 git 历史：`5195c00`(init) → `670a173`(CODING-STANDARDS) → `e782f7c`(docs同步) → `96ce984`(四件套) → `341d7d9`(docs同步四件套) → `52766f2`(确认gate) → `1fc881d`(debug) → 本次(test)。

### db 设计规范补强（2026-08-06，六件套不变）
- 新增 **`skills/doc/DB-DESIGN.md`**（建表设计规范：主键策略/字段规范/索引原则/范式vs反范式/命名速查/分表YAGNI/迁移策略/反模式）。
- `doc` 生成 DDL（`db/schema.sql`、migrations）时遵循它；`plan` spec 模板加「数据模型」维度引用它（大需求设计表时参考）。
- 顺手修 `PLAN-SPEC-FORMAT.md` 第3行过时措辞（"flow 的大需求模式" → "plan"）。
- 决策：db 设计是设计维度非开发动作，**不独立成 skill**，避免与 plan/flow/doc 职责重叠。

### OpenCode command 入口（2026-08-06）
- 新增 `opencode/commands/*.md`（6 个 slash 命令：/context /doc /flow /test /debug /plan），每个 command 引导 AI `skill({name:"xxx"})` 加载对应 skill。
- `install.sh --opencode` 扩展：新增 `provision_commands` 函数，同时装 skill 到 `~/.config/opencode/skills/` + command 到 `~/.config/opencode/commands/`（--project 模式装到 `<project>/.opencode/commands/`）。卸载 sweep 清两处。
- 原因：OpenCode 的 skill 只支持 AI 自动触发（`skill` 工具），**不支持 `/<skill-name>`**（与 Claude Code 不同）；独立 command 文件做手动 `/plan` 入口。
- 已测：`HOME=tmp ./install.sh --opencode` skill(6)+command(6) 同装；卸载干净；command 软链仓库可 git pull 自动更新。

### 通用化改造（2026-08-19，通用层 + 语言定制包）
- 四个 reference（CODING-STANDARDS/TEST-STRATEGIES/DEBUG-METHODS/DOC-FORMATS）拆「通用层 + stacks/JAVA.md」，Java 内容原样搬入一字不丢。
- 新增 **Swift/macOS 定制包 ×4**（flow: MVVM/值语义/Optional 安全；test: Swift Testing/protocol mock；debug: retain cycle/主线程速查；doc: macOS 文档适配）。
- `PROJECT-CONTEXT.md` 加 `language` 路由字段；jdk 语义泛化。六个 SKILL.md description/主干中性化（多语言可触发——plan gap 补齐）。
- install.sh / opencode-commands 零改动（skill 自包含，stacks 随软链可达，已测）。
- Go/Node 定制包：用到再加（各一个 md）。设计见 `2026-08-19-universal-skills-design.md`，计划见 `2026-08-19-universal-skills.md`。
