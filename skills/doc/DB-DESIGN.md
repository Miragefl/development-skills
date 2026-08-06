# 数据库建表设计规范

供 doc 生成 DDL 时遵循、plan 设计数据模型时参考。目标：建出的表好查、好扩展、不埋坑。

## 主键策略

- **默认**：`bigint` 自增（简单、有序、索引友好）。无特殊理由别用别的。
- **分布式 / 分表**：雪花 ID（`bigint` 存）。UUID 仅当必须跨系统去重且不依赖索引顺序时用（占空间、索引差）。
- **业务主键 vs 代理主键**：表一律用**代理主键**（自增 id），业务唯一约束走**唯一索引**（`uk_xxx`）。别拿业务字段当主键。

## 字段规范

- **命名**：snake_case。表名 `t_<业务>_<实体>`（如 `t_order_item`）；字段 `<属性>`（如 `user_id`、`created_at`）。
- **类型**：
  - 金额：`decimal(p,s)`，**别用 float/double**。
  - 字符串：`varchar(n)` 给合理上限；不确定用 `varchar(255)`，别滥用 `text`。
  - 时间：`datetime`（MySQL）/ `timestamp`（PG）。统一存 UTC 或明确时区。
  - 布尔：`tinyint(1)`（MySQL）/ `boolean`（PG）。
- **必备字段**（每张表）：`id`（主键）、`created_at`、`updated_at`、`deleted_at`（软删）或 `is_deleted`。
- **not null**：能 not null 就 not null，默认值能填就填。null 是 bug 之源。

## 索引原则

- **加索引的列**：where 条件、order by、join 的列。
- **联合索引**：按**区分度**从高到低排；遵循**最左前缀**（建 (a,b,c) 能命中 a / a,b / a,b,c，但不能命中 b,c）。
- **避免**：区分度低的列单建索引（如 status 只有 0/1）；冗余索引（建了 a,b,c 又单独建 a,b）。
- **唯一约束**用唯一索引（`uk_xxx`），既约束又加速。

## 范式 vs 反范式

- **默认三范式**：消除冗余，保证一致性（改一处不改十处）。
- **为查询性能反范式**：高频联表查询、且冗余字段低频变动时，可冗余（如订单里存 `user_name` 快照）。**反范式要记 ADR**（为啥这么干，防后人误以为是漏了）。

## 命名规范速查

| 对象 | 规范 | 示例 |
|---|---|---|
| 表 | `t_<模块>_<实体>` | `t_order_item` |
| 字段 | `snake_case` | `user_id` |
| 主键索引 | `pk_xxx` / 默认 PRIMARY | `pk_id` |
| 唯一索引 | `uk_<实体>_<字段>` | `uk_user_phone` |
| 普通索引 | `idx_<实体>_<字段>` | `idx_order_user_id` |

## 分表 / 分库（YAGNI 警告）

- **别提前分**。单表千万级、查询开始慢时再考虑。
- 分表键要选好（按 `user_id` / 时间），跨分片查询要尽量避开。
- 这类决策必须走 plan + ADR（影响大、难回退）。

## 迁移策略

- DDL 变更走 `docs/db/migrations/V<日期>_<简述>.sql`（对应 doc 生成的迁移目录）。
- 生产用 Flyway / Liquibase 管迁移顺序，别手改库。
- **危险变更先备份**：drop / rename / 改类型 / 加 not null。

## 反模式

- ❌ 拿业务字段当主键
- ❌ float / double 存金额
- ❌ 到处 null、没默认值
- ❌ 滥用 text、bigint 无上限
- ❌ 不加索引（慢查询）或乱加索引（写放大）
- ❌ 提前分表（YAGNI）
