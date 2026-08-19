# 通用化改造实现计划（Java 六件套 → 多语言 Skills）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 六件套通用化——reference 拆「通用层 + stacks/<LANG>.md 语言定制层」，PROJECT-CONTEXT 加 language 字段路由；第一批定制包 JAVA（搬迁）+ SWIFT（macOS 场景新写）。

**Architecture:** skill 主文件与流程骨架不动；四个带 reference 的 skill（flow/test/debug/doc）各拆两层：通用层留在主 reference（去语言例子），语言细节搬 `stacks/JAVA.md`；skill 内相对路径自包含，install.sh/commands 零改动。

**Tech Stack:** Markdown（SKILL.md / reference / stacks）、YAML frontmatter。

## Global Constraints

- **搬家原则**：现有 Java 内容一个字不丢——原样搬进 `stacks/JAVA.md`，只换位置。
- **路由机制**：`PROJECT-CONTEXT.md` 新增 `language` 字段（必填：java/swift/go/node…）；各 skill 主文件加路由句；**无对应 stacks 文件时优雅降级**（只用通用层，不报错）。
- **`jdk` 字段语义泛化、字段名不动**（向后兼容）：注释改「主语言运行时版本」。
- **skill 自包含**：stacks/ 必须在 skill 目录内（install.sh 软链整个 skill 目录，外部相对路径会断）。
- **零改动项**：install.sh、opencode/commands/、lib/、tools/validate.sh（validate 只认 SKILL.md）。
- **Swift 场景 = macOS app**（SwiftUI 为主、AppKit 混用），不是 iOS/Vapor。
- **每个 task 完成即 commit**（本仓库 git 已授权提交流程）。
- 参考 spec：`docs/design/specs/2026-08-19-universal-skills-design.md`。

---

## File Structure

| 文件 | 操作 | 职责 |
|---|---|---|
| `PROJECT-CONTEXT.template.md` | 改 | 加 language 字段；jdk 注释泛化 |
| `skills/context/SKILL.md` | 改 | fields 加 language；扫码推断 language |
| `skills/flow/CODING-STANDARDS.md` | 改 | 通用层（去 Java 例子） |
| `skills/flow/stacks/JAVA.md` | 新 | Spring 分层等 Java 定制（搬迁） |
| `skills/flow/stacks/SWIFT.md` | 新 | Swift/macOS 编码定制 |
| `skills/flow/SKILL.md` | 改 | 加路由句 |
| `skills/test/TEST-STRATEGIES.md` | 改 | 通用层 |
| `skills/test/stacks/JAVA.md` | 新 | JUnit/Mockito 等速查（搬迁） |
| `skills/test/stacks/SWIFT.md` | 新 | Swift Testing/XCTest/mock |
| `skills/test/SKILL.md` | 改 | 路由句 |
| `skills/debug/DEBUG-METHODS.md` | 改 | 通用层 |
| `skills/debug/stacks/JAVA.md` | 新 | Java bug 速查（搬迁） |
| `skills/debug/stacks/SWIFT.md` | 新 | Swift/macOS bug 速查 |
| `skills/debug/SKILL.md` | 改 | 路由句 |
| `skills/doc/DOC-FORMATS.md` | 改 | 通用层 |
| `skills/doc/DB-DESIGN.md` | 微 | 去 Java 痕迹 |
| `skills/doc/stacks/JAVA.md` | 新 | 注解扫描/类型映射/springdoc（搬迁） |
| `skills/doc/stacks/SWIFT.md` | 新 | macOS 文档适配 |
| `skills/doc/SKILL.md` | 改 | 路由句 |
| `skills/plan/PLAN-SPEC-FORMAT.md` | 微 | 约束节提 language |
| `README.md` | 改 | 通用化说明 + stacks 机制 |

依赖线性：T1(路由基础) → T2-T5(四 skill 拆层) → T6(Swift 包) → T7(文档) → T8(端到端验证)。

---

### Task 1: language 字段与 context skill 路由基础

**Files:**
- Modify: `PROJECT-CONTEXT.template.md`
- Modify: `skills/context/SKILL.md`

**Interfaces:**
- Produces: `PROJECT-CONTEXT.md` 的 `language` 字段（所有后续 task 的路由依赖它）。

- [ ] **Step 1: 改 PROJECT-CONTEXT.template.md（加 language + jdk 泛化）**

用 Edit 替换字段区开头两行：

```
旧：
- jdk: 17                           # JDK 版本，如 8 / 11 / 17 / 21
- build: maven                      # 构建工具：maven | gradle

新：
- language: java                    # 主开发语言：java | swift | go | node（skill 按它加载 stacks/<语言>.md 定制层）
- jdk: 17                           # 主语言运行时版本：Java 填 JDK 版本 / Swift 填 Swift 版本 / Go 填 Go 版本
- build: maven                      # 构建工具：Java 用 maven | gradle；Swift 用 xcodebuild/spm；Go 用 go；Node 用 npm/pnpm
```

