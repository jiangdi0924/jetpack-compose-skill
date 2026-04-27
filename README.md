<p align="center">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/jetpackcompose/jetpackcompose-original.svg" width="80" alt="Jetpack Compose logo"/>
</p>

<h1 align="center">Compose Agent Skill</h1>

<p align="center">
  让你的 AI 编程工具真正理解 Compose —— 覆盖 Android、桌面、iOS 和 Web。<br/>
  基于 <code>androidx/androidx</code> 和 <code>compose-multiplatform-core</code> 的真实源码 —— 不靠瞎猜。
</p>

<p align="center">
  <a href="#安装"><img src="https://img.shields.io/badge/setup-5%20min-brightgreen" alt="Setup time"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License"/></a>
  <a href="https://developer.android.com/jetpack/compose"><img src="https://img.shields.io/badge/Jetpack%20Compose-1.7+-4285F4" alt="Compose version"/></a>
  <a href="https://www.jetbrains.com/lp/compose-multiplatform/"><img src="https://img.shields.io/badge/Compose%20Multiplatform-1.8+-7F52FF" alt="CMP version"/></a>
  <a href="https://kotlinlang.org"><img src="https://img.shields.io/badge/Kotlin-2.0+-7F52FF" alt="Kotlin version"/></a>
</p>

---

## 安装

本 Skill 以插件（Plugin）形式分发。详细安装说明见 **[docs/INSTALL.md](docs/INSTALL.md)**：

- **Claude Code:** `/plugin marketplace add aldefy/compose-skill` → `/plugin install compose-expert`
- **Copilot CLI:** `copilot plugin install aldefy/compose-skill`
- **Codex CLI:** 需手动安装 —— 见 INSTALL.md。

之前手动安装过？请参考 **[docs/MIGRATION.md](docs/MIGRATION.md)** 进行迁移。

## 更新

