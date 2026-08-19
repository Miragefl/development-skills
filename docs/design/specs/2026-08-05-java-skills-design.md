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
- 不重造通用 brainstorming/plan 轮子；`flow` 仅做最小主干。

---

## 2. 需求

### 2.1 核心痛点（来自用户澄清）
| # | 痛点 | 对应方案 |
|---|---|---|
| ① | 不会自动生成接口文档、数据库脚本文档 | `doc` skill：写代码时 inline 自动生成 |
| ② | 文档路径不确定 | `doc`：固定路径约定（§6） |
| ③ | JDK 版本等项目元信息需多次重复提示 | `context` skill + `PROJECT-CONTEXT.md` |
| ④ | superpowers 流程过于繁重 | `flow` skill：精简主干 |

### 2.2 用户确认的关键决策
- **形态**：聚焦小 skill 集（职责单一，每个极简）。
- **范围**：全量三件套（`context` + `doc` + `flow`）。
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
development-skills/                 ← 独立 git 仓库（本目录）
├── README.md                            # 是啥 / 咋装 / 咋用
├── install.sh                           # 一键安装（CC + OpenCode 通用）
├── PROJECT-CONTEXT.template.md          # 元信息模板（拷到目标项目根改填）
├── LICENSE
├── lib/common.sh                        # 脚本共享层（NAME_RE / validate_skill_name / get_frontmatter_field）
├── tools/validate.sh                    # skill 合规校验
├── skills/
│   ├── context/SKILL.md                 # 元信息守护
│   ├── doc/{SKILL.md, DOC-FORMATS.md}        # 文档自动生成
│   ├── flow/{SKILL.md, CODING-STANDARDS.md}  # 小需求轻量流程
│   ├── plan/{SKILL.md, PLAN-SPEC-FORMAT.md}  # 大需求规划（确认 gate → flow）
│   ├── test/{SKILL.md, TEST-STRATEGIES.md}   # 测试策略 + TDD
│   └── debug/{SKILL.md, DEBUG-METHODS.md}    # 系统化排查修 bug
└── docs/design/{specs,plans}/           # 本仓库自身的设计文档
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

### 4.1 `context` —— 元信息守护

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

**产物**：`skills/context/SKILL.md`（数十行）+ `PROJECT-CONTEXT.template.md`。

---

### 4.2 `doc` —— 文档自动生成

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

**产物**：`skills/doc/SKILL.md` + `skills/doc/DOC-FORMATS.md` + `skills/doc/DB-DESIGN.md`（建表设计规范，生成 DDL 时遵循、plan 设计数据模型时参考）。

---

### 4.3 `flow` —— 轻量开发流程

**触发描述（description 草案）**：
> Use for Java backend feature/bug work when you want a lightweight flow instead of heavy multi-stage processes. Minimal spine: understand need → (only if complex) brief design notes → implement → self-check (compile/test) → sync docs via doc. Always read PROJECT-CONTEXT.md first; never re-ask known project facts.

**主干（砍到骨头）**：
```
理解需求 →（仅复杂任务）简短设计要点 → 实现 → 自检(编译/测试) → 同步文档(doc)
```

**明确砍掉（对比 superpowers）**：
- 多轮 2-3 approaches 方案对比
- spec 自检 gate、用户复核 gate
- writing-plans 独立阶段
- 强制分模块逐段确认

**强制保留**：
- 开干前先读 `PROJECT-CONTEXT.md`
- 基于事实（扫代码）而非猜测
- 改完代码同步 `doc` 文档
- 简单任务直接做，不强行套流程

**产物**：`skills/flow/SKILL.md`（数十行，grill-me 调性）+ `skills/flow/CODING-STANDARDS.md`（可维护性+设计模式规范，「实现」阶段硬性引用——见 §12 演进）。

---

### 4.4 `plan` —— 大需求规划

**触发描述（description 草案）**：
> Use for large Java backend efforts — cross-module, architecture-level, multi-session, or multi-person work. Writes a brief one-page spec to docs/specs/ and a task-checklist plan to docs/plans/ before implementation. Pair with flow for coding. Skip for small tasks — use flow directly.

**行为规约**：
1. 读 `PROJECT-CONTEXT.md`（不存在则先按 context 创建）。
2. 写精简 spec 到 `docs/specs/<需求名>.md`：目标(一句话) / 约束 / 模块拆解 / 关键决策 / 风险，一页纸为限。
3. 写精简 plan 到 `docs/plans/<需求名>.md`：Task 清单，每条标改哪些文件 + 怎么验证 + `- [ ]`。
4. **停下来等用户确认**（硬性 gate）：spec+plan 落盘后明确请用户审阅，不在确认前开始写代码；要改则改完再次确认。
5. **确认后自动转 flow**：衔接 flow 进入实现（套用 CODING-STANDARDS，动 Controller/Entity/DTO/SQL 时同步 doc）。

