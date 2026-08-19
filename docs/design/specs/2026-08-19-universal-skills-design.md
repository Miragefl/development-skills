# 通用化改造设计：Java 六件套 → 多语言开发 Skills

| 项 | 值 |
|---|---|
| 日期 | 2026-08-19 |
| 状态 | Draft（待用户复核） |
| 主题 | 现有六件套（context/doc/flow/test/debug/plan）通用化：通用层独立 + 语言定制包（stacks/） |
| 用户场景 | 自用多语言开发：Java（主力后端）、Swift（**macOS app**）、Go、Node/前端（后两者按需后补）；SQL 横切 |

---

## 1. 背景与目标

现有六件套的**流程骨架天然语言无关**（元信息机制 / TDD 循环 / 排查三铁律 / spec-plan 格式），但四个 reference 文件（CODING-STANDARDS / TEST-STRATEGIES / DEBUG-METHODS / DOC-FORMATS+DB-DESIGN）全是 Java 血肉。

**改造目标**：通用层独立 + 每门语言一个定制包（`stacks/<LANG>.md`）。加语言 = 加一个 md 文件，不动 skill 骨架。

**非开源定位**：为自己服务，按自己的语言栈定制，不迁就大众。

## 2. 架构选型（方案 A：每 skill 内挂 stacks/）

**决定性约束**：`install.sh` 把 `skills/<name>/` 整个目录软链到 `~/.claude/skills/<name>` → **skill 必须自包含** → 定制包必须在 skill 目录内，装出去相对路径（`./stacks/XX.md`）才不断。

| 方案 | 结论 |
|---|---|
| A. 每 skill 内 `stacks/` | ✅ 采用（自包含、软链安全、加语言=加文件） |
| B. 仓库级集中 `stacks/java/` | ❌ 否决（skill 软链后 `../../stacks/` 断链；救它要复杂化 install.sh） |
| C. 完全泛化删语言细节 | ❌ 否决（丢 Spring 分层等实战精华） |

## 3. 目录结构（改造后）

```
skills/
├── context/SKILL.md                          # 微调：fields 加 language
├── plan/{SKILL.md, PLAN-SPEC-FORMAT.md}      # 微调措辞（已几乎纯通用）
├── flow/
│   ├── SKILL.md                              # 加路由句
│   ├── CODING-STANDARDS.md                   # 通用层
│   └── stacks/{JAVA.md, SWIFT.md}            # 定制层
├── test/
│   ├── SKILL.md + TEST-STRATEGIES.md         # 同构
│   └── stacks/{JAVA.md, SWIFT.md}
├── debug/
│   ├── SKILL.md + DEBUG-METHODS.md           # 同构
│   └── stacks/{JAVA.md, SWIFT.md}
└── doc/
    ├── SKILL.md + DOC-FORMATS.md + DB-DESIGN.md   # DB-DESIGN 去 Java 例子
    └── stacks/{JAVA.md, SWIFT.md}
```

## 4. 两层拆分规则（搬家原则：Java 内容一个字不丢）

| 文件 | 通用层（留主 reference） | 定制层（搬 stacks/JAVA.md） |
|---|---|---|
| flow/CODING-STANDARDS | 总则（KISS/YAGNI/DRY/小函数/见名知意/无魔法值/低耦合）、SOLID（去 Java 例子）、GoF 原则（何时用/别用，去 Java 落地）、测试友好原则 | Spring 分层实战（Controller-Service-Repository/DTO-VO-Entity/构造器注入/统一异常/@Transactional）、Lombok @Builder、Spring 事件等 Java 落地 |
| test/TEST-STRATEGIES | TDD 三步循环、测行为不测实现、一测试一件事、全绿才重构、边界用例清单、Mock 策略原则、反模式 | JUnit5/Mockito/@SpringBootTest/@WebMvcTest/@DataJpaTest、Testcontainers、AssertJ 等 Java 工具速查 |
| debug/DEBUG-METHODS | 二分注释/二分提交/加日志/断点/隔离变量、验证假设手法、三铁律、反模式 | NPE/数据不生效/慢SQL/时好时坏/内存 等 Java 后端 bug 速查表 |
| doc/DOC-FORMATS | 三类文档概念 + 固定路径 + 格式模板（语言无关描述） | @RestController/@Entity/@TableName 扫描、Java→DB 类型映射、springdoc 适配 |
| doc/DB-DESIGN | 全部保留（本来就是建表规范，语言无关） | 文内 Java 例子改为中性（影响极小） |

## 5. 路由机制（核心）

