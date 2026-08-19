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
