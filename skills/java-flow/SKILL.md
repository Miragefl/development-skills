---
name: java-flow
description: Use for Java backend feature/bug work when you want a lightweight flow instead of heavy multi-stage processes. Minimal spine — understand need, brief design only if complex, implement, self-check (compile/test), sync docs via java-doc. Always read PROJECT-CONTEXT.md first; never re-ask known project facts.
---

<what-to-do>

Run this lightweight spine for Java backend work:

1. **读上下文**: 读 `PROJECT-CONTEXT.md`（不存在则先按 java-context 创建）。绝不重问已知项目事实。
2. **理解需求**: 用一句话复述要做什么；模糊处一次问一个。
3. **设计要点**: 仅当任务复杂才写几条设计要点；简单任务直接做，不套流程。
4. **实现**: 改代码前先读相关现有代码；遵循现有模式。
5. **自检**: 跑 `test_cmd`（编译/测试），基于结果而非猜测。
6. **同步文档**: 若动了 Controller/Entity/DTO/SQL，按 java-doc 更新对应文档。

</what-to-do>

<supporting-info>

不做这些（对比重型流程）：多轮方案对比、spec 自检 gate、用户复核 gate、独立的 writing-plans 阶段、强制分模块逐段确认。

简单任务（一处小改、一个 bug）跳过设计要点，直接实现→自检。复杂任务才补设计要点。

</supporting-info>
