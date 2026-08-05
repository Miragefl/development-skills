# Java 开发 Skills 设计文档

| 项 | 值 |
|---|---|
| 日期 | 2026-08-05 |
| 状态 | Draft（待用户复核） |
| 主题 | 自有精简 Java 后端开发 Skills 集（context / doc / flow） |
| 参考对象 | `grill-me`、`grill-with-docs`（context-mode 插件）、`superpowers`（brainstorming） |

---

## 1. 背景与目标

用户在使用 `superpowers`（brainstorming 等流程类 skill）开发 Java 后端项目时遇到四个痛点，希望参考 `grill-me` / `grill-with-docs` 的精简哲学，打造一套**自己的、精简的 Java 后端开发 skills**，作为独立 git 仓库分发，并通过安装脚本让 **Claude Code 与 OpenCode 双工具通用**。

### 目标
1. 开发时**自动生成**三类文档（REST/OpenAPI 接口、数据模型、数据库脚本），无需手动催促。
2. 文档输出路径**写死约定**，消除"放哪儿"的不确定性。
3. 项目元信息（JDK、构建工具、数据库等）**一次配置、反复读取**，AI 不再每次重复提问。
4. 提供一条**精简开发流程**，替代 superpowers 的重流程（多轮方案/spec 自检/复核 gate）。

### 非目标（YAGNI 边界，见 §9）
- 不做 IDE 插件、不做 CI 集成、不做全自动化构建发布。
- 不重造通用 brainstorming/plan 轮子；`java-flow` 仅做最小主干。

---

## 2. 需求

### 2.1 核心痛点（来自用户澄清）
| # | 痛点 | 对应方案 |
|---|---|---|
| ① | 不会自动生成接口文档、数据库脚本文档 | `java-doc` skill：写代码时 inline 自动生成 |
| ② | 文档路径不确定 | `java-doc`：固定路径约定（§6） |
| ③ | JDK 版本等项目元信息需多次重复提示 | `java-context` skill + `PROJECT-CONTEXT.md` |
| ④ | superpowers 流程过于繁重 | `java-flow` skill：精简主干 |

### 2.2 用户确认的关键决策
- **形态**：聚焦小 skill 集（职责单一，每个极简）。
- **范围**：全量三件套（`java-context` + `java-doc` + `java-flow`）。
- **元信息文件位置**：目标项目仓库根目录 `PROJECT-CONTEXT.md`。
- **文档输出根**：`docs/` 下按类型分类（`docs/api/`、`docs/data-model/`、`docs/db/`）。
- **技术栈**：多栈兼容（Maven/Gradle + MySQL/PostgreSQL/Oracle 等多种 DB）。
- **文档生成触发方式**：写代码时自动（inline，学 grill-with-docs）。
- **分发**：独立 git 仓库 + `install.sh`，Claude Code 与 OpenCode 通用。

### 2.3 约束
- **跨工具兼容**：SKILL.md 必须在 Claude Code 与 OpenCode 下都被正确发现与触发。
- **精简**：主 SKILL.md 控制在数十行；重的格式规范拆为独立 reference 文件，按需读取。
- **多栈适配**：构建工具（Maven/Gradle）、数据库方言、ORM（JPA/MyBatis/MyBatis-Plus）的差异需自动识别。
- **不主动 git**：遵循用户全局规则，仓库内文件操作不附带 git commit/push（除非用户明确要求）。

---

## 3. 整体架构

### 3.1 仓库结构
```
java-development-skills/                 ← 独立 git 仓库（本目录）
├── README.md                            # 是啥 / 咋装 / 咋用
├── install.sh                           # 一键安装（CC + OpenCode 通用）
├── PROJECT-CONTEXT.template.md          # 元信息模板（拷到目标项目根改填）
├── LICENSE
├── skills/
│   ├── java-context/
│   │   └── SKILL.md                     # skill 1：元信息守护
│   ├── java-doc/
│   │   ├── SKILL.md                     # skill 2：文档自动生成
│   │   └── DOC-FORMATS.md              # 三类文档格式规范（按需读取）
│   └── java-flow/
│       └── SKILL.md                     # skill 3：轻量开发流程
└── docs/
    └── design/specs/                    # 本仓库自身的设计文档
        └── 2026-08-05-java-skills-design.md
```

