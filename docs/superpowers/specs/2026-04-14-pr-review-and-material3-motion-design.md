# Design: PR Review Mode + Material 3 Motion Reference

**Date:** 2026-04-14
**Status:** Approved
**Scope:** Extend `jetpack-compose-expert-skill` with a PR review workflow and a Material 3 motion token reference

---

## Problem

1. The skill has no review mode. Giving it a PR URL produces ad-hoc feedback that misses patterns like missing `modifier` parameters and single-line modifier chains because it reads only the diff, not the full file.
2. `animation.md` covers animation APIs thoroughly but has no connection to M3 motion tokens. Developers hardcode `tween(300)` when they should use `MotionTokens.DurationMedium2`.
3. The skill has no guidance for reviewers catching these issues in PRs.

---

## What We're Building

Three changes, all within `jetpack-compose-expert-skill/`:

1. **`SKILL.md`** — add Review Mode trigger and routing entries
2. **`references/pr-review.md`** — full PR review workflow and Compose checklist
3. **`references/material3-motion.md`** — M3 motion token reference (sourced from AOSP)

---

## Source Requirements

All reference content must be sourced from authoritative material — no values from model training memory:

| Content | Primary Source | Secondary Source |
|---------|---------------|-----------------|
| M3 motion token values | `material3-source.md` (already in repo, 856 KB) | Live AOSP `MotionTokens.kt`, `EasingTokens.kt` on `androidx-main` |
| M3 easing token values | `material3-source.md` | Live AOSP `EasingTokens.kt` |
| Modifier ordering rules | `references/modifiers.md` | `ui-source.md` |
| Recomposition checklist items | `references/performance.md` | `runtime-source.md` |
| CMP compatibility rules | `references/multiplatform.md` | `cmp-source.md` |

---

## 1. SKILL.md Changes

### Review Mode Trigger

At the top of the workflow (before step 1), detect review intent:

**Triggers:**
- Input matches PR URL pattern: `github.com/.+/pull/\d+`
- Explicit phrases: "review this PR", "review this diff", "check this code", "what's wrong with this"

**When triggered:** Skip generation workflow entirely. Execute Review Mode (5 steps defined in `pr-review.md`). Do not mix with code generation.

### New Routing Table Entries

```
PR URL / review request          → pr-review.md
M3 motion / MotionTokens         → material3-motion.md
motion token / easing token      → material3-motion.md
tween duration / animation spec  → material3-motion.md (check M3 tokens first)
```

### Cross-references to Add

- `animation.md` routing entry: append "for M3 token selection, also consult material3-motion.md"
- `theming-material3.md` routing entry: append "for motion in M3 components, see material3-motion.md"

---

## 2. `references/pr-review.md`

### Structure

```
1. Review Mode Overview
2. Step-by-step workflow
3. Project settings scan
4. Compose review checklist (5 categories)
5. Output report format
```

### Step-by-Step Workflow

**Step 1 — Fetch the diff**
```bash
gh pr diff <PR_URL>
```
Store as `diff_output`. Note all changed files.

**Step 2 — Fetch full file contents**

For each `.kt` file in the diff, fetch the full file — not just changed lines:
```bash
gh api repos/{owner}/{repo}/contents/{path}?ref={branch} --jq '.content' | base64 -d
```
This is the fix for missed single-line modifiers. The diff shows what changed; the full file shows the actual composable signature, whether a modifier param exists, and how modifiers are structured across lines.

**Step 3 — Scan project settings**

Run in priority order, stop when enough signal found:

1. `.editorconfig` — indent, line length, trailing commas
2. `ktlint` config (`.editorconfig [*.kt]` block or `.editorconfig` root)
3. `detekt.yml` or `detekt/detekt.yml` — complexity, naming
4. **Codebase convention inference** (always run regardless of lint config): sample 3–5 existing composable files NOT in the diff. Infer:
   - How modifiers are chained (one per line vs inline)
   - Whether `Modifier` or `modifier` is used as param name (both are valid; note which the team uses)
   - Trailing lambda style on single-slot composables
   - Whether composables use named params for single-arg calls

