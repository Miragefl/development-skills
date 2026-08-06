---
name: java-plan
description: Use for large Java backend efforts — cross-module, architecture-level, multi-session, or multi-person work. Writes a brief one-page spec to docs/specs/ and a task-checklist plan to docs/plans/ (format in PLAN-SPEC-FORMAT.md) before implementation. Pair with java-flow for the actual coding. Skip for small tasks — use java-flow directly.
---

<what-to-do>

For a large Java backend effort, produce a brief spec + plan **before** coding:

1. **读上下文**: 读 `PROJECT-CONTEXT.md`（不存在则先按 java-context 创建）。
2. **写精简 spec** 到 `docs/specs/<需求名>.md`：目标（一句话）/ 约束 / 模块拆解 / 关键决策 / 风险。格式见 [PLAN-SPEC-FORMAT.md](./PLAN-SPEC-FORMAT.md)。一页纸为限。
3. **写精简 plan** 到 `docs/plans/<需求名>.md`：Task 清单，每条标改哪些文件 + 怎么验证 + `- [ ]`。
4. **使用者认可后**，交由 java-flow 实现（或继续在此会话推进）。

</what-to-do>

<supporting-info>

## 何时用 java-plan（使用者自决）

- **用**：跨模块、架构级、跨会话才能干完、多人协作、复杂业务规则。
- **不用**（直接 java-flow）：一处改动、一个 bug、单个功能模块、单会话能完。

拿不准就别用——文档随时能补，别为小活儿套重壳。

## 与其他 skill 的关系

- 规划完的**实现**交给 `java-flow`（轻量流程 + 套用 CODING-STANDARDS.md）。
- 接口/模型/DB 文档仍由 `java-doc` 在实现时自动生成——java-plan 不产那些。
- java-plan 只产 `docs/specs/` + `docs/plans/`。

## 原则

- **spec 一页**：超页说明想得不够清或该再拆。
- **plan 是清单**：每个 Task 独立可验证。
- **不写长文**：区别于 superpowers 的几十页文档。

</supporting-info>
