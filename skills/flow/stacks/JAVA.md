# Java/Spring 编码定制

配合 `../CODING-STANDARDS.md` 通用层使用（PROJECT-CONTEXT.md 的 `language: java` 时加载）。

## 后端分层实战

- **三层职责**：
  - `Controller`：接收参数、校验、编排调用、返回 VO。**不写业务逻辑**。
  - `Service`：业务逻辑、事务边界。**不直接拼 SQL 细节**（用 Repository/Mapper）。
  - `Repository/Mapper`：数据访问。**不掺业务判断**。
- **对象分层**：`DTO`(入参) · `VO`(出参) · `Entity`(表映射) · `Param`(内部传递)。**别拿 Entity 直接返给前端**。
- **构造器注入**：用 `@RequiredArgsConstructor` + `final` 字段，别用字段注入（`@Autowired` 写在字段上）。
- **统一异常**：`@RestControllerAdvice` + 自定义业务异常，Controller 不写 try-catch 堆。
- **事务边界**：`@Transactional` 标在 Service 方法，别标 Controller；只读查询用 `@Transactional(readOnly=true)`。

## Java 特有落地

- **建造者**：Lombok `@Builder`（构造参数 ≥4 时）。
- **观察者/事件**：Spring `ApplicationEvent`。
- **依赖倒置日常形态**：`@Autowired` 注入接口实现即 DIP。
