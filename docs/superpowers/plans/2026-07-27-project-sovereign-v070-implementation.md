# PROJECT SOVEREIGN v0.7 Political Drama Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the existing deterministic nation-management simulation into a character-led political strategy game with a mandatory new-game setup, Japanese-yen display, visible failure routes, meaningful war objectives and rewards, and multiple endings.

**Architecture:** Keep the existing economy, diplomacy, policy and military simulation as the source of truth. Add focused narrative modules under `src/narrative`, a shared money formatter under `src/ui`, and small UI renderers that consume deterministic derived models. Persist only schema-version-2 v0.7 state; do not migrate prior saves.

**Tech Stack:** TypeScript 5.8, browser DOM APIs, inline SVG, Node test runner, static HTML/CSS build, Cloudflare static deployment.

## Global Constraints

- Internal `1B` equals `10億円`.
- New games require nation, ambition and one of three secretaries.
- Character balance is two women and one man.
- Character presentation uses original inline SVG upper-body portraits and compact icons, with no runtime image service.
- Advice, risks, war previews and endings are deterministic and explainable.
- No tactical battle map, unit-control layer, external AI call or runtime icon dependency.
- No migration from v0.5-v0.6.2; v0.7 uses schema version 2.
- A valid v0.7 save can still be resumed and exported.

---

### Task 1: New Narrative State and Yen Formatter

**Files:**
- Modify: `src/domain/types.ts`
- Create: `src/ui/money.ts`
- Modify: `src/content/create-world.ts`
- Test: `tests/money.test.ts`
- Test: `tests/narrative-state.test.ts`

**Interfaces:**
- Produces: `formatYenFromB(valueB, options?)`
- Produces: `createInitialWorld({ playerNationId, seed, ambitionId, secretaryId })`
- Produces: `world.narrative` with secretary, ambition, risk clocks, war legacy and ending state.

- [ ] Write formatter tests covering `0円`, `万円`, `億円`, `兆円`, signs and separators.
- [ ] Run the formatter test and verify it fails because `money.ts` does not exist.
- [ ] Implement the formatter and rerun the test.
- [ ] Write a failing world-creation test requiring ambition and secretary state.
- [ ] Add narrative types and initialize schema-version-2 v0.7 worlds.
- [ ] Update existing tests to pass explicit default ambition and secretary through a shared test helper.
- [ ] Run all tests and commit.

### Task 2: Secretary Catalog, Portraits and Deterministic Briefing

**Files:**
- Create: `src/narrative/secretaries.ts`
- Create: `src/narrative/secretary-system.ts`
- Create: `src/ui/secretary-portraits.ts`
- Modify: `src/narrative/index.ts`
- Test: `tests/secretary-system.test.ts`
- Test: `tests/secretary-portraits.test.ts`

**Interfaces:**
- Produces: `getSecretaryDefinition(secretaryId)`
- Produces: `getSecretaryBriefing(world)`
- Produces: `updateSecretaryState(previous, next, commands)`
- Produces: `renderSecretaryPortrait(secretaryId, expression, compact?)`

- [ ] Write failing tests for all three secretaries, five expressions and accessible SVG output.
- [ ] Implement the catalog and original SVG portrait system.
- [ ] Write failing briefing tests for treasury, trade, war and stable-state scenarios.
- [ ] Implement deterministic three-part briefings with source metric labels.
- [ ] Write failing trust/stress update tests.
- [ ] Implement bounded trust/stress changes and secretary-specific small modifiers.
- [ ] Run all tests and commit.

### Task 3: Mandatory New-Game Wizard and v0.7-Only Saves

**Files:**
- Modify: `src/ui/main.ts`
- Modify: `src/save/save.ts`
- Modify: `src/save/indexed-db.ts`
- Modify: `tests/save.test.ts`
- Replace: `tests/v06-save-migration.test.ts`
- Test: `tests/new-game-setup-ui.test.ts`

**Interfaces:**
- Consumes: secretary catalog and portrait renderer.
- Produces: start-screen controls with `data-start-nation`, `data-ambition-id`, `data-secretary-id`.
- Produces: save parser that accepts schema version 2 and rejects older versions.

- [ ] Write failing UI-contract tests for nation, ambition and secretary selection.
- [ ] Implement the three-step start screen with one final “統治を開始” action.
- [ ] Write failing save tests that reject schema version 1 and accept schema version 2.
- [ ] Remove migration behavior and implement clear v0.7-only validation.
- [ ] Ensure resume is shown only for a valid v0.7 save.
- [ ] Run all tests and commit.

### Task 4: Survival Risks, Last-Chance Decisions and Game Over

**Files:**
- Create: `src/narrative/survival.ts`
- Modify: `src/domain/types.ts`
- Modify: `src/domain/commands.ts`
- Modify: `src/simulation/engine.ts`
- Create: `src/ui/game-over-view.ts`
- Modify: `src/ui/command-center-view.ts`
- Modify: `src/ui/main.ts`
- Test: `tests/survival.test.ts`
- Test: `tests/game-over-ui.test.ts`

**Interfaces:**
- Produces: `evaluateSurvivalRisks(world)`
- Produces: `updateSurvivalState(previous, next, commands)`
- Produces: `applyLastChanceCommand(world, command, events)`
- Produces: `renderGameOver(world)`

- [ ] Write failing tests for fiscal default, government collapse, coup, war defeat and state collapse.
- [ ] Implement derived risk metrics, percentages, causes, recovery targets and persistence clocks.
- [ ] Write failing tests for one final rescue choice per non-war route and “accept defeat”.
- [ ] Add last-chance commands and deterministic penalties.
- [ ] Integrate survival updates after each simulated month.
- [ ] Add risk cards to the command room and a full game-over screen.
- [ ] Run all tests and commit.