同时把文件头说明第三行「字段名（jdk/build/db 等）保持英文——它们是 skill 机器解析的 key」后追加：「`language` 是语言定制层的路由 key」。

- [ ] **Step 2: 改 context/SKILL.md（扫码推断 language + fields 更新）**

what-to-do 第 1 步扫码推断清单里加 language 推断；supporting-info 的 fields 列表加 language。两处 Edit：

Edit A（扫码推断，第 1 步第 1 条内）：
```
旧：…`pom.xml` → `build: maven`, `build.gradle` → `build: gradle`; …
新：…`pom.xml` → `build: maven` + `language: java`, `build.gradle` → `build: gradle` + `language: java`; 多数源文件为 `.swift` → `language: swift`; `go.mod` → `language: go`; `package.json` 为主 → `language: node`; …
```

Edit B（fields 列表）：
```
旧：Fields: jdk, build, build_cmd, run_cmd, test_cmd, db, orm, package, doc_root, modules, notes.
新：Fields: language (required — routes stacks/<lang>.md), jdk (主语言运行时版本), build, build_cmd, run_cmd, test_cmd, db, orm, package, doc_root, modules, notes.
```

- [ ] **Step 3: 验证**

```bash
grep -q 'language: java' PROJECT-CONTEXT.template.md && echo "PASS: 模板含 language"
grep -q 'language (required' skills/context/SKILL.md && echo "PASS: context skill 更新"
./tools/validate.sh   # 六个 OK
```

- [ ] **Step 4: Commit**

```bash
git add PROJECT-CONTEXT.template.md skills/context/SKILL.md
git commit -m "feat(context): 加 language 路由字段 + jdk 语义泛化"
```

---

### Task 2: flow 拆层（CODING-STANDARDS 通用化 + JAVA 搬迁 + 路由句）

**Files:**
- Modify: `skills/flow/CODING-STANDARDS.md`（重写为通用层）
- Create: `skills/flow/stacks/JAVA.md`
- Modify: `skills/flow/SKILL.md`（路由句）

**Interfaces:**
- Consumes: Task 1 的 language 字段。
- Produces: `stacks/JAVA.md` / `stacks/SWIFT.md` 的引用约定（后续 task 同构复用此模式）。

- [ ] **Step 1: 重写 CODING-STANDARDS.md 为通用层**

完整内容：

```markdown
# 编码规范·通用层（可维护性 + 设计模式）

供 flow「实现」步骤遵循，语言无关。语言/栈特定规范见 `stacks/<language>.md`（language 读自 PROJECT-CONTEXT.md；无对应文件则只用本层）。

## 1. 总则（可维护性基础）

- **KISS**：能用简单方案别炫技。复杂度要为真实需求买单。
- **YAGNI**：别为"以后可能用得上"预留抽象。用到了再抽。
- **DRY**：重复三次就抽。但别为 DRY 把不相关的东西硬塞一起。
- **小函数**：一个函数 ≤30 行，只干一件事。超过就拆。
- **见名知意**：`processOrder()` 好，`doStuff()` 坏。别省字母到看不懂。
- **无魔法值**：`if (status == 3)` 坏，`if (status == OrderStatus.PAID)` 好。常量/枚举。
- **低耦合高内聚**：改一个功能只动一个地方；一个模块里的东西都相关。

## 2. SOLID

- **S 单一职责**：一个类/函数只有一个变更理由。展示层不写业务，业务层不碰存储细节。
- **O 开闭原则**：加功能靠新实现扩展，不改老代码。策略模式是常用手段。
- **L 里氏替换**：子类型能完整替代基类型，别在用基类的地方偷偷判断具体类型。
- **I 接口隔离**：接口按消费方裁剪，别造"全能大接口"。多个窄接口好过一个胖接口。
- **D 依赖倒置**：依赖抽象/接口，不依赖具体实现。

## 3. GoF 设计模式（按场景用，别为用而用）

- **策略模式**：替换一坨 `if-else`/`switch`。何时用：分支会持续增加。何时别用：就两三个固定分支。
- **工厂方法**：创建逻辑复杂或需按类型造。何时用：创建时一堆判断。何时别用：直接 new 就够。
- **建造者**：构造参数多（≥4）或有可选参数。何时用：构造函数参数爆炸。
- **模板方法**：流程固定、各步可变。何时用：多处相同骨架不同细节。何时别用：流程就一处。
- **观察者/事件**：解耦"做完 X 后要做 Y"。何时用：Y 不该阻塞 X、或有多个 Y。何时别用：就是顺序调用。

## 4. 测试友好

- **依赖注入便于 mock**：依赖通过构造/参数注入，别在函数里硬造依赖。
- **单一职责好测**：一个函数只干一件事，用例才清晰。
- **纯函数优先**：无副作用最好测。把 IO/时间/随机隔离到边界。
- **依赖接口**：mock 只 mock 接口不碰实现。
- **别滥用静态/全局**：难 mock、难扩展。工具函数才用，业务逻辑别用。

---

_原则是工具不是教条。拿不准时，选更简单、更易测的那个。_
```