1. `PROJECT-CONTEXT.md` **新增 `language` 字段**（必填：`java` / `swift` / `go` / `node` …）。
2. `jdk` 字段**语义泛化、字段名不动**（保持向后兼容）：模板注释改为「主语言运行时版本——Java 填 JDK 版本、Swift 填 Swift 版本、Go 填 Go 版本」。
3. 各 skill 主文件（flow/test/debug/doc 的 what-to-do 或 supporting-info）加一句路由：*遵循 <通用 reference>；若 `./stacks/<language>.md` 存在则一并遵循（language 读自 PROJECT-CONTEXT）*。
4. **优雅降级**：语言无定制包（如暂无 GO.md）→ 只用通用层，不报错。以后补 = 加文件。
5. context skill 引导创建 PROJECT-CONTEXT 时必填 language（扫码推断：`.swift` 文件多 → swift；`pom.xml` → java）。

## 6. Swift 定制包（macOS app 场景，新写 4 份）

| 文件 | 内容要点 |
|---|---|
| flow/stacks/SWIFT.md | SwiftUI/AppKit 架构（MVVM、View-Model 拆分）、值语义优先（struct/enum 为主，class 仅需引用语义时）、Optional 安全（强制解包禁令、guard let 惯用法）、协议导向、async/await + MainActor、命名规范（Swift API Design Guidelines） |
| test/stacks/SWIFT.md | XCTest / Swift Testing（@Test/#expect）、protocol-based mock、ViewModel 单测、View 逻辑下沉到可测层 |
| debug/stacks/SWIFT.md | 速查：强制解包崩溃、retain cycle（闭包捕获 self）/内存泄漏、MainActor 界面卡死、并发数据竞争、SwiftUI 状态不刷新 |
| doc/stacks/SWIFT.md | macOS app 场景：数据模型文档（struct 字段表）+ 模块文档（窗口/功能模块）；**REST 接口文档弱化**（app 无对外 HTTP 接口，仅网络层调后端时记 API 客户端约定）；DB 脚本类不适用（除非 App 用 Core Data/SwiftData，则记模型） |

## 7. 零改动项

- `install.sh`：**零改动**（stacks/ 在 skill 目录内，软链自包含）。
- `opencode/commands/`：**零改动**（command 只引导加载 skill，语言路由在 skill 内部）。
- `lib/`、`tools/validate.sh`：零改动（validate 只认 SKILL.md，stacks/*.md 不在校验范围）。

## 8. 改造文件清单

| 操作 | 文件 |
|---|---|
| 改（拆通用层） | flow/CODING-STANDARDS.md、test/TEST-STRATEGIES.md、debug/DEBUG-METHODS.md、doc/DOC-FORMATS.md、doc/DB-DESIGN.md（微） |
| 新（Java 定制） | flow|test|debug|doc 各 stacks/JAVA.md（内容从原文件搬） |
| 新（Swift 定制） | flow|test|debug|doc 各 stacks/SWIFT.md（macOS 场景新写） |
| 改（路由句） | flow/test/debug/doc 各 SKILL.md |
| 改（language 字段） | PROJECT-CONTEXT.template.md、context/SKILL.md |
| 微调 | plan/PLAN-SPEC-FORMAT.md |
| 同步 | README.md、本 spec 关联的 §12 演进记录 |

## 9. 非目标（YAGNI）

- **Go / Node 定制包**：真用到了再补（每个一个 md，半小时的事）。
- 不做开源适配（多用户配置、贡献指南、语言包注册机制）。
- SQL 不做独立定制包（DB-DESIGN + `db` 字段方言路由已覆盖，属现有机制）。

## 10. 风险与对策

| 风险 | 对策 |
|---|---|
| 拆分丢 Java 内容 | 搬家原则：原样搬不删改；拆完抽查关键条目（Spring 分层/JUnit 速查等）在 JAVA.md 中存在 |
| language 字段缺失/未填 | 优雅降级（只用通用层）+ context skill 创建时扫码推断并必填 |
| 软链后 stacks/ 路径断 | 方案 A 已规避（skill 内相对路径）；改造后 HOME 重定向安装测试验证 |

## 11. 验证

1. `./tools/validate.sh` 全绿（skill 合规不受影响）。
2. 拆分完整性抽查：原文件关键条目 ⊆ 通用层 + stacks/JAVA.md。
3. 安装测试：`HOME=tmp ./install.sh` 后，skill 内 `./stacks/JAVA.md` 相对引用可达（软链跟随）。
4. Swift 四份定制包内容审阅（macOS 场景对路）。
