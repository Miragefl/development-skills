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