- [ ] **Step 2: 建 stacks/JAVA.md（原 Java 内容搬迁，一字不丢）**

```bash
mkdir -p skills/flow/stacks
```

完整内容：

```markdown
# Java/Spring 编码定制

配合 `../CODING-STANDARDS.md` 通用层使用（PROJECT-CONTEXT.md 的 `language: java` 时加载）。

## 后端分层实战

- **三层职责**：
  - `Controller`：接收参数、校验、编排调用、返回 VO。**不写业务逻辑**。
  - `Service`：业务逻辑、事务边界。**不直接拼 SQL 细节**（用 Repository/Mapper）。
  - `Repository/Mapper`：数据访问。**不掺业务判断**。
- **对象分层**：`DTO`(入参) · `VO`(出参) · `Entity`(表映射) · `Param`(内部传递)。**别拿 Entity 直接返给前端**。
- **构造器注入**：用 `@RequiredArgsConstructor` + `final` 字段，别用字段注入（`@Autowired` 写在字段上）。
- **统一异常**：`@RestControllerAdvice` + 自定义业务异常，Controller 不写 try-catch 堆。
- **事务边界**：`@Transactional` 标在 Service 方法，别标 Controller；只读查询用 `@Transactional(readOnly=true)`。

## Java 特有落地

- **建造者**：Lombok `@Builder`（构造参数 ≥4 时）。
- **观察者/事件**：Spring `ApplicationEvent`。
- **依赖倒置日常形态**：`@Autowired` 注入接口实现即 DIP。
```

- [ ] **Step 3: flow/SKILL.md 加路由句**

Edit「实现」步骤：

```
旧：…可维护性与设计模式遵循 [CODING-STANDARDS.md](./CODING-STANDARDS.md)（SOLID/分层/模式/可测试性）。
新：…可维护性与设计模式遵循 [CODING-STANDARDS.md](./CODING-STANDARDS.md)（SOLID/模式/可测试性）+ `./stacks/<language>.md` 语言定制层（language 读自 PROJECT-CONTEXT.md；文件不存在则只用通用层）。
```

- [ ] **Step 4: 验证（含搬迁完整性抽查）**

```bash
./tools/validate.sh
grep -q '事务边界' skills/flow/stacks/JAVA.md && echo "PASS: Spring 分层已搬入"
grep -q '@RequiredArgsConstructor' skills/flow/stacks/JAVA.md && echo "PASS: 构造器注入已搬入"
grep -q 'stacks/<language>' skills/flow/SKILL.md && echo "PASS: 路由句在"
! grep -q '@Transactional' skills/flow/CODING-STANDARDS.md && echo "PASS: 通用层已无 Java 痕迹"
```

- [ ] **Step 5: Commit**

```bash
git add skills/flow/
git commit -m "refactor(flow): CODING-STANDARDS 拆通用层 + stacks/JAVA.md 搬迁 + language 路由"
```

---

### Task 3: test 拆层

**Files:**
- Modify: `skills/test/TEST-STRATEGIES.md`（通用层）
- Create: `skills/test/stacks/JAVA.md`
- Modify: `skills/test/SKILL.md`（路由句）

- [ ] **Step 1: 重写 TEST-STRATEGIES.md 为通用层**

完整内容：

```markdown
# 测试策略·通用层

供 test 的「定层」「补边界」「重构」参考，语言无关。工具/框架速查见 `stacks/<language>.md`。

## 测试分层（测什么层）

| 层 | 测什么 | 依赖处理 |
|---|---|---|
| 单元（逻辑层） | 业务逻辑、分支、计算 | mock 掉依赖（存储/网络/外部） |
| 集成（边界） | 接口契约、参数校验、异常映射 | mock 内部实现或用真组件 |
| 存储/DAO | 存取正确、映射、事务 | 内存库或测试库 |

**不混层**：单元测试别起重型容器（慢且耦合）；集成测试别 mock 掉被测对象本身。

## TDD 三步循环

```
Red       写一个会失败的测试（描述期望行为）
Green     写最少代码让它通过
Refactor  测试全绿下重构
```

- Red 必须因**预期断言失败**，不是编译错或崩溃。
- Green 写最少代码，别提前实现下个需求。
- 没有测试绿灯就别重构。

## Mock 策略

- **Mock 依赖，不 Mock 被测**：测逻辑层就 mock 它的依赖，被测对象本身用真实实现。
- **构造注入便于 mock**：依赖走构造/参数注入（见 CODING-STANDARDS 测试友好），测试直接传 mock。
- **别 mock 值对象**：数据结构用真实实例构造。

## 边界用例清单（每个功能至少想一遍）

- null / 空集合 / 空字符串
- 越界（负数、超大、超长）
- 并发（同一资源多线程）
- 异常路径（依赖抛异常 → 我的处理对吗）
- 权限 / 越权
- 时间 / 时区
- 幂等（重复调用）

## 反模式

- ❌ 测私有方法（反射测内部 = 绑死实现）
- ❌ 一个测试断言八件事（挂了不知道哪个）
- ❌ 测试依赖执行顺序
- ❌ mock 被测对象本身
- ❌ 测试里 sleep / 依赖网络 / 依赖系统时间（脆弱）
- ❌ 为覆盖率写无意义测试
```