### 3.2 设计原则
- **KISS**：每个 SKILL.md 极简（数十行），核心指令直白。
- **DRY**：`PROJECT-CONTEXT.md` 作为所有 skill 的共享元信息底座；格式规范抽到独立文件复用。
- **YAGNI**：只实现四大痛点所需，流程 skill 仅保留最小主干。
- **SOLID-S（单一职责）**：context 管元信息、doc 管文档、flow 管流程，互不越界。
- **懒加载**：文档/元信息文件"有料才建"，不预生成空文件（学 grill-with-docs）。
- **能查代码就别问**：项目事实（构建工具、依赖、包结构）优先扫代码确认，不向用户发问（学 grill-me）。

### 3.3 跨工具兼容（关键结论）
经查证 [OpenCode Agent Skills 文档](https://opencode.ai/docs/skills/)，OpenCode 的 skill 搜索路径**原生包含 Claude Code 的目录**：
- 项目级：`.claude/skills/<name>/SKILL.md`（CC + OpenCode 均扫描）
- 全局级：`~/.claude/skills/<name>/SKILL.md`（CC + OpenCode 均扫描）
- OpenCode 专有：`~/.config/opencode/skills/<name>/SKILL.md`、`.opencode/skills/<name>/SKILL.md`

**结论**：SKILL.md **写一份**，frontmatter 用两边都识别的 `name` + `description`，装到 `~/.claude/skills/` 即可被双工具同时发现，**无需任何格式转换**。`install.sh` 默认装到 `~/.claude/skills/`，提供 `--opencode` 选项额外写入 `~/.config/opencode/skills/` 做双保险。

**frontmatter 规则（双工具一致）**：
- `name`（必填）：`^[a-z0-9]+(-[a-z0-9]+)*$`，1–64 字符，须与目录名一致。
- `description`（必填）：1–1024 字符，需足够具体以便 agent 正确触发。
- 可选：`license`、`compatibility`、`metadata`（OpenCode 识别；Claude Code 忽略未知字段，无副作用）。

---

## 4. Skill 详细设计

### 4.1 `java-context` —— 元信息守护

**触发描述（description 草案）**：
> Use at the start of any Java backend task, or when project setup/build/database/JDK info is needed. Reads `PROJECT-CONTEXT.md` from the repo root; if missing, guides the user to create it once from the template. Ensures JDK version, build tool, database, ORM, and package conventions are never asked twice.

**行为规约**：
1. 任务开始时，读取目标项目根的 `PROJECT-CONTEXT.md`。
2. 若不存在 → 将 `PROJECT-CONTEXT.template.md` 拷到项目根，引导用户填写关键字段；能从代码推断的字段（如 `pom.xml` 存在→`build: maven`）预先填好。
3. 元信息缺失或与代码实际冲突（如元信息写 Gradle 但实际是 `pom.xml`）→ 立即提醒修正。
4. 其他 skill 一律通过本文件获取项目事实，禁止重复向用户发问。

**`PROJECT-CONTEXT.md` 模板字段**（机器友好、极简）：
```markdown
# Project Context
- jdk: 17
- build: maven                 # maven | gradle
- build_cmd: ./mvnw clean package
- run_cmd: ./mvnw spring-boot:run
- test_cmd: ./mvnw test
- db: mysql 8                  # mysql | postgresql | oracle | sqlserver | ...
- orm: mybatis-plus            # jpa | mybatis | mybatis-plus
- package: com.example.app
- doc_root: docs/              # 文档统一输出根
- modules: [user, order, payment]
- notes: ""                    # 其他约定（缓存、消息队列、特殊规范等）
```

**产物**：`skills/java-context/SKILL.md`（数十行）+ `PROJECT-CONTEXT.template.md`。

---

### 4.2 `java-doc` —— 文档自动生成

**触发描述（description 草案）**：
> Use whenever writing or modifying Java Controllers, DTOs/Entities, or SQL/DDL in a Spring backend project. Auto-generates and keeps in sync three doc types at fixed paths: REST/OpenAPI docs under `docs/api/`, data-model docs under `docs/data-model/`, and DB scripts under `docs/db/`. Adapts to Maven/Gradle and the project's database dialect. Reads `PROJECT-CONTEXT.md` for stack info.

**触发点（inline 自动）**：当用户在写/改以下内容时，主动提醒并同步对应文档：
- `@RestController` / `@Controller` / `@*Mapping` → 接口文档
- `@Entity` / `@TableName` / DTO / VO → 数据模型文档
- 建表/改表 SQL、Entity 变更 → DB 脚本（DDL）

**多栈适配策略**：
| 维度 | 识别方式 | 处理 |
|---|---|---|
| 构建工具 | 存在 `pom.xml`/`build.gradle` | 生成对应构建命令；Maven 用 `./mvnw`，Gradle 用 `./gradlew` |
| 数据库方言 | `PROJECT-CONTEXT.md` 的 `db` 字段 | 生成对应方言 DDL（类型映射、自增/序列差异） |
| ORM | 扫 `@Entity`(JPA) / `@TableName`(MyBatis-Plus) | 按对应注解解析字段与约束 |
| OpenAPI | 检测 `springdoc-openapi` 依赖 | 若存在，优先结合 `/v3/api-docs` 的 JSON 生成更准确的接口文档 |

**懒加载**：仅在实际有内容时创建文件/目录，不预生成空骨架。

**格式规范外置**：三类文档的具体格式（字段表结构、示例写法、DDL 模板）写入 `DOC-FORMATS.md`，主 SKILL.md 仅引用，避免主文件膨胀。

**产物**：`skills/java-doc/SKILL.md` + `skills/java-doc/DOC-FORMATS.md`。

---

### 4.3 `java-flow` —— 轻量开发流程

**触发描述（description 草案）**：
> Use for Java backend feature/bug work when you want a lightweight flow instead of heavy multi-stage processes. Minimal spine: understand need → (only if complex) brief design notes → implement → self-check (compile/test) → sync docs via java-doc. Always read PROJECT-CONTEXT.md first; never re-ask known project facts.

**主干（砍到骨头）**：
```
理解需求 →（仅复杂任务）简短设计要点 → 实现 → 自检(编译/测试) → 同步文档(java-doc)
```

**明确砍掉（对比 superpowers）**：
- 多轮 2-3 approaches 方案对比
- spec 自检 gate、用户复核 gate
- writing-plans 独立阶段
- 强制分模块逐段确认

**强制保留**：
- 开干前先读 `PROJECT-CONTEXT.md`
- 基于事实（扫代码）而非猜测
- 改完代码同步 `java-doc` 文档
- 简单任务直接做，不强行套流程

**产物**：`skills/java-flow/SKILL.md`（数十行，grill-me 调性）。

---

## 5. `install.sh` 设计

**用法**：
```bash
./install.sh                    # 默认：软链三个 skill 到 ~/.claude/skills/（CC+OpenCode 均可发现）
./install.sh --opencode         # 额外再写入 ~/.config/opencode/skills/（双保险）
./install.sh --project <path>   # 装到指定项目的 .claude/skills/
./install.sh --uninstall        # 移除已安装的软链/副本
```

**逻辑**：
1. 检测平台（macOS / Linux），确定 home 目录。
2. 遍历 `skills/` 下每个子目录，校验目录名与 SKILL.md 的 `name` 一致且符合命名规则。
3. 默认软链到 `~/.claude/skills/<name>`（便于 `git pull` 升级）；文件系统不支持软链时回退为复制。
4. `--opencode`：额外复制（不软链，避免跨工具耦合）到 `~/.config/opencode/skills/<name>`。
5. `--project`：装到 `<path>/.claude/skills/`。
6. 安装后：把 `PROJECT-CONTEXT.template.md` 拷一份到目标项目根（若不存在），提示用户填写。
7. 打印安装摘要（装了哪些、装到哪、如何触发）。

**幂等性**：重复安装不报错，已存在的软链/文件先移除再重建。

---

## 6. 文档路径约定（写死）

目标项目内，`java-doc` 生成物的固定位置（根 = `PROJECT-CONTEXT.md` 的 `doc_root`，默认 `docs/`）：

| 类型 | 路径 | 粒度 |
|---|---|---|
| 接口文档 | `<doc_root>/api/<模块>.md` | 按业务模块聚合 |
| 数据模型 | `<doc_root>/data-model/<实体名>.md` | 一个实体一文件 |
| DB 脚本 | `<doc_root>/db/schema.sql` + `<doc_root>/db/migrations/` | 全量 schema + 迁移记录 |

---

## 7. 多栈适配策略（汇总）

构建工具、DB 方言、ORM、OpenAPI 四个维度的识别与处理见 §4.2 表格。核心原则：**优先扫代码与 `PROJECT-CONTEXT.md` 确定事实，不向用户发问**；只有两者都缺时才一次性问清并写回 `PROJECT-CONTEXT.md`。

---

## 8. 交付文件清单

| 路径 | 类型 | 说明 |
|---|---|---|
| `README.md` | 文档 | 项目说明、安装、使用、各 skill 触发场景 |
| `install.sh` | 脚本 | 跨工具安装（可执行） |
| `PROJECT-CONTEXT.template.md` | 模板 | 元信息模板 |
| `LICENSE` | 文档 | 开源协议（待用户定，默认 MIT） |
| `skills/java-context/SKILL.md` | skill | 元信息守护 |
| `skills/java-doc/SKILL.md` | skill | 文档自动生成（主） |
| `skills/java-doc/DOC-FORMATS.md` | reference | 三类文档格式规范 |
| `skills/java-flow/SKILL.md` | skill | 轻量开发流程 |
| `docs/design/specs/2026-08-05-java-skills-design.md` | 文档 | 本设计文档 |

---

## 9. 非目标（YAGNI）

- 不做 IDE 插件、LSP、CI/CD 集成。
- 不做自动构建/发布/部署流水线。
- 不重造通用 brainstorming / plan / debug 工具；`java-flow` 仅最小主干。
- 不做非 Java 后端场景（前端、移动端、JNI/native 等）的文档生成。
- 不内置具体业务领域的接口/表结构假定。

---

## 10. 风险与对策

| 风险 | 对策 |
|---|---|
| SKILL.md 过长导致主上下文膨胀 | 重格式规范外置到 reference 文件，主文件仅放触发逻辑与路径约定 |
| 多栈适配遗漏某些组合 | 以 `PROJECT-CONTEXT.md` 为权威事实源；识别失败时一次性问清并回写 |
| inline 触发过于频繁打扰用户 | 仅在写/改 Controller/Entity/DTO/SQL 时触发；生成前简要说明意图 |
| OpenCode 版本演进改变搜索路径 | 默认装 `~/.claude/skills/`（当前双工具共认），`--opencode` 提供专有目录双保险 |
| 软链在部分环境（Windows/某些 FS）不可用 | install.sh 自动回退为复制 |

---

## 11. 后续步骤

1. 用户复核本设计文档 → 确认/修订。
2. 调用 `writing-plans` skill 产出分步实现计划。
3. 按计划实现：先 `install.sh` 骨架 + `java-context`，再 `java-doc`（含 DOC-FORMATS.md），最后 `java-flow` 与 README。
4. 在一个真实 Java 项目中验证双工具发现与文档生成效果。

---

_参考：[OpenCode Agent Skills](https://opencode.ai/docs/skills/) · [OpenCode Rules](https://opencode.ai/docs/rules/) · [agents.md 开放标准](https://agents.md/) · grill-me / grill-with-docs（context-mode 插件）_
