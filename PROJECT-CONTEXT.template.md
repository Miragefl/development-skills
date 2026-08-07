# 项目元信息（PROJECT-CONTEXT）

> 本文件是项目的唯一元信息来源，供 context / doc / flow / test / debug / plan 读取。
> 拷到项目根目录改填；能从代码确认的字段（build/package 等）可留空让 AI 扫码补。
> 字段名（jdk/build/db 等）保持英文——它们是 skill 机器解析的 key；**注释和说明一律用中文写**。

- jdk: 17                           # JDK 版本，如 8 / 11 / 17 / 21
- build: maven                      # 构建工具：maven | gradle
- build_cmd: ./mvnw clean package   # 打包构建命令
- run_cmd: ./mvnw spring-boot:run   # 本地运行命令
- test_cmd: ./mvnw test             # 测试命令
- db: mysql 8                       # 数据库类型与版本：mysql | postgresql | oracle | sqlserver | mariadb | ...
- orm: mybatis-plus                 # ORM 框架：jpa | mybatis | mybatis-plus
- package: com.example.app          # 顶层包名
- doc_root: docs/                   # 文档统一输出根目录（api/ data-model/ db/ 在其下）
- modules: []                       # 业务模块列表，如 [user, order, payment]
- notes: ""                         # 其他约定（用中文描述）：缓存 / 消息队列 / 网关 / 鉴权方式 / 特殊规范
