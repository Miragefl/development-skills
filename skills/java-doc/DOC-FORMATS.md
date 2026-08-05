# Java 文档格式规范

供 java-doc 生成三类文档时遵循。固定路径根 = PROJECT-CONTEXT.md 的 `doc_root`（默认 `docs/`）。

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
