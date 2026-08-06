---
description: 系统化排查修 bug（复现→隔离→假设→验证→治本）
---
加载 debug skill（skill({ name: "debug" })），按它的系统化流程排查：复现 → 隔离（二分/日志/断点）→ 假设根因 → 验证 → 改最少代码修**根因** → 回归。三铁律：不复现不改动、先定位根因再修、治本不治标。遵循 `DEBUG-METHODS.md`。

问题：$ARGUMENTS
