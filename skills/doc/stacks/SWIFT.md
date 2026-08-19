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
