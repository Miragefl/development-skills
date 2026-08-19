# 文档格式规范·通用层

供 doc 生成三类文档时遵循，语言无关。语言触发点/类型映射见 `stacks/<language>.md`。固定路径根 = PROJECT-CONTEXT.md 的 `doc_root`（默认 `docs/`）。

## 1. 接口文档 `<doc_root>/api/<模块>.md`

按业务模块聚合（对外提供 HTTP 接口的场景；app 类项目见 stacks 适配）。每个接口一段：

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

有标准契约来源（OpenAPI/接口定义）时优先以其为准生成，并在文件头注明来源。

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
