---
name: flow
description: Use for feature/bug work when you want a lightweight flow. Minimal spine — understand need, brief design notes only if complex, implement, self-check (compile/test), sync docs via doc. Always read PROJECT-CONTEXT.md first; never re-ask known project facts; code follows CODING-STANDARDS.md. For large efforts, plan first with plan.
---

<what-to-do>

Run this lightweight spine:

1. **读上下文**: 读 `PROJECT-CONTEXT.md`（不存在则先按 context 创建）。绝不重问已知项目事实。
2. **理解需求**: 用一句话复述要做什么；模糊处一次问一个。
3. **设计要点**: 仅当任务复杂才写几条设计要点；简单任务直接做，不套流程。
4. **实现**: 改代码前先读相关现有代码；遵循现有模式；可维护性与设计模式遵循 [CODING-STANDARDS.md](./CODING-STANDARDS.md)（SOLID/模式/可测试性）+ `./stacks/<language>.md` 语言定制层（language 读自 PROJECT-CONTEXT.md；文件不存在则只用通用层）。
5. **自检**: 跑 `test_cmd`（编译/测试），基于结果而非猜测。
6. **同步文档**: 若动了接口/数据模型/存储层代码，按 doc 更新对应文档。

</what-to-do>

<supporting-info>

## 大需求先规划

若需求大（跨模块/架构级/跨会话/多人协作），先用 **plan** 写精简 spec+plan 落盘，再回来实现。小需求直接走上面的流程，不落盘规划。

## 写测试

写测试 / 上 TDD / 补覆盖用 **test**。flow 的「自检」只跑 `test_cmd` 验证，不负责写测试。

## 代码质量（硬性要求）

「实现」阶段产出的代码必须遵循 [CODING-STANDARDS.md](./CODING-STANDARDS.md)：可维护性总则 / SOLID / 后端分层 / GoF 模式 / 测试友好。这是质量底线，不是建议。

## 流程边界

不做 superpowers 那套：多轮方案对比、spec 自检 gate、强制复核 gate、独立的 writing-plans 阶段、分模块逐段确认。简单任务直接做。

</supporting-info>
