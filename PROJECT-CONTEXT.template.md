# Project Context

> 本文件是项目的唯一元信息来源，供 java-context / java-doc / java-flow 读取。
> 拷到项目根目录改填；能从代码确认的字段（build/package）可留空让 AI 扫码补。

- jdk: 17                      # 如 8 / 11 / 17 / 21
- build: maven                 # maven | gradle
- build_cmd: ./mvnw clean package
- run_cmd: ./mvnw spring-boot:run
- test_cmd: ./mvnw test
- db: mysql 8                  # mysql | postgresql | oracle | sqlserver | mariadb | ...
- orm: mybatis-plus            # jpa | mybatis | mybatis-plus
- package: com.example.app
- doc_root: docs/              # 文档统一输出根（api/ data-model/ db/ 在其下）
- modules: []                  # 业务模块列表，如 [user, order, payment]
- notes: ""                    # 其他约定：缓存/MQ/网关/鉴权方式/特殊规范
