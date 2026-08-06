---
name: doc
description: Use whenever writing or modifying Java Controllers, DTOs/Entities, or SQL/DDL in a Spring backend. Auto-generates and keeps in sync three doc types at fixed paths under doc_root — REST docs in api/, data-model docs in data-model/, DB scripts in db/. Adapts to Maven/Gradle and the project DB dialect. Reads PROJECT-CONTEXT.md for the stack.
---

<what-to-do>

When the user writes or modifies any of these, offer (and on approval, write) the matching doc:

- `@RestController` / `@Controller` / `@*Mapping` → `api/<模块>.md`
- `@Entity` / `@TableName` / DTO / VO → `data-model/<实体名>.md`
- 建表/改表 SQL or Entity 字段变更 → `db/schema.sql` (+ `db/migrations/V*.sql`)

Read `PROJECT-CONTEXT.md` first for `doc_root`, `db` (方言), `orm`, `package`, `modules`. Generate docs under `<doc_root>/api`, `<doc_root>/data-model`, `<doc_root>/db`.

Follow the formats in [DOC-FORMATS.md](./DOC-FORMATS.md). 生成/改 DDL（`db/schema.sql`、migrations）时遵循建表设计规范 [DB-DESIGN.md](./DB-DESIGN.md)（主键 / 字段 / 索引 / 命名 / 范式）。

</what-to-do>

<supporting-info>

## 多栈适配

- **构建**: `pom.xml` → Maven (`./mvnw`); `build.gradle` → Gradle (`./gradlew`).
- **DB 方言**: 按 `db` 字段生成对应 DDL（类型、自增/序列差异）。
- **ORM**: `@Entity` → JPA 解析; `@TableName` → MyBatis-Plus 解析.
- **OpenAPI**: 若依赖含 `springdoc-openapi`，优先读 `/v3/api-docs` JSON 生成接口文档。

## 懒加载

有内容才建文件，不空建目录。生成前用一句话说明意图；不擅自删除已有文档，只追加/更新对应段落。

</supporting-info>