- [ ] **Step 2: 建 stacks/JAVA.md（Java 工具速查搬迁）**

```bash
mkdir -p skills/test/stacks
```

完整内容：

```markdown
# Java 测试定制

配合 `../TEST-STRATEGIES.md` 通用层使用（`language: java` 时加载）。

## Java 分层对应

| 层 | 工具 |
|---|---|
| 单元 | JUnit 5 + Mockito（纯 JVM，不起 Spring） |
| Web 切片 | `@WebMvcTest(Controller)` + MockMvc |
| JPA 切片 | `@DataJpaTest` |
| MyBatis-Plus 切片 | `@MybatisPlusTest` |
| 全集成 | `@SpringBootTest` + Testcontainers（MySQL/Redis） |
| 断言 | AssertJ（流式，比原生可读） |
| 参数化 | `@ParameterizedTest` + `@CsvSource` / `@MethodSource` |

## Mockito 速记

- `when(mock.foo(any())).thenReturn(x)` 打桩
- `verify(mock, times(1)).foo(any())` 验证调用
- `assertThrows(BizEx.class, () -> svc.call())` 断言异常

## 原「测试分层」Java 表（保留备查）

| 层 | 测什么 | 怎么测 | 依赖处理 |
|---|---|---|---|
| 单元（Service/逻辑） | 业务逻辑、分支、计算 | 纯 JUnit | mock 掉 Mapper/外部调用 |
| 集成（Controller） | 接口契约、参数校验、异常映射 | @SpringBootTest / MockMvc / @WebMvcTest | mock Service 或用真组件 |
| DAO（Mapper/Repository） | SQL 正确、映射、事务 | @MybatisPlusTest / @DataJpaTest / H2 | 内存库或 Testcontainers |
| 契约（可选） | 对外 API 稳定性 | Spring Cloud Contract / Pact | — |
```

- [ ] **Step 3: test/SKILL.md 加路由句**

Edit：SKILL.md 中「测试分层、TDD 细节、Mock 策略、Java 后端测试速查见 [TEST-STRATEGIES.md](./TEST-STRATEGIES.md).」改为：

```
测试分层、TDD、Mock 策略见 [TEST-STRATEGIES.md](./TEST-STRATEGIES.md)（通用层）；语言工具速查见 `./stacks/<language>.md`（language 读自 PROJECT-CONTEXT.md；不存在则只用通用层）。
```

- [ ] **Step 4: 验证**

```bash
./tools/validate.sh
grep -q 'Mockito' skills/test/stacks/JAVA.md && echo "PASS: Mockito 已搬入"
grep -q '@SpringBootTest' skills/test/stacks/JAVA.md && echo "PASS: Spring 测试已搬入"
! grep -q 'Mockito' skills/test/TEST-STRATEGIES.md && echo "PASS: 通用层无 Java 痕迹"
```

- [ ] **Step 5: Commit**

```bash
git add skills/test/
git commit -m "refactor(test): TEST-STRATEGIES 拆通用层 + stacks/JAVA.md + language 路由"
```

---

### Task 4: debug 拆层

**Files:**
- Modify: `skills/debug/DEBUG-METHODS.md`（通用层）
- Create: `skills/debug/stacks/JAVA.md`
- Modify: `skills/debug/SKILL.md`（路由句）

- [ ] **Step 1: 重写 DEBUG-METHODS.md 为通用层**

完整内容：

```markdown
# Debug 排查手法·通用层

供 debug 的「隔离」「假设」「验证」步骤参考，语言无关。语言/平台 bug 速查见 `stacks/<language>.md`。

## 隔离手法（缩小范围）

- **二分注释**：注释掉一半代码/配置，看 bug 还在不在，再二分。快速定位区块。
- **二分提交**：bug 是新引入的？`git bisect` 二分提交历史找回归 commit。
- **加日志**：在关键路径打参数/状态/分支日志，看实际走到哪。
- **断点调试**：IDE 条件断点（命中特定参数/状态时停）。
- **隔离变量**：固定输入，逐步排除外部因素（DB / 缓存 / 网络 / 并发）。

## 验证假设

- **临时单测**：针对假设写个失败的单测，确认假设后改成回归测试。
- **最小改动验证**：只改假设涉及的那一行，看症状是否消失。
- **日志验证**：在假设点加日志，确认变量值符合/不符合预期。
- **错就换**：假设验证不成立，立刻换下一个，别执着。

## 反模式（别这么干）

- ❌ 不复现就改代码
- ❌ 改一行试一下，不行再改一行（撞运气）
- ❌ 吞掉异常不处理
- ❌ 只修症状不查根因（"加个判空"而不问为啥是空）
- ❌ 改完不跑测试就说"应该好了"
```

