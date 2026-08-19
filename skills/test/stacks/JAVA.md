# Java 测试定制

配合 `../TEST-STRATEGIES.md` 通用层使用（`language: java` 时加载）。

## Java 分层对应

| 层 | 工具 |
|---|---|
| 单元 | JUnit 5 + Mockito（纯 JVM，不起 Spring） |
| Web 切片 | `@WebMvcTest(Controller)` + MockMvc |
| JPA 切片 | `@DataJpaTest` |
| MyBatis-Plus 切片 | `@MybatisPlusTest` |
| 全集成 | `@SpringBootTest` + Testcontainers（MySQL/Redis） |
| 断言 | AssertJ（流式，比原生可读） |
| 参数化 | `@ParameterizedTest` + `@CsvSource` / `@MethodSource` |

## Mockito 速记

- `when(mock.foo(any())).thenReturn(x)` 打桩
- `verify(mock, times(1)).foo(any())` 验证调用
- `assertThrows(BizEx.class, () -> svc.call())` 断言异常

## 契约测试（可选）

对外 API 稳定性：Spring Cloud Contract / Pact。
