---
name: plan
description: Use for large development efforts — cross-module, architecture-level, multi-session, or multi-person work. Writes a brief one-page spec to docs/specs/ and a task-checklist plan to docs/plans/ (format in PLAN-SPEC-FORMAT.md), waits for user approval, then auto-invokes flow for implementation. Skip for small tasks — use flow directly.
---

<what-to-do>

For a large Java backend effort, produce a brief spec + plan **before** coding:

1. **读上下文**: 读 `PROJECT-CONTEXT.md`（不存在则先按 context 创建）。
2. **写精简 spec** 到 `docs/specs/<需求名>.md`：目标（一句话）/ 约束 / 模块拆解 / 关键决策 / 风险。格式见 [PLAN-SPEC-FORMAT.md](./PLAN-SPEC-FORMAT.md)。一页纸为限。
3. **写精简 plan** 到 `docs/plans/<需求名>.md`：Task 清单，每条标改哪些文件 + 怎么验证 + `- [ ]`。
4. **停下来等用户确认**：spec+plan 写完后，明确请用户审阅确认，**不要自动往下实现**。用户要改 → 改完再次确认；用户未确认 → 停在规划阶段。
5. **确认后自动转 flow**：用户确认 spec+plan 后，自动衔接 flow 进入实现（套用 CODING-STANDARDS.md，动 Controller/Entity/DTO/SQL 时同步 doc）。

</what-to-do>

<supporting-info>

## 确认 gate（重要）

第 4 步是硬性 gate：**spec+plan 落盘后必须停下等确认**，绝不在用户没点头前开始写代码。这是 plan 与 flow 的交接点——确认即授权实现，不确认就停在规划。

## 何时用 plan（使用者自决）

- **用**：跨模块、架构级、跨会话才能干完、多人协作、复杂业务规则。
- **不用**（直接 flow）：一处改动、一个 bug、单个功能模块、单会话能完。

拿不准就别用——文档随时能补，别为小活儿套重壳。

## 与其他 skill 的关系

- **确认后**的实现交给 `flow`（轻量流程 + CODING-STANDARDS.md）。
- 接口/模型/DB 文档仍由 `doc` 在实现时自动生成。
- plan 只产 `docs/specs/` + `docs/plans/`。

## 原则

- **spec 一页**：超页说明想得不够清或该再拆。
- **plan 是清单**：每个 Task 独立可验证。
- **不写长文**：区别于 superpowers 的几十页文档。

</supporting-info>
