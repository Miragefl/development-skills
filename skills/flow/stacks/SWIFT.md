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