### Task 5: National Ambitions and Endings

**Files:**
- Create: `src/narrative/ambitions.ts`
- Create: `src/narrative/endings.ts`
- Modify: `src/simulation/engine.ts`
- Create: `src/ui/ending-view.ts`
- Modify: `src/ui/command-center-view.ts`
- Modify: `src/ui/main.ts`
- Test: `tests/ambitions.test.ts`
- Test: `tests/endings.test.ts`

**Interfaces:**
- Produces: `getAmbitionDefinition(id)`
- Produces: `evaluateAmbition(world)`
- Produces: `updateAmbitionStreak(world)`
- Produces: `selectEnding(world)`
- Produces: `renderEnding(world)`

- [ ] Write failing tests for five ambitions and progress labels.
- [ ] Implement deterministic progress and 12-turn streak completion.
- [ ] Write failing tests for six main and three hidden endings.
- [ ] Implement ending selection and score breakdown.
- [ ] Add ambition progress to the command room and ending display flow.
- [ ] Run all tests and commit.

### Task 6: War Objectives, Preview, Victory Report and Settlement

**Files:**
- Modify: `src/domain/types.ts`
- Modify: `src/domain/commands.ts`
- Modify: `src/domain/command-planning.ts`
- Modify: `src/military/system.ts`
- Create: `src/narrative/war-outcomes.ts`
- Modify: `src/ui/main.ts`
- Test: `tests/war-objectives.test.ts`
- Test: `tests/war-settlement.test.ts`

**Interfaces:**
- `declare-war` consumes `objective: WarObjective`.
- Produces: `getWarPreview(world, targetNationId, objective)`.
- Produces: pending settlement state after a player victory.
- `resolve-war-settlement` consumes posture and governance.

- [ ] Write failing command-validation tests requiring an offensive-war objective.
- [ ] Add objective fields and deterministic war preview estimates.
- [ ] Write failing tests for recorded war costs and casualties.
- [ ] Record player war cost, baseline casualties and objective in `WarState`.
- [ ] Write failing settlement tests for lenient, balanced and harsh rewards.
- [ ] Implement reparations, reputation, resistance and legacy bonuses.
- [ ] Replace confirm-only declaration UI with objective cards and visible estimates.
- [ ] Add victory report and mandatory settlement panel.
- [ ] Run all tests and commit.

### Task 7: Yen Conversion Across All Player-Facing Money

**Files:**
- Modify: `src/ui/app-shell.ts`
- Modify: `src/ui/main.ts`
- Modify: `src/ui/command-center-view.ts`
- Modify: `src/ui/turn-result-view.ts`
- Modify: `src/ui/turn-result-overlay.ts`
- Modify: `src/gameplay/crisis-director.ts`
- Modify: `src/gameplay/objectives.ts`
- Modify: `src/gameplay/issue-guidance.ts`
- Modify: any remaining player-facing formatter call sites found by repository scan.
- Test: `tests/yen-ui-contract.test.ts`

**Interfaces:**
- Consumes: `formatYenFromB` only; no local `B` suffix formatting remains in rendered UI.

- [ ] Write a failing repository contract test that identifies player-facing `B` suffixes.
- [ ] Convert the command dock, metrics, analysis, company, war and report displays.
- [ ] Convert crisis guidance and objective labels.
- [ ] Keep non-currency units unchanged.
- [ ] Run the contract test, full tests and commit.

### Task 8: Pop Visual Refresh and Responsive Command Room

**Files:**
- Modify: `public/styles.css`
- Modify: `src/ui/visual-language.ts`
- Modify: `src/ui/app-shell.ts`
- Modify: `src/ui/command-center-view.ts`
- Test: `tests/v07-visual-language.test.ts`
- Test: `tests/v07-command-room-ui.test.ts`

**Interfaces:**
- Produces accessible inline SVG category icons.
- Produces desktop secretary rail and compact briefing behavior.

- [ ] Write failing visual-contract tests for character rail, risk states, ambition badge and icon accessibility.
- [ ] Expand the icon catalog for ambition, relationship, victory, defeat, territory and resources.
- [ ] Apply a slightly pop visual language using rounded shapes, clearer category accents and restrained motion.
- [ ] Ensure the portrait does not obscure controls or introduce internal scrolling at common desktop widths.
- [ ] Add narrow-layout portrait collapse and preserve all critical warnings.
- [ ] Run tests and commit.

### Task 9: Integration, Balance, E2E and Release Packaging

**Files:**
- Modify: `scripts/e2e.py`
- Modify: `tests/e2e-contract.test.ts`
- Modify: `package.json`
- Create: `RELEASE_NOTES-v0.7.0.md`
- Modify: `README.md`
- Modify: deployment reconstruction files in the repository wrapper.

**Interfaces:**
- Produces a reproducible v0.7 patch and static `dist` output.

- [ ] Add an E2E flow covering new game setup, secretary briefing, one policy turn, risk display, war preview and yen formatting.
- [ ] Add deterministic long-run checks for normal play, collapse and ambition completion.
- [ ] Run `npm test`.
- [ ] Run `npm run typecheck`.
- [ ] Run `npm run build`.
- [ ] Run the Chromium E2E script.
- [ ] Inspect built output for v0.7 markers and prohibited old `B` labels.
- [ ] Create release notes and package the verified patch for repository reconstruction.
- [ ] Commit and publish the feature branch for review.
