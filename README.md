# Java Development Skills

一套精简的**多语言**开发 Skills（通用层 + 语言定制包），给 Claude Code 与 OpenCode 双工具通用。六个职责单一的 skill + 共享元信息底座；内置 **Java** 与 **Swift(macOS)** 定制包，其他语言加一个 `stacks/<LANG>.md` 即可。

## Skills

| Skill | 干啥 | 触发 |
|---|---|---|
| `context` | 守护项目元信息（语言/构建/DB/ORM…）于 `PROJECT-CONTEXT.md`，绝不重复问 | 任务开始时 |
| `doc` | 写代码时自动生成/同步 接口/数据模型/DB脚本 三类文档到固定路径 | 写改接口/模型/存储层代码时 |
| `flow` | 小需求轻量开发流程主干，替代重型多阶段流程 | 小功能开发时 |
| `test` | 写测试 / TDD / 测试策略（单元·集成·边界），flow 写码它写测 | 写测试 / 上 TDD / 提覆盖时 |
| `debug` | 系统化排查修 bug（复现→隔离→假设→验证→治本修复），禁止瞎猜 | 修 bug / 排查异常 / 性能问题时 |
| `plan` | 大需求先写精简 spec+plan 落盘（`docs/specs`、`docs/plans`），再实现 | 跨模块/架构级/大需求规划时 |

## 流程

一个开发任务，skill 这样串起来（每个单一职责，按需触发）：

```
任务来了 → context 读 PROJECT-CONTEXT.md（一次，元信息底座）
│
├─ 大需求 / 架构级 → plan 写 spec+plan →【用户确认】→ flow 实现 → test 测试
├─ 小功能         → flow 实现 → test 测试
├─ 修 bug / 异常  → debug 系统化排查 → test 补回归测试
│
└─ 任意阶段动到 Controller/Entity/DTO/SQL → doc 自动同步文档
```

**协作铁律**：
- `context` 是所有 skill 的元信息底座，开干前先读。
- `plan` 写完 spec+plan **必须停下等用户确认**，确认后才自动转 `flow`。
- `flow` 只写实现 + 跑 `test_cmd` 验证；**写测试交给 `test`**。
- `doc` 在任何 skill 动到接口/实体/SQL 时自动触发，生成 `docs/api`、`docs/data-model`、`docs/db`。

## 安装

```bash
git clone https://github.com/Miragefl/java-development-skills java-development-skills
cd java-development-skills

./install.sh                 # 默认装到 ~/.claude/skills/（Claude Code + OpenCode 都能发现）
./install.sh --opencode      # OpenCode 专用：装 skill 到 ~/.config/opencode/skills/ + command 到 commands/（/d-plan /d-flow 等手动命令）
./install.sh --project /path/to/your-java-app   # 装到指定项目的 .claude/skills/
./install.sh --uninstall     # 卸载
```

> OpenCode 原生扫描 `~/.claude/skills/` 与 `.claude/skills/`，所以默认安装即双工具通用，无需格式转换。

## 使用

1. 在你的项目根创建 `PROJECT-CONTEXT.md`（`--project` 安装会自动拷模板；否则 `cp PROJECT-CONTEXT.template.md 你的项目/PROJECT-CONTEXT.md`），填好 **language（语言，决定加载哪门定制包）**、运行时版本、构建、DB。
2. 正常开聊——AI 会按场景自动触发对应 skill。
3. 文档会生成在项目的 `<doc_root>/`（默认 `docs/`）下：`api/`、`data-model/`、`db/`。
4. **OpenCode 用户**：`./install.sh --opencode` 额外装 `/d-context` `/d-doc` `/d-flow` `/d-test` `/d-debug` `/d-plan` 手动命令（`d-` 前缀避免与 OpenCode 内置命令撞名）。OpenCode 的 skill 只支持 AI 自动触发，**不支持 `/skill-name`**——这 6 个 command 文件就是给你手动 `/d-plan` 的入口（内容引导 AI 加载对应 skill）。

## 设计

见 [docs/design/specs/2026-08-05-java-skills-design.md](docs/design/specs/2026-08-05-java-skills-design.md)。

## License

MIT
