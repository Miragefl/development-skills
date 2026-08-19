# 项目元信息（PROJECT-CONTEXT）

> 本文件是项目的唯一元信息来源，供 context / doc / flow / test / debug / plan 读取。
> 拷到项目根目录改填；能从代码确认的字段（build/package 等）可留空让 AI 扫码补。
> 字段名（jdk/build/db 等）保持英文——它们是 skill 机器解析的 key；**注释和说明一律用中文写**。`language` 是语言定制层（skills/*/stacks/<语言>.md）的路由 key。

- language: java                    # 主开发语言：java | swift | go | node（skill 按它加载 skills/*/stacks/<语言>.md 定制层）
- jdk: 17                           # 主语言运行时版本：Java 填 JDK 版本 / Swift 填 Swift 版本 / Go 填 Go 版本
- build: maven                      # 构建工具：Java 用 maven | gradle；Swift 用 xcodebuild/spm；Go 用 go；Node 用 npm/pnpm
- build_cmd: ./mvnw clean package   # 打包构建命令
- run_cmd: ./mvnw spring-boot:run   # 本地运行命令
- test_cmd: ./mvnw test             # 测试命令
- db: mysql 8                       # 数据库类型与版本：mysql | postgresql | oracle | sqlserver | mariadb | ...
- orm: mybatis-plus                 # ORM 框架：jpa | mybatis | mybatis-plus
- package: com.example.app          # 顶层包名
- doc_root: docs/                   # 文档统一输出根目录（api/ data-model/ db/ 在其下）
- modules: []                       # 业务模块列表，如 [user, order, payment]
- notes: ""                         # 其他约定（用中文描述）：缓存 / 消息队列 / 网关 / 鉴权方式 / 特殊规范