- [ ] **Step 2: 建 stacks/JAVA.md（Java bug 速查搬迁）**

```bash
mkdir -p skills/debug/stacks
```

完整内容：

```markdown
# Java 后端 Bug 速查

配合 `../DEBUG-METHODS.md` 通用层使用（`language: java` 时加载）。按症状先查：

| 症状 | 先查 |
|---|---|
| NullPointerException | 哪个对象 null；是否未初始化 / 被并发清空 / 接口返回空 |
| 数据不生效 / 脏数据 | 事务是否提交；update 是否命中；缓存是否挡住 |
| 慢 / 超时 | 慢 SQL（看执行计划）/ N+1 查询 / 锁等待 / 外部调用超时 |
| 时好时坏 | 并发（竞态、可见性）/ 缓存 / 环境差异 / 数据依赖顺序 |
| 接口 404 / 参数错 | 路由匹配 / 参数绑定 / 拦截器 / Content-Type |
| 内存 / Full GC | 大对象 / 内存泄漏 / 连接未关 / 缓存无上限 |
```

- [ ] **Step 3: debug/SKILL.md 加路由句**

Edit：「排查手法与常见 Java bug 速查见 [DEBUG-METHODS.md](./DEBUG-METHODS.md).」改为：

```
排查手法见 [DEBUG-METHODS.md](./DEBUG-METHODS.md)（通用层）；语言 bug 速查见 `./stacks/<language>.md`（language 读自 PROJECT-CONTEXT.md；不存在则只用通用层）。
```

- [ ] **Step 4: 验证**

```bash
./tools/validate.sh
grep -q 'NullPointerException' skills/debug/stacks/JAVA.md && echo "PASS: NPE 速查已搬入"
! grep -q 'NullPointerException' skills/debug/DEBUG-METHODS.md && echo "PASS: 通用层无 Java 痕迹"
```

- [ ] **Step 5: Commit**

```bash
git add skills/debug/
git commit -m "refactor(debug): DEBUG-METHODS 拆通用层 + stacks/JAVA.md + language 路由"
```

---

### Task 5: doc 拆层（DOC-FORMATS + DB-DESIGN + JAVA 搬迁）

**Files:**
- Modify: `skills/doc/DOC-FORMATS.md`（通用层）
- Modify: `skills/doc/DB-DESIGN.md`（微调去 Java 痕迹）
- Create: `skills/doc/stacks/JAVA.md`
- Modify: `skills/doc/SKILL.md`（路由句）

- [ ] **Step 1: 重写 DOC-FORMATS.md 为通用层**

完整内容：

```markdown
# 文档格式规范·通用层

供 doc 生成三类文档时遵循，语言无关。语言触发点/类型映射见 `stacks/<language>.md`。固定路径根 = PROJECT-CONTEXT.md 的 `doc_root`（默认 `docs/`）。

## 1. 接口文档 `<doc_root>/api/<模块>.md`

按业务模块聚合。每个接口一段（后端服务场景；app 场景见 stacks 适配）：

```md
## POST /api/orders

创建订单

- **Method**: POST
- **入参** (`OrderCreateReq`):
  | 字段 | 类型 | 必填 | 说明 |
  |---|---|---|---|
  | userId | Long | 是 | 用户ID |
- **出参** (`OrderVO`): 见 data-model/orders.md#OrderVO
- **示例**:
  请求: `{"userId":1}`
  响应: `{"code":0,"data":{...}}`
```

有标准 OpenAPI/契约来源时优先以其为准生成，并在文件头注明来源。

## 2. 数据模型文档 `<doc_root>/data-model/<实体名>.md`

```md
# Order

对应存储: `t_order`

| 字段 | 语言类型 | 列/键 | 存储类型 | 说明 | 约束 |
|---|---|---|---|---|---|
| id | Long | id | bigint | 主键 | PK |
```

## 3. DB 脚本 `<doc_root>/db/`

- `schema.sql`: 全量建表 DDL（按 `db` 方言）。
- `migrations/`: 每次结构变更追加 `V<日期>_<简述>.sql`。
- 设计规范见 [DB-DESIGN.md](./DB-DESIGN.md)。

## 懒加载

仅当确有内容时创建文件/目录；不预生成空骨架。生成前一句话说明意图；只追加/更新对应段落，不擅自删除。
```

