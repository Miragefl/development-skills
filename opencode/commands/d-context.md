---
description: 读/初始化项目元信息 PROJECT-CONTEXT.md（JDK/构建/DB/ORM）
---
加载 context skill（skill({ name: "context" })），按它的流程处理：读项目根 `PROJECT-CONTEXT.md`；不存在则扫码（`pom.xml`/`build.gradle` 判构建工具、`@TableName` 判 ORM、从配置读 JDK 版本）引导我填写，**一次写好绝不重问**。

$ARGUMENTS
