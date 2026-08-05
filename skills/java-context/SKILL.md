---
name: java-context
description: Use at the start of any Java backend task, or when project setup (JDK, build tool, database, ORM, package) info is needed. Reads PROJECT-CONTEXT.md from the repo root; if missing, creates it once from the template by scanning the code. Ensures project facts are never asked twice.
---

<what-to-do>

Before any Java backend work, read `PROJECT-CONTEXT.md` at the repo root.

If it does not exist:
1. Scan the code to fill what you can — `pom.xml` → `build: maven`, `build.gradle` → `build: gradle`; `@Entity` → `orm: jpa`, `@TableName` → `orm: mybatis-plus`; detect JDK from `pom.xml` `<maven.compiler.release>` or `build.gradle` `sourceCompatibility`; detect package from the top-level `package` statement.
2. Create `PROJECT-CONTEXT.md` from the template (`PROJECT-CONTEXT.template.md`) with those values filled; leave the rest as guided prompts.
3. Ask the user only for what code cannot reveal (e.g. `db` type/version, `notes`), one question at a time.

On every task, reuse this file. Never re-ask JDK / build tool / database / ORM / package — read it here.

</what-to-do>

<supporting-info>

If `PROJECT-CONTEXT.md` contradicts the code (e.g. says `gradle` but `pom.xml` exists), point it out and fix the file. Keep entries as a flat bullet list of `- key: value`. Fields: jdk, build, build_cmd, run_cmd, test_cmd, db, orm, package, doc_root, modules, notes.

</supporting-info>