- [ ] **Step 2: 建 doc/stacks/JAVA.md（触发点/映射搬迁）**

```bash
mkdir -p skills/doc/stacks
```

完整内容：

```markdown
# Java 文档定制

配合 `../DOC-FORMATS.md` 通用层使用（`language: java` 时加载）。

## 触发点（写/改以下时同步文档）

- `@RestController` / `@Controller` / `@*Mapping` → `api/<模块>.md`
- `@Entity` / `@TableName` / DTO / VO → `data-model/<实体名>.md`
- 建表/改表 SQL、Entity 字段变更 → `db/schema.sql` (+ `db/migrations/V*.sql`)

## Java → DB 类型映射（默认，按 db 方言调整）

- Long → bigint / BIGINT
- String → varchar(n) / VARCHAR
- BigDecimal → decimal(p,s) / NUMERIC
- LocalDateTime → datetime / TIMESTAMP
- Boolean → tinyint(1) / BOOLEAN

## OpenAPI 增强

若依赖含 `springdoc-openapi`，优先读 `/v3/api-docs` JSON 生成接口文档。
```

- [ ] **Step 3: DB-DESIGN.md 微调**

Edit 数据模型文档示例行，去 Java 痕迹：

```
旧：`| 字段 | Java 类型 | 列名 | DB 类型 | 说明 | 约束 |`（若存在）
新：`| 字段 | 语言类型 | 列名 | DB 类型 | 说明 | 约束 |`
```
（DB-DESIGN.md 本身以建表规范为主、语言无关；只把残留的 "Java" 字样中性化。执行时 `grep -n 'Java' skills/doc/DB-DESIGN.md` 逐处改为中性表述。）

- [ ] **Step 4: doc/SKILL.md 加路由句**

Edit：「Follow the formats in [DOC-FORMATS.md](./DOC-FORMATS.md). 生成/改 DDL（`db/schema.sql`、migrations）时遵循建表设计规范 [DB-DESIGN.md](./DB-DESIGN.md)…」后追加一句：

```
触发点与类型映射见 `./stacks/<language>.md`（language 读自 PROJECT-CONTEXT.md；不存在则按通用层描述扫描）。
```

- [ ] **Step 5: 验证**

```bash
./tools/validate.sh
grep -q '@RestController' skills/doc/stacks/JAVA.md && echo "PASS: 触发点已搬入"
grep -q 'springdoc' skills/doc/stacks/JAVA.md && echo "PASS: OpenAPI 已搬入"
! grep -q '@RestController' skills/doc/DOC-FORMATS.md && echo "PASS: 通用层无 Java 痕迹"
grep -c 'Java' skills/doc/DB-DESIGN.md   # 应为 0 或仅中性提法
```

- [ ] **Step 6: Commit**

```bash
git add skills/doc/
git commit -m "refactor(doc): DOC-FORMATS 拆通用层 + stacks/JAVA.md + DB-DESIGN 去 Java 痕迹"
```

---

### Task 6: Swift/macOS 定制包 ×4（新写）

**Files:**
- Create: `skills/flow/stacks/SWIFT.md`
- Create: `skills/test/stacks/SWIFT.md`
- Create: `skills/debug/stacks/SWIFT.md`
- Create: `skills/doc/stacks/SWIFT.md`

- [ ] **Step 1: flow/stacks/SWIFT.md**

```markdown
# Swift/macOS 编码定制

配合 `../CODING-STANDARDS.md` 通用层使用（`language: swift` 时加载）。场景：macOS app（SwiftUI 为主，AppKit 混用）。

## 架构分层（macOS app）

- **MVVM**：View（SwiftUI，只管渲染）→ ViewModel（`@Observable`，状态+逻辑）→ Model（数据）。**View 不写业务逻辑**。
- **View 薄 ViewModel 厚**：View 只有布局和绑定；校验/编排/转换下沉 ViewModel，才可测。
- **服务层**：网络/磁盘/系统能力封装成 Service（protocol 定义），ViewModel 依赖 protocol，便于 mock。

## Swift 语言要点

- **值语义优先**：Model 用 `struct`/`enum`；仅需要引用语义（共享可变状态、生命周期管理）才用 `class`。
- **Optional 安全**：**禁强制解包 `!`**（测试代码除外）；`guard let` 早退、`if let`/`??`/`?.` 处理。`try!`/`as!` 同禁。
- **协议导向**：能力用 `protocol` 抽（Service 注入、mock），别靠继承基类。
- **并发**：`async/await` 为主；UI 操作回 `@MainActor`；后台用 `Task`/`TaskGroup`；共享可变状态用 `actor`。
- **命名**：遵循 Swift API Design Guidelines（调用点读起来像句子：`fetchOrders(for: userID)`）；类型大驼峰、方法/变量小驼峰。

## AppKit 混用

- SwiftUI 为主；仅 SwiftUI 覆盖不了时用 `NSViewRepresentable` 包 AppKit。
- 菜单栏/多窗口/生命周期用 SwiftUI 原生（`MenuBarExtra`/`WindowGroup`/Scene），别硬上 AppKit。
```

