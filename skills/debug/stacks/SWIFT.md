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
