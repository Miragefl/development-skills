# Java 后端测试策略速查

供 java-test 的「定层」「补边界」「重构」参考。按需读。

## 测试分层（测什么层）

| 层 | 测什么 | 怎么测 | 依赖处理 |
|---|---|---|---|
| 单元（Service/逻辑） | 业务逻辑、分支、计算 | 纯 JUnit | mock 掉 Mapper/外部调用 |
| 集成（Controller） | 接口契约、参数校验、异常映射 | @SpringBootTest / MockMvc / @WebMvcTest | mock Service 或用真组件 |
| DAO（Mapper/Repository） | SQL 正确、映射、事务 | @MybatisPlusTest / @DataJpaTest / H2 | 内存库或 Testcontainers |
| 契约（可选） | 对外 API 稳定性 | Spring Cloud Contract / Pact | — |

**不混层**：单元测试别起 Spring 容器（慢且耦合）；集成测试别 mock 掉被测对象本身。

## TDD 三步循环

```
Red       写一个会失败的测试（描述期望行为）
Green     写最少代码让它通过
Refactor  测试全绿下重构
```

- Red 必须因**预期断言失败**，不是编译错或 NPE。
- Green 写最少代码，别提前实现下个需求。
- Refactor 没有测试绿灯就别重构。

## Mock 策略

- **Mock 依赖，不 Mock 被测**：测 Service 就 mock 它的 Mapper/外部调用，Service 本体真实。
- **构造器注入便于 mock**：依赖走构造器（CODING-STANDARDS 要求），测试直接 new + 传 mock。
- **Mockito**：`when(...).thenReturn(...)` / `verify(...)` / `assertThrows(...)`。
- **别 mock 值对象**：DTO/Entity 用真实实例或 Builder 造，别 mock。

## 边界用例清单（每个功能至少想一遍）

- null / 空集合 / 空字符串
- 越界（负数、超大、超长）
- 并发（同一资源多线程）
- 异常路径（依赖抛异常 → 我的处理对吗）
- 权限 / 越权
- 时间 / 时区（LocalDate vs LocalDateTime）
- 幂等（重复调用）

## Java 后端测试速查

| 场景 | 工具 |
|---|---|
| 单元 | JUnit 5 + Mockito |
| Spring 切片 | @WebMvcTest(Controller) / @DataJpaTest / @MybatisPlusTest |
| 全集成 | @SpringBootTest + Testcontainers（MySQL/Redis） |
| Mock HTTP | MockMvc / RestAssured |
| 断言 | AssertJ（流式，比原生 assert 可读） |
| 参数化 | @ParameterizedTest + @CsvSource / @MethodSource |

## 反模式

- ❌ 测私有方法（反射测内部 = 绑死实现）
- ❌ 一个测试断言八件事（挂了不知道哪个）
- ❌ 测试依赖执行顺序
- ❌ mock 被测对象本身
- ❌ 测试里 Thread.sleep / 依赖网络 / 依赖系统时间（脆弱）
- ❌ 为覆盖率写无意义测试