- [ ] **Step 2: test/stacks/SWIFT.md**

```markdown
# Swift/macOS 测试定制

配合 `../TEST-STRATEGIES.md` 通用层使用（`language: swift` 时加载）。

## 工具

| 场景 | 工具 |
|---|---|
| 单元 | Swift Testing（`@Test` / `#expect`）或 XCTest |
| 异步 | `async` 测试方法 + `await #expect(...)` |
| Mock | protocol-based：Service 定义 protocol，测试写 Mock 实现 |
| UI/集成 | XCUITest（重，按需别滥写） |

## macOS app 策略

- **重点测 ViewModel 与 Service**（逻辑都在那）；**View 不测**（声明式 UI，性价比低）——逻辑想可测就下沉 ViewModel。
- **Mock 注入示例**：

```swift
protocol OrderServiceProtocol { func fetch() async throws -> [Order] }

@Observable final class OrderViewModel {
    private let service: OrderServiceProtocol
    var orders: [Order] = []
    init(service: OrderServiceProtocol) { self.service = service }
    func load() async { orders = (try? await service.fetch()) ?? [] }
}

struct MockOrderService: OrderServiceProtocol {
    var result: [Order] = []
    func fetch() async throws -> [Order] { result }
}

@Test func loadFillsOrders() async {
    let vm = OrderViewModel(service: MockOrderService(result: [.sample]))
    await vm.load()
    #expect(vm.orders.count == 1)
}
```

## Swift 特有边界

- Optional 为 nil 分支
- 快速连续调用的竞态
- 非 @MainActor 改 UI 状态
```

- [ ] **Step 3: debug/stacks/SWIFT.md**

```markdown
# Swift/macOS Bug 速查

配合 `../DEBUG-METHODS.md` 通用层使用（`language: swift` 时加载）。按症状先查：

| 症状 | 先查 |
|---|---|
| 崩溃 EXC_BAD_INSTRUCTION | 强制解包 `!` / `try!` / 数组越界 / `as!` 失败 |
| 内存涨不跌、对象不释放 | 闭包捕获 self（retain cycle）→ `[weak self]`；订阅未取消 |
| 界面卡死/转圈 | 主线程干重活（耗时操作缺后台 Task）；死锁（主线程等主线程） |
| 界面不刷新 | 状态是否 `@Observable`/`@Published`；是否在非 @MainActor 改 UI 状态 |
| 数据竞争/诡异崩溃 | 共享可变 class 无 actor/锁保护 |
| 文件读写失败 | App Sandbox 允许目录；entitlements 配置 |
| SwiftUI 布局异常 | 视图 identity 不稳（id 变化）；body 里写副作用 |

## Swift 专项手法

- **retain cycle**：Xcode → Debug → View Memory Graph。
- **主线程卡顿**：Instruments → Time Profiler。
- **并发问题**：开 Thread Sanitizer 跑复现。
```

- [ ] **Step 4: doc/stacks/SWIFT.md**

```markdown
# Swift/macOS 文档定制

配合 `../DOC-FORMATS.md` 通用层使用（`language: swift` 时加载）。macOS app 场景对三类文档的适配：

## 三类文档适配

| 通用文档 | macOS app 适配 |
|---|---|
| `api/` | **弱化**：app 无对外 HTTP 接口。若网络层调后端，在 `api/` 记 API 客户端约定（调哪些后端接口、参数/响应模型） |
| `data-model/` | **主力**：核心 Model（struct）字段表；用 Core Data/SwiftData 则记实体与关系 |
| `db/` | 不适用（除非 app 内嵌 SQLite/Core Data，则记模型迁移） |

## 触发点

- 核心 Model `struct`/`enum`（业务实体）→ `data-model/<模型>.md`
- 网络层 API 客户端新增/修改 → `api/<模块>.md`
- Core Data/SwiftData 模型变更 → `data-model/` + 迁移记录

## 模块文档（macOS 补充）

建议 `doc_root/modules/<模块>.md`：窗口/功能模块的职责、入口、依赖（主窗口 / 设置 / 菜单栏等模块）。
```

- [ ] **Step 5: 验证**

```bash
./tools/validate.sh
for f in flow test debug doc; do
  test -f skills/$f/stacks/SWIFT.md && echo "PASS: $f/SWIFT.md" || echo "FAIL: $f/SWIFT.md"
