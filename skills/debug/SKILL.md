---
name: debug
description: Use when fixing bugs, diagnosing exceptions/errors, or investigating performance issues in a Java backend. Systematic spine — reproduce, isolate, hypothesize, verify, fix root cause, regression-check, sync docs. Never guess-edit; reproduce before touching code; fix the cause not the symptom. Reads PROJECT-CONTEXT.md for stack info (test_cmd etc).
---

<what-to-do>

Run this systematic spine for Java debugging:

1. **复现**: 稳定复现 bug，记下确切步骤/输入/环境。**不能复现就先把它弄复现**——别动代码。
2. **隔离**: 二分注释 / 加日志 / 断点，把范围缩到具体模块 → 方法 → 行。
3. **假设**: 根据现象提根因假设（"X 在 Y 条件下为 null"）。
4. **验证**: 最小改动 / 临时日志 / 单测验证假设。错了换假设，别死磕一个。
5. **修复**: 改最少代码修**根因**（治本，别打补丁糊弄症状）。
6. **回归**: 跑 `test_cmd`；想想这改动会不会引新坑（边界 / 并发 / 其他调用方）。
7. **同步**: 动了 Controller/Entity/DTO/SQL，按 doc 更新文档。

排查手法与常见 Java bug 速查见 [DEBUG-METHODS.md](./DEBUG-METHODS.md)。

</what-to-do>

<supporting-info>

## 三条铁律（焊死）

1. **不复现不改动**：复现不了先搞复现，否则改了也不知道好没好。
2. **先定位根因再修**：禁止"我改改试试"撞运气。根因没找到就改 = 制造新 bug。
3. **治本不治标**：找到根因修根因。别在症状上打补丁——补丁会积成技术债。

## 何时用 debug

- **用**：修 bug、排查异常（NPE / 超时 / 数据错乱）、性能问题、行为与预期不符。
- **不用**：正常 feature 开发（走 flow）；大改动先规划（走 plan）。

小 bug 直接 debug；**复杂 / 影响大的 bug** 先 plan 规划排查思路，再 debug 执行。

## 与其他 skill 关系

- 修完 bug 动到接口/实体 → 触发 doc 同步。
- 大 bug 可先 plan 写排查计划（落盘 spec/plan），确认后 debug 执行。

</supporting-info>