**与 flow 的分工**：小需求直接 flow；大需求先 plan 规划再 flow 实现。**使用者自决，AI 可建议**。拿不准选 flow——文档随时能补，别为小活儿套重壳。

**格式外置**：spec/plan 的精简格式见 `PLAN-SPEC-FORMAT.md`（一页 spec + task 清单，区别于 superpowers 几十页文档）。

**产物**：`skills/plan/SKILL.md` + `skills/plan/PLAN-SPEC-FORMAT.md`。

---

### 4.5 `debug` —— 系统化排查

**触发描述（description 草案）**：
> Use when fixing bugs, diagnosing exceptions/errors, or investigating performance issues in a Java backend. Systematic spine — reproduce, isolate, hypothesize, verify, fix root cause, regression-check. Never guess-edit; reproduce before touching code; fix the cause not the symptom.

**行为规约**：
1. **复现**：稳定复现，记步骤；不能复现先搞复现，**别动代码**。
2. **隔离**：二分 / 日志 / 断点缩小到模块 → 方法 → 行。
3. **假设**：根据现象提根因假设。
4. **验证**：最小改动 / 临时单测 / 日志验证；错就换假设，别死磕。
5. **修复**：改最少代码修**根因**（治本不治标）。
6. **回归**：跑 `test_cmd` + 想新坑（边界 / 并发 / 其他调用方）。
7. **同步**：动接口/实体按 doc 更新。

**三条铁律**：① 不复现不改动 ② 先定位根因再修 ③ 治本不治标。

**与 flow/plan 分工**：feature 走 flow；bug 走 debug；复杂 / 大影响 bug 先 plan 规划排查思路再 debug。

**格式外置**：排查手法 + 常见 Java bug 速查见 `DEBUG-METHODS.md`。

**产物**：`skills/debug/SKILL.md` + `skills/debug/DEBUG-METHODS.md`。

---

### 4.6 `test` —— 测试策略与 TDD

**触发描述（description 草案）**：
> Use when writing tests, applying TDD, or deciding test strategy for a Java backend. Pairs with flow — flow writes code, this writes tests.

**行为规约**：
1. **定层**：单元（Service/逻辑）/ 集成（Controller）/ DAO（Mapper），不混层。
2. **先写失败测试（TDD）**：针对行为写会失败的测试（Red），测行为不测实现。
3. **跑出失败**：确认因预期断言失败（不是编译错）。
4. **实现到通过**：最少代码让测试通过（Green）。
5. **补边界**：null/空/越界/并发/异常/权限/时间。
6. **回归**：全量 `test_cmd` 通过。
7. **重构**：全绿下才重构。

**三条原则**：① 测行为不测实现 ② 一个测试一件事 ③ 测试是安全网（全绿才重构）。

**与 flow 分工**：flow 写实现（自检只跑 `test_cmd` 验证）；test 写测试、定策略、TDD。

**格式外置**：分层 / Mock / TDD / Java 测试速查见 `TEST-STRATEGIES.md`。

**产物**：`skills/test/SKILL.md` + `skills/test/TEST-STRATEGIES.md`。

---

### 4.7 skill 协作流程

各 skill 单一职责，按场景触发并衔接。核心链路：

| 入口场景 | 链路 |
|---|---|
| 大需求 / 架构级 | plan（spec+plan + 确认 gate）→ flow（实现）→ test（测试） |
| 小功能 | flow（实现）→ test（测试） |
| 修 bug / 异常 / 性能 | debug（系统化排查 + 治本修复）→ test（回归测试） |

**横切（所有场景共用）**：
- 任何 skill 开干前读 `context` 维护的 `PROJECT-CONTEXT.md`（元信息底座，不重复问）。
- 任意 skill 动到 Controller/Entity/DTO/SQL → 触发 `doc` 同步文档到 `docs/api`、`docs/data-model`、`docs/db`。

**交接点（硬性 gate / 职责边界）**：
- **plan → flow**：spec+plan 落盘后**必须用户确认**才转实现（确认 gate，见 §4.4）。
- **flow → test**：flow 自检只跑 `test_cmd` 验证；写测试由 test 负责（见 §4.6）。
- **debug → test**：bug 修完补回归测试，防回归。

**自决原则**：使用者判断走哪条链路（大 / 小需求、feature / bug），AI 可建议但最终使用者定（见各 skill 的「何时用」）。

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

