# PROJECT SOVEREIGN Expanded Systems Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans and superpowers:test-driven-development. Every production behavior must begin with a failing test.

**Goal:** Expand the playable foundation into a broad public alpha containing parliament and laws, research, infrastructure projects, deterministic crises, military conflict, intelligence operations, achievements, and matching UI views.

**Architecture:** Preserve the pure deterministic monthly engine and serializable `WorldState`. Each new subsystem owns a focused state model and monthly update function; `engine.ts` orchestrates them in a fixed order. Browser UI submits typed commands only, and save validation is extended for every new state block.

**Tech Stack:** Node.js 22+, TypeScript 5.8 strict mode, browser Web Worker, IndexedDB, Web standard APIs, Node built-in test runner, static Cloudflare Pages deployment.

## Global Constraints

- No paid API, server runtime, or external runtime library.
- One turn equals one month and all randomness derives from the saved world seed.
- The same state and command list must produce byte-equivalent output.
- New systems must survive at least 1,200 turns without NaN, negative populations, or invalid ownership.
- Player-facing results must include Japanese explanations and event records.
- Existing saves remain loadable through schema migration or an explicit version rejection.

---

### Task 1: Parliament, Parties, Elections, and Laws

**Files:**
- Modify: `src/domain/types.ts`
- Create: `src/politics/catalog.ts`
- Create: `src/politics/system.ts`
- Modify: `src/domain/commands.ts`
- Modify: `src/content/create-world.ts`
- Modify: `src/simulation/engine.ts`
- Test: `tests/politics.test.ts`

**Interfaces:**
- Produces `PartyState`, `ParliamentState`, `LawDefinition`, `LawState`.
- Produces commands `propose-law`, `repeal-law`, `call-snap-election`.
- Produces `updatePolitics(world, previous, events)` and `applyPoliticalCommand(...)`.

**Acceptance tests:**
- Four parties and a seat total are created for each nation.
- A law passes only with sufficient coalition support and political capital.
- Elections are deterministic and preserve total seats.
- Active laws apply measurable modifiers to economy or population.

### Task 2: Research, Technologies, and Infrastructure Projects

**Files:**
- Modify: `src/domain/types.ts`
- Create: `src/development/catalog.ts`
- Create: `src/development/system.ts`
- Modify: `src/domain/commands.ts`
- Modify: `src/content/create-world.ts`
- Modify: `src/simulation/engine.ts`
- Test: `tests/development.test.ts`

**Interfaces:**
- Produces `ResearchState`, `TechnologyState`, `InfrastructureProject`.
- Produces commands `set-research-focus`, `start-infrastructure-project`.
- Produces monthly research progress, unlock events, project completion, region effects, and fiscal costs.

**Acceptance tests:**
- Research focus changes progress distribution without changing total generated research.
- Technology unlocks are deterministic and idempotent.
- Infrastructure projects consume treasury over time and improve the target region on completion.

### Task 3: Deterministic Crises and National Response

**Files:**
- Modify: `src/domain/types.ts`
- Create: `src/crises/catalog.ts`
- Create: `src/crises/system.ts`
- Modify: `src/domain/commands.ts`
- Modify: `src/simulation/engine.ts`
- Test: `tests/crises.test.ts`

**Interfaces:**
- Produces `ActiveCrisis`, crisis definitions, and response commands.
- Produces `triggerCrises(world, events)` and `updateCrises(world, events)`.

**Acceptance tests:**
- Identical seeds trigger identical crises on identical turns.
- Crisis response reduces duration or impact and consumes treasury/political capital.
- Severe crises stop multi-month advance and appear in the national report.

### Task 4: Military, Mobilization, War, and Peace

**Files:**
- Modify: `src/domain/types.ts`
- Create: `src/military/system.ts`
- Modify: `src/domain/commands.ts`
- Modify: `src/content/create-world.ts`
- Modify: `src/simulation/engine.ts`
- Test: `tests/military.test.ts`

**Interfaces:**
- Produces `MilitaryState`, `WarState`, `WarFrontState`.
- Produces commands `set-military-budget`, `mobilize`, `declare-war`, `offer-peace`.
- Produces deterministic monthly readiness, equipment, casualties, war exhaustion, and negotiated peace.

**Acceptance tests:**
- Declaration requires sufficient political capital and no existing war.
- Mobilization raises readiness while reducing workforce and increasing spending.
- War calculations are deterministic, finite, and never create negative manpower.
- Peace closes the war symmetrically for both states.

### Task 5: Intelligence and Covert Operations

**Files:**
- Modify: `src/domain/types.ts`
- Create: `src/intelligence/system.ts`
- Modify: `src/domain/commands.ts`
- Modify: `src/content/create-world.ts`
- Modify: `src/simulation/engine.ts`
- Test: `tests/intelligence.test.ts`

**Interfaces:**
- Produces `IntelligenceState`, `CovertOperation`.
- Produces commands `set-intelligence-budget`, `launch-intelligence-operation`.
- Produces deterministic reconnaissance, influence, industrial sabotage, detection, diplomatic consequences, and reports.

**Acceptance tests:**
- Operations have validated targets, costs, duration, and deterministic outcomes.
- Detection reduces trust and increases grievance.
- Reconnaissance updates intelligence confidence without directly changing target resources.

### Task 6: UI Integration, Achievements, and Expanded Save Validation

**Files:**
- Modify: `src/ui/main.ts`
- Modify: `public/styles.css`
- Modify: `src/save/save.ts`
- Modify: `src/simulation/invariants.ts`
- Modify: `tests/ui-contract.test.ts`
- Modify: `tests/save.test.ts`
- Create: `tests/expanded-long-run.test.ts`

**Interfaces:**
- Adds tabs for politics, development, defense, intelligence, and crises.
- Adds `AchievementState` and deterministic achievement evaluation.
- Extends save validation and invariants for all new systems.

**Acceptance tests:**
- Built HTML/JS exposes all expanded tabs and command controls.
- Malformed expanded save blocks are rejected.
- A 1,200-turn AI-only run preserves all expanded invariants.
- `npm run verify` passes and `dist/` contains Cloudflare deployment contracts.
