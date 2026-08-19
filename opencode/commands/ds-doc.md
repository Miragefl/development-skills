---
description: 自动生成/同步 接口·数据模型·DB脚本 三类文档
---
加载 doc skill（skill({ name: "doc" })），按它的流程处理：读 `PROJECT-CONTEXT.md` 取 `doc_root`/`db`/`orm`；扫描 Controller/Entity/DTO/SQL，在 `<doc_root>/api`、`<doc_root>/data-model`、`<doc_root>/db` 生成/同步文档，遵循 `DOC-FORMATS.md` 与 `DB-DESIGN.md`。

目标：$ARGUMENTS