Build a **project profile** from this scan. Use it to suppress false positives — a team that consistently writes inline modifiers should not be flagged for it.

**Step 4 — Run checklist**

See checklist below. Evaluate every changed composable against all 5 categories.

**Step 5 — Output report**

See report format below.

### Compose Review Checklist

#### Category 1: Modifier Hygiene

Scan the **full file** (not just diff) for each changed composable.

- [ ] Every `@Composable` function that renders UI has a `modifier: Modifier = Modifier` parameter
- [ ] The `modifier` parameter is passed to the root layout element (not buried or ignored)
- [ ] `modifier` is not applied more than once (e.g., not split across two sibling elements)
- [ ] Modifier ordering follows the paint model: `size/fillMaxWidth` → `padding` → `background/border` → `clickable/focusable`. Flag reversals (e.g., `background` before `padding` when padding should be inside the background).
- [ ] Single-line modifier check: if the composable constructor is on one line with inline modifier (e.g., `Row(modifier = Modifier.fillMaxWidth().padding(16.dp))`), verify ordering is still correct
- [ ] Modifier chain does not use both `Modifier.padding()` and `Modifier.offset()` for the same visual adjustment — these are not equivalent

#### Category 2: Recomposition

- [ ] Composable parameters do not include unstable types (plain `List<T>`, `HashMap`, non-`@Stable` classes) without `@Immutable` or `@Stable` annotation
- [ ] Lambdas passed as parameters are not created inline at call site without `remember {}` (causes recomposition on every parent recompose)
- [ ] `derivedStateOf {}` is used where a value is computed from one or more state reads
- [ ] `remember {}` keys are correct — not `Unit` (never recalculates) or omitted when inputs change

#### Category 3: M3 Motion

Cross-reference with `material3-motion.md` for token values.

- [ ] No hardcoded integer durations in `tween()`, `spring()`, or `keyframes {}` — use `MotionTokens.*`
- [ ] No hardcoded `FastOutSlowInEasing`, `LinearOutSlowInEasing`, `FastOutLinearInEasing` — use M3 easing tokens
- [ ] `animateColorAsState()` without `animationSpec` — flag, add `tween(MotionTokens.DurationShort4.toInt())`
- [ ] `AnimatedVisibility` enter/exit do not use matched durations — enter should use decelerate easing, exit should use accelerate easing (different token families)
- [ ] Duration > 600ms on non-shared-element animation — flag as too slow

#### Category 4: CMP Compatibility

Only apply to files that appear to be in `commonMain` (path contains `commonMain` or no platform suffix).

- [ ] No `android.*` imports
- [ ] No `androidx.*` imports that are Android-only (check `multiplatform.md` API availability matrix)
- [ ] No `LocalContext.current` usage
- [ ] No `Activity` or `Context` references
- [ ] Resources use `Res.*` not `R.*`

#### Category 5: Lists & Keys

- [ ] Every `items()` call in `LazyColumn`/`LazyRow`/`LazyGrid` has a `key = {}` parameter
- [ ] `contentType = {}` is present when a lazy list renders more than one type of item
- [ ] No `LazyColumn` nested inside `LazyColumn` without explicit height constraint (causes unbounded height crash)
- [ ] `TvLazyRow`/`TvLazyColumn` from `tv-foundation` flagged as deprecated — replace with standard Foundation equivalents

### Output Report Format

```
## PR Review: <PR title> (#NNN)
Branch: <head> → <base>

### Project Profile
- Code style: [inferred — e.g., "modifiers chained one per line", "trailing lambdas preferred"]
- Lint config: [ktlint found / detekt found / none found]
- Conventions inferred from: [files sampled]

---

### Issues

#### Critical
Issues that will cause bugs, crashes, or correctness problems.
- `path/to/File.kt:42` — Missing `modifier: Modifier = Modifier` parameter on `MyCard`. Modifier is required on all UI composables for caller control of layout.

#### Suggestions
Style, M3 alignment, performance improvements.
- `path/to/File.kt:87` — `tween(300)` → use `MotionTokens.DurationMedium2.toInt()` (300ms maps to Medium2 in M3 motion scale)
- `path/to/File.kt:103` — `FastOutSlowInEasing` → use `EmphasizedDecelerateEasing` (M3 equivalent for entering elements)

#### Positive Patterns
Good Compose usage worth noting.
- `path/to/File.kt:55` — Correct use of `derivedStateOf {}` to avoid redundant recomposition
- `path/to/File.kt:71` — Shared element transition correctly uses `sharedBounds()` for container-to-page expansion

---

### Summary
X critical issues, Y suggestions across Z files.
```

