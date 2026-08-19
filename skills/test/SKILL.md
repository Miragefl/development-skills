---
name: test
description: Use when writing tests, applying TDD, or deciding test strategy (unit/integration/boundary). Pairs with flow — flow writes code, this writes tests. Spine — pick test layer, write failing test first (TDD), run to fail, implement to pass, cover boundary/error cases, regression, refactor under green. Reads PROJECT-CONTEXT.md for test_cmd and language (stacks/<lang>.md has language-specific tooling).
---

<what-to-do>

Run this spine for testing:

1. **定层**: 决定测什么层——单元（逻辑层，纯 mock 依赖）/ 集成（边界）/ 存储（打真库或内存库，具体工具见 stacks/<language>.md）。不混层。
2. **先写失败测试（TDD）**: 针对行为写一个**会失败**的测试（Red）。测行为/契约，不是实现细节。
3. **跑出失败**: 跑 `test_cmd` 确认测试**因预期原因失败**（不是编译错/报错）。
4. **实现到通过**: 写最少代码让测试通过（Green），不超需求。
5. **补边界**: 加边界用例——null/空/越界/并发/异常路径/权限/时间。
6. **回归**: 全量 `test_cmd` 通过；想想会不会破其他测试。
7. **重构**: 测试全绿下才重构实现（测试是安全网）。

测试分层、TDD、Mock 策略见 [TEST-STRATEGIES.md](./TEST-STRATEGIES.md)（通用层）；语言工具速查见 `./stacks/<language>.md`（language 读自 PROJECT-CONTEXT.md；不存在则只用通用层）。

</what-to-do>

<supporting-info>

## 与 flow 的分工

- **flow**：写**实现代码**；它的「自检」只是跑 `test_cmd` 验证。
- **test**：写**测试代码**、定测试策略、套 TDD、补覆盖。
- 协作：flow 实现功能 → test 补测试；严格 TDD 时 test 先写失败测试 → flow 实现。

## 何时用 test

- **用**：写单元/集成测试、上 TDD、提升覆盖率、补边界用例、给 bug 写回归测试（配合 debug）。
- **不用**：只跑现有测试（那是 flow 的自检步）。

## 三条原则

1. **测行为不测实现**：测公开契约/输出，不测私有方法/内部状态（否则一重构就崩）。
2. **一个测试一件事**：失败时一眼知道哪挂了。
3. **测试是安全网不是负担**：全绿才敢重构；测试本身要简单稳定，别写脆弱测试（依赖时间/顺序/网络）。

</supporting-info>