done
grep -q '@Observable' skills/flow/stacks/SWIFT.md && echo "PASS: macOS 场景内容在"
```

- [ ] **Step 6: Commit**

```bash
git add skills/
git commit -m "feat(stacks): 新增 Swift/macOS 定制包 ×4（flow/test/debug/doc）"
```

---

### Task 7: plan 微调 + README 同步

**Files:**
- Modify: `skills/plan/PLAN-SPEC-FORMAT.md`
- Modify: `README.md`

- [ ] **Step 1: PLAN-SPEC-FORMAT.md 微调**

Edit spec 模板「约束」节：

```
旧：- 技术栈/版本（读 PROJECT-CONTEXT.md）
新：- 技术栈/语言（读 PROJECT-CONTEXT.md 的 language 及版本字段）
```

- [ ] **Step 2: README 同步通用化**

Edit 首段：

```
旧：一套精简的自有 Java 后端开发 Skills，给 Claude Code 与 OpenCode 双工具通用。六个职责单一的 skill + 一个共享元信息底座。
新：一套精简的多语言开发 Skills（通用层 + 语言定制包），给 Claude Code 与 OpenCode 双工具通用。六个职责单一的 skill + 共享元信息底座；内置 Java 与 Swift(macOS) 定制包，其他语言加一个 stacks/<LANG>.md 即可。
```

并在「## 使用」第 1 条后加：

```
   - `PROJECT-CONTEXT.md` 的 `language` 字段决定加载哪门语言的定制规范（`skills/*/stacks/<LANG>.md`）；没有对应包则只用通用层。
```

（README 其余 Java 表述逐处扫一遍改中性：`grep -n 'Java 后端' README.md` 逐条改为「后端/开发」。）

- [ ] **Step 3: 验证 + Commit**

```bash
grep -q '多语言' README.md && echo "PASS: README 通用化"
git add README.md skills/plan/
git commit -m "docs: README/plan 同步通用化（language 路由说明）"
```

---

### Task 8: 端到端验证

- [ ] **Step 1: validate 全绿**

```bash
./tools/validate.sh; echo "退出码应为 0"
```

- [ ] **Step 2: 拆分完整性抽查（Java 内容一个字不丢）**

```bash
grep -q '事务边界' skills/flow/stacks/JAVA.md && grep -q '@RequiredArgsConstructor' skills/flow/stacks/JAVA.md && echo "PASS: flow Java 内容在"
grep -q 'Mockito' skills/test/stacks/JAVA.md && grep -q '@WebMvcTest' skills/test/stacks/JAVA.md && echo "PASS: test Java 内容在"
grep -q 'NullPointerException' skills/debug/stacks/JAVA.md && echo "PASS: debug Java 内容在"
grep -q '@RestController' skills/doc/stacks/JAVA.md && grep -q 'springdoc' skills/doc/stacks/JAVA.md && echo "PASS: doc Java 内容在"
```

- [ ] **Step 3: 通用层无语言痕迹抽查**

```bash
! grep -qE '@Transactional|Mockito|@RestController' skills/flow/CODING-STANDARDS.md skills/test/TEST-STRATEGIES.md skills/debug/DEBUG-METHODS.md skills/doc/DOC-FORMATS.md && echo "PASS: 四个通用层干净"
```

- [ ] **Step 4: 安装测试（HOME 重定向，验证 stacks 随软链可达）**

```bash
TH=$(mktemp -d)
HOME="$TH" ./install.sh >/dev/null 2>&1
test -f "$TH/.claude/skills/flow/stacks/JAVA.md" && echo "PASS: 软链后 stacks/JAVA.md 可达"
test -f "$TH/.claude/skills/doc/stacks/SWIFT.md" && echo "PASS: 软链后 stacks/SWIFT.md 可达"
rm -rf "$TH"
```

- [ ] **Step 5: 修订记录 + 最终提交**

```bash
cat >> docs/design/plans/2026-08-05-java-skills.md <<'EOF'

### 通用化改造（2026-08-19，通用层 + 语言定制包）
- 四个 reference（CODING-STANDARDS/TEST-STRATEGIES/DEBUG-METHODS/DOC-FORMATS+DB-DESIGN）拆「通用层 + stacks/JAVA.md」。
- 新增 Swift/macOS 定制包 ×4。
- PROJECT-CONTEXT 加 language 字段路由；jdk 语义泛化。install.sh/commands 零改动。
EOF
git add -A && git commit -m "test: 通用化端到端验证 + 修订记录" && git push
```

---

## Self-Review

1. **Spec coverage**：§3 结构→T2-T6；§4 拆分表→T2-T5；§5 路由→T1+各 SKILL 路由句；§6 Swift 包→T6；§8 清单→全部 task；§11 验证→各 task 验证步+T8。✅ 无缺口。
2. **Placeholder scan**：无 TBD/TODO；DB-DESIGN 微调给了 grep 指引（明确动作）；README 中性化给了 grep 命令。✅
3. **一致性**：路由句统一为「`./stacks/<language>.md`（language 读自 PROJECT-CONTEXT.md；不存在则只用通用层）」四个 skill 同款。✅