Critical and Suggestions are mandatory sections. Positive Patterns is always included — reviews should not read as a pure hit list.

---

## 3. `references/material3-motion.md`

### Source Requirement

Before writing this file, the implementation step must:
1. Read `material3-source.md` for `MotionTokens`, `EasingTokens`, and related definitions
2. Fetch live AOSP source for `MotionTokens.kt` and `EasingTokens.kt` from `androidx-main` branch to verify current values
3. Only write token values and easing curves that appear in the actual source — no values from training memory

### Structure

```
1. Overview — what M3 motion tokens are and why to use them
2. Duration token table — all tokens with values and use cases
3. Easing token table — all tokens with CubicBezierEasing values and use cases
4. Mapping to Compose animation APIs — how to use tokens in tween/spring/AnimatedVisibility
5. Decision tree — how to pick the right token
6. Review flags — patterns to catch in PRs
7. CMP compatibility note
```

### Section Descriptions

**Duration tokens:** Full table of `MotionTokens.DurationShort1–4`, `DurationMedium1–4`, `DurationLong1–4`, `DurationExtraLong1–4` with millisecond values sourced from AOSP and guidance on which interaction scale each covers.

**Easing tokens:** Full table of all named easing curves (`Emphasized`, `EmphasizedDecelerate`, `EmphasizedAccelerate`, `Standard`, `StandardDecelerate`, `StandardAccelerate`) with their `CubicBezierEasing(x1, y1, x2, y2)` values sourced from AOSP and human-readable guidance (entering vs. exiting vs. state-change context).

**Compose API mapping:** Code examples showing how to use tokens in:
- `tween(durationMillis = MotionTokens.DurationMedium2.toInt(), easing = EmphasizedDecelerateEasing)`
- `AnimatedVisibility` enter/exit pairing (asymmetric durations — exit is faster)
- `updateTransition` with token-based specs per animated value
- `animateColorAsState` with correct spec

**Decision tree:** Text-based flowchart:
- Micro interaction (ripple, check, toggle) → Short1–2
- Component state change (button press, chip, icon) → Short3–4
- Container change (card expand, FAB, menu) → Medium1–2
- Screen-level transition (dialog, bottom sheet, nav) → Medium3–4
- Shared element / hero transition → Long1–2
- Full-screen complex transition → Long3–ExtraLong1

**Review flags table:** Patterns found in diffs → flag → suggested fix (feeds into `pr-review.md` checklist Category 3).

**CMP note:** `MotionTokens` is in `androidx.compose.material3` — available on all CMP targets (Android, Desktop, iOS, Web) since M3 1.2.0. No platform guards needed.

---

## What We're Not Building

- No GitHub comment posting — review output is local only
- No new routing for components (Button, TextField, etc.) — that's a separate spec
- No M2→M3 migration table — already partially covered in `deprecated-patterns.md`
- No adaptive/responsive layout patterns — separate scope

---

## File Checklist

- [ ] `SKILL.md` — Review Mode trigger block + 2 new routing entries + cross-reference notes
- [ ] `references/pr-review.md` — Full review workflow + checklist + report format
- [ ] `references/material3-motion.md` — M3 motion token reference (sourced from AOSP)
- [ ] `README.md` — bump reference count 18 → 19, add M3 motion to coverage table

Note: `pr-review.md` is a workflow document, not a reference counted in the "18 guides" — it activates a different mode. Only `material3-motion.md` increments the reference count.
