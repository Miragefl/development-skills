---
name: java-flow
description: Use for Java backend feature/bug work when you want a lightweight flow. Minimal spine — understand need, brief design notes only if complex, implement, self-check (compile/test), sync docs via java-doc. Always read PROJECT-CONTEXT.md first; never re-ask known project facts; code follows CODING-STANDARDS.md. For large efforts, plan first with java-plan.
---

<what-to-do>

Run this lightweight spine for Java backend work:

1. **读上下文**: 读 `PROJECT-CONTEXT.md`（不存在则先按 java-context 创建）。绝不重问已知项目事实。
2. **理解需求**: 用一句话复述要做什么；模糊处一次问一个。
3. **设计要点**: 仅当任务复杂才写几条设计要点；简单任务直接做，不套流程。
4. **实现**: 改代码前先读相关现有代码；遵循现有模式；可维护性与设计模式遵循 [CODING-STANDARDS.md](./CODING-STANDARDS.md)（SOLID/分层/模式/可测试性）。
5. **自检**: 跑 `test_cmd`（编译/测试），基于结果而非猜测。
6. **同步文档**: 若动了 Controller/Entity/DTO/SQL，按 java-doc 更新对应文档。

</what-to-do>

<supporting-info>

## 大需求先规划

若需求大（跨模块/架构级/跨会话/多人协作），先用 **java-plan** 写精简 spec+plan 落盘，再回来实现。小需求直接走上面的流程，不落盘规划。

## 代码质量（硬性要求）

「实现」阶段产出的代码必须遵循 [CODING-STANDARDS.md](./CODING-STANDARDS.md)：可维护性总则 / SOLID / 后端分层 / GoF 模式 / 测试友好。这是质量底线，不是建议。

## 流程边界

不做 superpowers 那套：多轮方案对比、spec 自检 gate、强制复核 gate、独立的 writing-plans 阶段、分模块逐段确认。简单任务直接做。

</supporting-info>