新版本会发布在 [GitHub Releases](https://github.com/aldefy/compose-skill/releases) 并附带迁移说明。运行 `/plugin update`（Claude Code）或 `copilot plugin update aldefy/compose-skill`（Copilot）即可获取更新。

---

## 解决的问题

AI 编程工具生成的 Compose 代码能编译，但常常在细节上出错：错误使用 `remember`、不稳定的重组、Modifier 顺序错乱、过时的导航写法、凭空捏造的 API。它们靠猜测，而不是了解真实行为。

本 Skill 通过两件事来解决这个问题：

1. **20 份参考指南** 涵盖所有主要 Compose 主题 —— 包括 Compose Multiplatform、Android TV、Material 3 动效、原子化设计系统、设计稿到代码的工作流、动画配方、生产环境崩溃模式
2. **6 份源码文件** 直接来自 [`androidx/androidx`](https://github.com/androidx/androidx/tree/androidx-main/compose) 和 [`compose-multiplatform-core`](https://github.com/JetBrains/compose-multiplatform-core)，让 Agent 可以核对真实实现

## 安装后的差异

| 领域 | 不装 Skill | 装了 Skill |
|---|---|---|
| 状态 | 处处 `remember { mutableStateOf() }`，即便 `derivedStateOf` 或 `rememberSaveable` 才是正解 | 为每种场景挑选合适的状态原语 |
| 性能 | 生成每帧都重组的代码 | 应用稳定性注解、延迟读取、列表 `key {}` |
| 导航 | 字符串路由（已弃用） | 基于 `@Serializable` 路由类的类型安全路由 |
| Modifier | 顺序随意，会漏掉「`clickable` 必须在 `padding` 之前」这类 Bug | 给出正确顺序并附带原因 |
| 副作用 | 协程作用域用错、`LaunchedEffect` key 选错 | 正确选择副作用 API 并使用生命周期感知的 key |
| API | 杜撰不存在的参数 | 推荐前先核对真实源码 |
| 多平台 | 在公共代码里用了仅 Android 才有的 API | 使用 `expect`/`actual`、`Res.*` 资源以及平台正确的写法 |
| 设计稿到代码 | 直译 Figma 节点、Modifier 顺序错乱 | 使用语义化 M3 组件、正确顺序、主题 token |
| 崩溃防御 | 无防御性写法 | 防范零尺寸 DrawScope、重复 key、过期的 `derivedStateOf` |

## 覆盖范围

| 主题 | Agent 能学到什么 |
|---|---|
| 状态管理 | `remember`、`mutableStateOf`、`derivedStateOf`、`rememberSaveable`、状态提升、`snapshotFlow` |
| 视图组合 | 组合函数的结构、Slot API、`@Preview` 用法、提取规则 |
| 性能 | 重组跳过、`@Stable`/`@Immutable`、延迟读取、Baseline Profile、基准测试 |
| 导航 | 类型安全路由、`NavHost`、深链接、共享元素过渡、回退栈 |
| 动画 | `animate*AsState`、`AnimatedVisibility`、`Crossfade`、`updateTransition`、共享过渡，9 个动画配方（闪光、滑动删除等）、手势驱动模式、Figma 曲线映射 |
| 列表与滚动 | `LazyColumn`/`LazyRow`/`LazyGrid`、`Pager`、`key {}`、`contentType`、滚动状态 |
| 副作用 | `LaunchedEffect`、`DisposableEffect`、`SideEffect`、`rememberCoroutineScope` |
| Modifier | 顺序规则、自定义 Modifier、`Modifier.Node` 迁移 |
| 主题 | `MaterialTheme`、`ColorScheme`、动态色彩、`Typography`、Shapes、深色主题 |
| 无障碍 | Semantics、内容描述、遍历顺序、触摸目标、TalkBack |
| CompositionLocal | `LocalContext`、`LocalDensity`、自定义 Local，何时用 vs 直接传参 |
| 已弃用模式 | 已移除的 API、旧版 Compose 的迁移路径 |
| **Styles API（实验）** | `Style {}`、`MutableStyleState`、`Modifier.styleable()`、组合、主题集成、alpha06 的注意点 |
| **设计稿到代码** | 组合函数拆解算法、Figma 属性映射、间距归属、Modifier 顺序、Design Token |
| **生产崩溃手册** | 6 种崩溃模式的根因 + 修复、防御性写法、生产环境的状态/性能规则 |
| **Compose Multiplatform** | CMP 架构、`expect`/`actual`、`Res.*` 资源、API 可用性矩阵、迁移指南 |
| **平台相关** | 桌面（Window、Tray、MenuBar）、iOS（UIKitView 与坑点）、Web/WASM（Canvas 限制） |
| **TV Compose** | TV Material3（Surface、Cards、Carousel、NavigationDrawer、TabRow）、焦点系统、D-pad 导航、主题、沉浸式列表、TVProvider |
| **M3 Motion** | 全部时长 token（`DurationShort1–4`、`DurationMedium1–4`、`DurationLong1–4`、`DurationExtraLong1–4`）、带 CubicBezierEasing 数值的缓动 token、`MotionScheme` API（`defaultSpatialSpec`、`defaultEffectsSpec`）、Compose API 映射、决策树、PR 评审检查项 |
| **原子化设计** | 五层结构（token、原子、分子、有机体、模板）映射到 Compose、M3 包装模式、自定义原子模式、Slot API 契约、Token 层、反模式 |
| 源代码 | `androidx/androidx` 与 `compose-multiplatform-core` 的真实 `.kt` 源码，覆盖 runtime、UI、foundation、material3、navigation、CMP |

## 工作原理

```
你提了一个 Compose 问题
        |
        v
  AI 读取 SKILL.md（工作流 + 检查清单）
        |
        v
  根据问题查阅对应参考文件
        |
        +-- state-management.md
        +-- performance.md
        +-- navigation.md
        +-- design-to-compose.md
        +-- production-crash-playbook.md
        +-- multiplatform.md
        +-- platform-specifics.md
        +-- tv-compose.md
        +-- ...（共 20 份指南）
        |
        +-- source-code/
              +-- runtime-source.md
              +-- material3-source.md
              +-- cmp-source.md
              +-- ...（共 6 份源码）
```

**第一层：指南文档**（19 份）—— 实用参考，附带模式、坑点、do/don't 示例。Agent 首先读这些。

**第二层：源码凭据**（6 份）—— 来自 `androidx/androidx` 与 `compose-multiplatform-core` 的真实 Kotlin 源码。当 Agent 需要核对实现细节而不是猜测时，会读这些。

## 文件结构

```
skills/compose-expert/
├── SKILL.md                              # 主工作流 + 检查清单
└── references/
    ├── state-management.md               # 状态、remember、提升、derivedStateOf
    ├── view-composition.md               # 组合函数结构、Slot、Preview
    ├── modifiers.md                      # Modifier 顺序、自定义、Modifier.Node
    ├── side-effects.md                   # LaunchedEffect、DisposableEffect、SideEffect
    ├── composition-locals.md             # CompositionLocal、LocalContext、自定义 Local
    ├── lists-scrolling.md                # LazyColumn/Row/Grid、Pager、key、contentType
    ├── navigation.md                     # NavHost、类型安全路由、深链接
    ├── animation.md                      # animate*AsState、AnimatedVisibility、过渡
    ├── theming-material3.md              # MaterialTheme、ColorScheme、动态色彩
    ├── performance.md                    # 重组、稳定性、基准测试
    ├── accessibility.md                  # Semantics、内容描述、测试
    ├── deprecated-patterns.md            # 移除的 API、迁移路径
    ├── styles-experimental.md           # Styles API（@ExperimentalFoundationStyleApi）
    ├── design-to-compose.md             # Figma/截图拆解、属性映射
    ├── production-crash-playbook.md     # 崩溃模式、防御性写法、生产规则
    ├── multiplatform.md                 # CMP 架构、expect/actual、Res.*、迁移
    ├── platform-specifics.md            # 桌面、iOS、Web/WASM 平台 API 与坑点
    ├── tv-compose.md                    # Android TV：tv-material、Carousel、焦点、D-pad
    ├── atomic-design.md                 # 原子化设计系统：token、原子、分子、有机体、模板
    └── source-code/                      # 真实 .kt 源码
        ├── runtime-source.md             # Composer、Recomposer、State、Effects
        ├── ui-source.md                  # AndroidCompositionLocals、Modifier、Layout
        ├── foundation-source.md          # LazyList、BasicTextField、Gestures
        ├── material3-source.md           # MaterialTheme、所有 M3 组件
        ├── navigation-source.md          # NavHost、ComposeNavigator
        └── cmp-source.md                # Window、UIKitView、ComposeViewport、Resources
```

## 接入方式

本 Skill 就是一组 Markdown 文件，下面任何工具读到的都是同一份内容，按你用的工具选一种即可。

---

### Claude Code

Skill 是文件驱动的 —— Claude Code 会自动从 `~/.claude/skills/`（个人）或 `.claude/skills/`（项目）发现它们。

**个人 Skill（在所有项目中可用）：**
> 克隆仓库并把 Skill 复制到个人 Skill 目录：

```bash
git clone https://github.com/aldefy/compose-skill.git /tmp/compose-skill
mkdir -p ~/.claude/skills
cp -r /tmp/compose-skill/skills/compose-expert ~/.claude/skills/
```

**项目 Skill（仅当前项目）：**

> 克隆仓库并把 Skill 复制到项目的 `.claude/skills` 目录：

```bash
git clone https://github.com/aldefy/compose-skill.git /tmp/compose-skill
mkdir -p .claude/skills
cp -r /tmp/compose-skill/skills/compose-expert .claude/skills/
```

不需要任何 CLI 命令或配置文件。Claude Code 会自动从这些目录读取 `SKILL.md`，并在你提到 Compose、`@Composable`、`remember`、`LazyColumn`、`NavHost` 等关键词时触发。

---

### Codex CLI（OpenAI）

在项目根目录新增一个 `AGENTS.md` 文件：

```markdown
# AGENTS.md

## Jetpack Compose
For all Compose/Android UI tasks, follow the instructions in
`skills/compose-expert/SKILL.md` and consult the reference
files in `skills/compose-expert/references/` before answering.
```

把 Skill 作为子模块添加到项目：

```bash
git submodule add https://github.com/aldefy/compose-skill.git .compose-skill
```

Codex 会自动从 git 根目录到当前目录沿路径发现 `AGENTS.md`。

---

### Gemini CLI（Google）

在项目根目录的 `GEMINI.md` 中加入：

```markdown
# GEMINI.md

## Jetpack Compose Expert
For all Jetpack Compose tasks, follow the workflow and checklists in
`skills/compose-expert/SKILL.md`.

Before answering any Compose question, consult the relevant reference:
- State management -> `skills/compose-expert/references/state-management.md`
- Performance -> `skills/compose-expert/references/performance.md`
- Navigation -> `skills/compose-expert/references/navigation.md`
- (see SKILL.md for the full topic -> file mapping)

For implementation details, check actual source code in
`skills/compose-expert/references/source-code/`.
```

作为子模块添加：

```bash
git submodule add git@github.com:aldefy/compose-skill.git .compose-skill
```

---

### Google Antigravity

Antigravity 会自动从工作区或全局 Skill 目录发现 Skill。`skills/compose-expert` 已经包含了带 YAML frontmatter description 的 `SKILL.md`，本身就是一个完整可用的 Antigravity Skill。

**工作区 Skill（仅当前项目）：**

```bash
# 克隆仓库
git clone https://github.com/aldefy/compose-skill.git /tmp/compose-skill

# 复制到项目的 .agents/skills 目录
mkdir -p .agents/skills
cp -r /tmp/compose-skill/skills/compose-expert .agents/skills/compose-expert
```

**全局 Skill（在所有项目中可用）：**

```bash
# 克隆仓库
git clone https://github.com/aldefy/compose-skill.git /tmp/compose-skill

# 复制到全局 Antigravity Skill 目录
mkdir -p ~/.gemini/antigravity/skills
cp -r /tmp/compose-skill/skills/compose-expert ~/.gemini/antigravity/skills/compose-expert
```

---

### Cursor

新建 `.cursor/rules/compose-skill.mdc`：

```markdown
---
description: Jetpack Compose expert guidance
globs: **/*.kt
---

Follow the instructions in `skills/compose-expert/SKILL.md`
for all Compose-related code. Consult reference files in
`skills/compose-expert/references/` before suggesting patterns.
```

或者把 `SKILL.md` 内容直接粘到 **Settings > Rules for AI**。

---

### GitHub Copilot

在 `.github/copilot-instructions.md` 中加入：

```markdown
## Jetpack Compose
For Compose/Android UI work, follow the skill instructions in
`skills/compose-expert/SKILL.md`. Consult reference files in
`skills/compose-expert/references/` for patterns, pitfalls,
and source-code-backed guidance.
```

---

### Windsurf

在项目根目录新建 `.windsurf/rules/compose-skill.md`：

```markdown
For all Jetpack Compose tasks, follow the workflow in
`skills/compose-expert/SKILL.md` and consult the reference
files in `skills/compose-expert/references/` before answering.
```

> **说明：** 旧的 `.windsurfrules` 文件仍然可用，但当前推荐 `.windsurf/rules/`。

---

### Amazon Q Developer

在 `.amazonq/rules/compose.md` 中加入：

```markdown
For all Jetpack Compose tasks, follow the workflow in
`skills/compose-expert/SKILL.md` and consult the reference
files in `skills/compose-expert/references/` before answering.
```

---

### 其它任意 AI 编程工具

它就是一组 Markdown，把仓库克隆到项目（或作为子模块），然后让你的工具读 `skills/compose-expert/SKILL.md` 即可。Agent 会先读 `SKILL.md` 的工作流，再按需读 `references/` 下的内容。

## 快速示例

接入完成后，正常和 AI 对话即可：

```
"My LazyColumn is janky when scrolling — help me fix it"
```

发生的事情：
1. Agent 读取 `SKILL.md` 中的工作流
2. 拉取 `references/lists-scrolling.md` 和 `references/performance.md`
3. 检查代码里有没有缺 `key {}`、Item 类型不稳定、Item 块里塞了重组合的内容
4. 如果有不确定的地方，去对照 `references/source-code/foundation-source.md`
5. 基于真实的 `LazyList` 实现给出修复方案

不会编造 API，也不会瞎猜行为。

## 来源

源码来自 [`androidx/androidx`](https://github.com/androidx/androidx/tree/androidx-main/compose) 和 [`JetBrains/compose-multiplatform-core`](https://github.com/JetBrains/compose-multiplatform-core)，遵循 Apache License 2.0。指南文档是基于这些源码与官方文档的原创分析。

## 贡献

欢迎 PR，特别是：
- 更多平台相关的坑点和绕坑写法
- 常见 UI 模式的新动画配方
- 真实应用中的生产崩溃模式
- 跟进新版 Compose/CMP 的修订
- 用于跟踪新版本的自动更新工具

## 许可证

MIT —— 见 [LICENSE](LICENSE)。

`androidx/androidx` 的源码遵循 Apache License 2.0，版权归 The Android Open Source Project 所有。`compose-multiplatform-core` 的源码遵循 Apache License 2.0，版权归 JetBrains s.r.o. 所有。
