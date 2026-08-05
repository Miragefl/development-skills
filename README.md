# Java Development Skills

一套精简的自有 Java 后端开发 Skills，给 Claude Code 与 OpenCode 双工具通用。三个职责单一的 skill + 一个共享元信息底座。

## Skills

| Skill | 干啥 | 触发 |
|---|---|---|
| `java-context` | 守护项目元信息（JDK/构建/DB/ORM…）于 `PROJECT-CONTEXT.md`，绝不重复问 | Java 任务开始时 |
| `java-doc` | 写代码时自动生成/同步 接口/数据模型/DB脚本 三类文档到固定路径 | 写改 Controller/Entity/DTO/SQL 时 |
| `java-flow` | 轻量开发流程主干，替代重型多阶段流程 | Java 功能/bug 开发时 |

## 安装

```bash
git clone https://github.com/Miragefl/java-development-skills java-development-skills
cd java-development-skills

./install.sh                 # 默认装到 ~/.claude/skills/（Claude Code + OpenCode 都能发现）
./install.sh --opencode      # 额外装到 ~/.config/opencode/skills/（双保险）
./install.sh --project /path/to/your-java-app   # 装到指定项目的 .claude/skills/
./install.sh --uninstall     # 卸载
```

> OpenCode 原生扫描 `~/.claude/skills/` 与 `.claude/skills/`，所以默认安装即双工具通用，无需格式转换。

## 使用

1. 在你的 Java 项目根创建 `PROJECT-CONTEXT.md`（`--project` 安装会自动拷模板；否则 `cp PROJECT-CONTEXT.template.md 你的项目/PROJECT-CONTEXT.md`），填好 JDK/构建/DB/ORM。
2. 正常开聊——AI 会按场景自动触发对应 skill。
3. 文档会生成在项目的 `<doc_root>/`（默认 `docs/`）下：`api/`、`data-model/`、`db/`。

## 设计

见 [docs/design/specs/2026-08-05-java-skills-design.md](docs/design/specs/2026-08-05-java-skills-design.md)。

## License

MIT