目标项目内，`doc` 生成物的固定位置（根 = `PROJECT-CONTEXT.md` 的 `doc_root`，默认 `docs/`）：

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
| `skills/context/SKILL.md` | skill | 元信息守护 |
| `skills/doc/SKILL.md` | skill | 文档自动生成（主） |
| `skills/doc/DOC-FORMATS.md` | reference | 三类文档格式规范 |
| `skills/doc/DB-DESIGN.md` | reference | 建表设计规范（主键/字段/索引/命名/范式） |
| `skills/flow/SKILL.md` | skill | 小需求轻量开发流程 |
| `skills/flow/CODING-STANDARDS.md` | reference | 可维护性+设计模式规范（flow「实现」阶段引用） |
| `skills/plan/SKILL.md` | skill | 大需求规划（spec+plan 落盘） |
| `skills/plan/PLAN-SPEC-FORMAT.md` | reference | 精简版 spec/plan 格式 |
| `skills/debug/SKILL.md` | skill | 系统化排查修 bug |
| `skills/debug/DEBUG-METHODS.md` | reference | 排查手法 + 常见 Java bug 速查 |
| `skills/test/SKILL.md` | skill | 测试策略与 TDD |
| `skills/test/TEST-STRATEGIES.md` | reference | 分层 / Mock / TDD / 测试速查 |
| `lib/common.sh` | 共享库 | install.sh / validate.sh 共用：NAME_RE / validate_skill_name / get_frontmatter_field |
| `opencode/commands/*.md` | OpenCode 命令 | 6 个 slash 入口（/context /doc /flow /test /debug /plan），引导加载对应 skill |
| `docs/design/specs/2026-08-05-java-skills-design.md` | 文档 | 本设计文档 |

---

## 9. 非目标（YAGNI）

- 不做 IDE 插件、LSP、CI/CD 集成。
- 不做自动构建/发布/部署流水线。
- 不重造通用 brainstorming / plan / debug 工具；`flow` 仅最小主干。
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
3. 按计划实现：先 `install.sh` 骨架 + `context`，再 `doc`（含 DOC-FORMATS.md），最后 `flow` 与 README。
4. 在一个真实 Java 项目中验证双工具发现与文档生成效果。

---

_参考：[OpenCode Agent Skills](https://opencode.ai/docs/skills/) · [OpenCode Rules](https://opencode.ai/docs/rules/) · [agents.md 开放标准](https://agents.md/) · grill-me / grill-with-docs（context-mode 插件）_

---

## 12. 设计演进（同步于 2026-08-06）

初版交付后经历两轮演进，设计文档与当前代码的偏差记录于此（详细实现见 `docs/design/plans/2026-08-05-java-skills.md` 末尾「实现修订记录」）：

- **质量重构**：引入 `lib/common.sh` 共享层（NAME_RE / validate_skill_name / get_frontmatter_field）；install.sh 拆分为 `install_one` / `uninstall_one` / `resolve_targets` / `provision_template` + `main()` 包裹；validate.sh 抽 `validate_one_skill` + early-return。原 §5 install.sh 逻辑描述仍准确，内部结构已函数化（SRP）。
- **规范增强**：新增 `skills/flow/CODING-STANDARDS.md`，flow「实现」阶段硬性引用，回应"代码要可维护、注重设计模式"的要求。此为 §4.3 的补充——flow 产出的代码强制遵循 SOLID / 后端分层 / GoF 模式 / 测试友好。
- **架构演进（三件套 → 四件套）**：拆出独立 `plan` skill 接管大需求规划（写精简 spec+plan 落盘 `docs/specs`、`docs/plans`）；flow 撤掉内嵌双模式，回归纯轻量流程；`PLAN-SPEC-FORMAT.md` 从 flow 移到 plan。理由：SOLID-S 单一职责——flow 不再既管轻量流程又管大需求规划。
- **架构演进（四件套 → 五件套）**：新增独立 `debug` skill 接管 bug 排查（系统化：复现→隔离→假设→验证→治本修复→回归），三铁律焊死（不复现不改 / 先定位根因 / 治本不治标）；flow 不再背"修 bug"职责，专注 feature。理由：debug 与 feature 是不同心智模型，按 SOLID-S 拆分。
- **架构演进（五件套 → 六件套）**：新增独立 `test` skill 接管测试（定层 + TDD + 边界 + 覆盖），三原则焊死（测行为不测实现 / 一测试一件事 / 全绿才重构）；flow 的「自检」只保留"跑 test_cmd 验证"，写测试交给 test。理由：测试是独立方法论，按 SOLID-S 拆分。
- **db 设计规范补强**：新增 `skills/doc/DB-DESIGN.md`（建表设计规范：主键/字段/索引/命名/范式/分表/迁移）；doc 生成 DDL 时遵循，plan spec 模板加「数据模型」维度引用它。决策：db 设计是**设计维度**非开发动作，不独立成 skill，避免与 plan/flow/doc 职责重叠。
- **OpenCode command 入口**：新增 `opencode/commands/*.md`（6 个 slash 命令：/context /doc /flow /test /debug /plan）；`install.sh --opencode` 同时装 skill 到 `~/.config/opencode/skills/` + command 到 `~/.config/opencode/commands/`。原因：OpenCode 的 skill 只支持 AI 自动触发（`skill` 工具），**不支持 `/<skill-name>` 手动触发**（与 Claude Code 不同），需独立 command 文件做手动入口。
- **不变项**：各 skill 单一职责的原则、文档路径约定（§6）、跨工具发现机制（§3.3）、多栈适配（§7）未变。
