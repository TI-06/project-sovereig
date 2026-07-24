# PROJECT SOVEREIGN Foundation Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a deterministic, browser-playable vertical slice with four nations, monthly turns, basic economy, companies, population, politics, diplomacy, explanations, local saves, and automated tests.

**Architecture:** Use a pnpm TypeScript monorepo. The simulation is a pure deterministic package graph executed inside a Web Worker; React only renders state and submits commands. IndexedDB persistence is isolated behind a versioned save repository.

**Tech Stack:** Node.js 24 LTS, pnpm, TypeScript strict mode, React 19.2, Vite 8.1, Tailwind CSS 4.3, Zustand, Zod, Dexie, Web Worker, Vitest, Playwright.

## Global Constraints

- PC browser first; Japanese UI only for the vertical slice.
- One turn equals one game month.
- No paid API, paid asset, or server dependency is required to play.
- The same initial state, command log, and random seed must produce the same output.
- `Math.random()` is prohibited in simulation packages.
- React components must not contain simulation formulas.
- TypeScript must use `strict: true`.
- All domain state must be serializable as JSON.
- Every task ends with tests and a commit.

---

## File Map

```text
apps/web/
├─ src/app/App.tsx                     application shell
├─ src/app/store.ts                    UI state and worker bridge state
├─ src/features/dashboard/             main national dashboard
├─ src/features/turn-controls/         month advance controls
├─ src/features/report/                monthly report and explanations
├─ src/features/policies/              policy editing UI
├─ src/worker/simulation.worker.ts     simulation worker endpoint
├─ src/worker/client.ts                typed worker client
└─ e2e/game-flow.spec.ts               browser acceptance test

packages/domain/src/                   IDs, state, commands, reports
packages/simulation-core/src/          deterministic engine and pipeline
packages/economy/src/                  budget, production, market, indicators
packages/companies/src/                company decisions and accounting
packages/population/src/               cohorts, employment, happiness
packages/politics/src/                 support and government stability
packages/diplomacy/src/                relations and basic nation AI
packages/content/src/                  four-nation seed content
packages/save-schema/src/              validation, checksum, migration
packages/test-fixtures/src/             reusable deterministic fixtures
```

---

### Task 1: Monorepo and Quality Gate

**Files:**
- Create: `package.json`
- Create: `pnpm-workspace.yaml`
- Create: `tsconfig.base.json`
- Create: `eslint.config.js`
- Create: `.prettierrc.json`
- Create: `.gitignore`
- Create: `vitest.workspace.ts`
- Create: `.github/workflows/ci.yml`
- Test: `tooling/tests/repository.test.ts`

**Interfaces:**
- Consumes: none
- Produces: workspace commands `pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm build`

- [ ] **Step 1: Write the repository contract test**

```ts
// tooling/tests/repository.test.ts
import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';

const readJson = (path: string) => JSON.parse(readFileSync(path, 'utf8'));

describe('repository contract', () => {
  it('enables strict TypeScript and exposes quality commands', () => {
    const tsconfig = readJson('tsconfig.base.json');
    const pkg = readJson('package.json');
    expect(tsconfig.compilerOptions.strict).toBe(true);
    expect(pkg.scripts).toMatchObject({
      lint: expect.any(String),
      typecheck: expect.any(String),
      test: expect.any(String),
      build: expect.any(String),
    });
  });
});
```

- [ ] **Step 2: Run the test and verify failure**

Run: `pnpm vitest run tooling/tests/repository.test.ts`
Expected: FAIL because root configuration files do not exist.

- [ ] **Step 3: Create the root workspace files**

```json
// package.json
{
  "name": "project-sovereign",
  "private": true,
  "packageManager": "pnpm@10.15.1",
  "scripts": {
    "dev": "pnpm --filter @sovereign/web dev",
    "build": "pnpm -r build",
    "lint": "eslint .",
    "typecheck": "pnpm -r typecheck",
    "test": "vitest run --workspace vitest.workspace.ts",
    "test:watch": "vitest --workspace vitest.workspace.ts",
    "test:e2e": "pnpm --filter @sovereign/web test:e2e"
  },
  "devDependencies": {
    "@eslint/js": "10.7.0",
    "eslint": "10.7.0",
    "prettier": "3.9.6",
    "typescript": "7.0.2",
    "typescript-eslint": "8.65.0",
    "vitest": "4.1.10"
  }
}
```

```yaml
# pnpm-workspace.yaml
packages:
  - apps/*
  - packages/*
  - tooling
```

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "target": "ES2023",
    "lib": ["ES2023", "DOM", "WebWorker"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "verbatimModuleSyntax": true,
    "isolatedModules": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  }
}
```

- [ ] **Step 4: Install dependencies and run all quality commands**

Run: `corepack enable && pnpm install && pnpm test && pnpm typecheck && pnpm lint`
Expected: repository contract PASS; no type or lint errors.

- [ ] **Step 5: Commit**

```bash
git add package.json pnpm-workspace.yaml tsconfig.base.json eslint.config.js .prettierrc.json .gitignore vitest.workspace.ts .github tooling
git commit -m "chore: initialize sovereign monorepo quality gates"
```

---

### Task 2: Domain Types and Command Validation

**Files:**
- Create: `packages/domain/package.json`
- Create: `packages/domain/tsconfig.json`
- Create: `packages/domain/src/ids.ts`
- Create: `packages/domain/src/state.ts`
- Create: `packages/domain/src/commands.ts`
- Create: `packages/domain/src/report.ts`
- Create: `packages/domain/src/index.ts`
- Test: `packages/domain/src/commands.test.ts`

**Interfaces:**
- Consumes: root TypeScript config
- Produces: `WorldState`, `NationState`, `PlayerCommand`, `MonthlyReport`, `validateCommands(commands, state)`

- [ ] **Step 1: Write failing command validation tests**

```ts
import { describe, expect, it } from 'vitest';
import { validateCommands } from './commands';
import type { WorldState } from './state';

const state = {
  turn: 0,
  date: { year: 2035, month: 1 },
  playerNationId: 'nation:a',
  nations: {
    'nation:a': {
      id: 'nation:a',
      name: 'アルカディア共和国',
      treasury: 1000,
      debt: 500,
      taxPolicy: { income: 0.2, corporate: 0.25, consumption: 0.1 },
      policyRate: 0.02,
    },
  },
} as unknown as WorldState;

describe('validateCommands', () => {
  it('rejects tax rates outside zero to one', () => {
    const result = validateCommands([
      { type: 'set-tax-rate', tax: 'income', value: 1.2 },
    ], state);
    expect(result.ok).toBe(false);
  });

  it('accepts a legal rate for the player nation', () => {
    const result = validateCommands([
      { type: 'set-tax-rate', tax: 'income', value: 0.24 },
    ], state);
    expect(result).toEqual({ ok: true, commands: expect.any(Array) });
  });
});
```

- [ ] **Step 2: Run test and verify failure**

Run: `pnpm --filter @sovereign/domain test`
Expected: FAIL because the domain package and validator do not exist.

- [ ] **Step 3: Implement branded IDs, serializable state, commands, and validation**

```ts
// packages/domain/src/commands.ts
import type { WorldState } from './state';

export type TaxKind = 'income' | 'corporate' | 'consumption';

export type PlayerCommand =
  | { type: 'set-tax-rate'; tax: TaxKind; value: number }
  | { type: 'set-policy-rate'; value: number }
  | { type: 'set-budget-share'; category: 'education' | 'healthcare' | 'industry'; value: number }
  | { type: 'propose-trade-agreement'; targetNationId: string };

export type ValidationResult =
  | { ok: true; commands: PlayerCommand[] }
  | { ok: false; errors: Array<{ index: number; message: string }> };

export function validateCommands(commands: PlayerCommand[], state: WorldState): ValidationResult {
  const errors: Array<{ index: number; message: string }> = [];
  commands.forEach((command, index) => {
    if (command.type === 'set-tax-rate' && (command.value < 0 || command.value > 1)) {
      errors.push({ index, message: '税率は0%以上1以下で指定してください。' });
    }
    if (command.type === 'set-policy-rate' && (command.value < -0.05 || command.value > 0.5)) {
      errors.push({ index, message: '政策金利は-5%以上50%以下で指定してください。' });
    }
  });
  return errors.length === 0 ? { ok: true, commands } : { ok: false, errors };
}
```

- [ ] **Step 4: Run domain tests and typecheck**

Run: `pnpm --filter @sovereign/domain test && pnpm --filter @sovereign/domain typecheck`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/domain
git commit -m "feat: define sovereign domain state and commands"
```

---

### Task 3: Deterministic Random Generator and Monthly Pipeline

**Files:**
- Create: `packages/simulation-core/package.json`
- Create: `packages/simulation-core/src/rng.ts`
- Create: `packages/simulation-core/src/pipeline.ts`
- Create: `packages/simulation-core/src/invariants.ts`
- Create: `packages/simulation-core/src/index.ts`
- Test: `packages/simulation-core/src/rng.test.ts`
- Test: `packages/simulation-core/src/pipeline.test.ts`

**Interfaces:**
- Consumes: domain state, commands, reports
- Produces: `createRng(seed)`, `deriveSeed(worldSeed, turn, subsystem, entityId)`, `advanceMonth(input)`

- [ ] **Step 1: Write failing determinism tests**

```ts
import { describe, expect, it } from 'vitest';
import { createRng, deriveSeed } from './rng';

describe('deterministic RNG', () => {
  it('replays the same sequence for the same seed', () => {
    const a = createRng('world-1');
    const b = createRng('world-1');
    expect([a.next(), a.next(), a.next()]).toEqual([b.next(), b.next(), b.next()]);
  });

  it('derives isolated per-subsystem streams', () => {
    expect(deriveSeed('world-1', 12, 'companies', 'company-1'))
      .not.toBe(deriveSeed('world-1', 12, 'population', 'company-1'));
  });
});
```

- [ ] **Step 2: Run tests and verify failure**

Run: `pnpm --filter @sovereign/simulation-core test`
Expected: FAIL because RNG and pipeline do not exist.

- [ ] **Step 3: Implement xoshiro128** and a fixed pipeline order**

Pipeline order:
1. validate and apply commands
2. update companies
3. clear markets and trade
4. update employment and population
5. calculate macro indicators and budget
6. update politics
7. update diplomacy and AI commands for next turn
8. create explanations and report
9. assert invariants

- [ ] **Step 4: Run determinism tests twice**

Run: `pnpm --filter @sovereign/simulation-core test && pnpm --filter @sovereign/simulation-core test`
Expected: both runs return identical snapshots and PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/simulation-core
git commit -m "feat: add deterministic monthly simulation pipeline"
```

---

### Task 4: Four-Nation Content Pack

**Files:**
- Create: `packages/content/package.json`
- Create: `packages/content/src/goods.ts`
- Create: `packages/content/src/nations.ts`
- Create: `packages/content/src/regions.ts`
- Create: `packages/content/src/companies.ts`
- Create: `packages/content/src/cohorts.ts`
- Create: `packages/content/src/create-world.ts`
- Create: `packages/content/src/index.ts`
- Test: `packages/content/src/create-world.test.ts`

**Interfaces:**
- Consumes: domain state types
- Produces: `createInitialWorld({ playerNationId, seed }): WorldState`

- [ ] **Step 1: Write failing content cardinality test**

```ts
it('creates the full vertical-slice world', () => {
  const world = createInitialWorld({ playerNationId: 'nation:arcadia', seed: 'demo' });
  expect(Object.keys(world.nations)).toHaveLength(4);
  expect(Object.keys(world.regions)).toHaveLength(12);
  expect(Object.keys(world.goods)).toHaveLength(8);
  expect(Object.keys(world.companies)).toHaveLength(24);
  expect(Object.keys(world.cohorts)).toHaveLength(36);
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/content test`
Expected: FAIL because the content package does not exist.

- [ ] **Step 3: Define balanced seed content**

Nations:
- `nation:arcadia`: diversified democracy, medium debt, high education
- `nation:dorn`: resource exporter, centralized politics, low population
- `nation:lumen`: industrial export state, energy importer
- `nation:selene`: service and finance state, high inequality

Each has three regions, six companies, and nine cohorts.

- [ ] **Step 4: Run cardinality and reference-integrity tests**

Run: `pnpm --filter @sovereign/content test`
Expected: PASS; every region/company/cohort owner ID resolves.

- [ ] **Step 5: Commit**

```bash
git add packages/content
git commit -m "feat: add four-nation playable content pack"
```

---

### Task 5: Economy, Budget, and Market Clearing

**Files:**
- Create: `packages/economy/package.json`
- Create: `packages/economy/src/budget.ts`
- Create: `packages/economy/src/production.ts`
- Create: `packages/economy/src/market.ts`
- Create: `packages/economy/src/trade.ts`
- Create: `packages/economy/src/indicators.ts`
- Create: `packages/economy/src/index.ts`
- Test: `packages/economy/src/economy.test.ts`

**Interfaces:**
- Consumes: previous world state, company production intentions
- Produces: `EconomyResult` with prices, output, trade, government revenue, spending, indicators

- [ ] **Step 1: Write failing economic response tests**

```ts
it('raises food price when supply falls below demand', () => {
  const result = clearMarket({ supply: 80, demand: 100, previousPrice: 1 });
  expect(result.price).toBeGreaterThan(1);
  expect(result.quantity).toBe(80);
});

it('increases revenue when income tax rises without instantly raising GDP', () => {
  const low = calculateBudget(fixture({ incomeTax: 0.2 }));
  const high = calculateBudget(fixture({ incomeTax: 0.25 }));
  expect(high.revenue).toBeGreaterThan(low.revenue);
  expect(high.gdpBeforeBehavioralEffects).toBe(low.gdpBeforeBehavioralEffects);
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/economy test`
Expected: FAIL because economy functions do not exist.

- [ ] **Step 3: Implement bounded market, budget, trade, and indicators**

Use price changes capped to ±15% monthly. Government spending exceeding revenue adds debt. Negative treasury converts to debt at month end. Exchange rate changes are capped to ±8% monthly.

- [ ] **Step 4: Run economy tests and full invariants**

Run: `pnpm --filter @sovereign/economy test && pnpm --filter @sovereign/simulation-core test`
Expected: PASS; no NaN, infinity, negative prices, or negative debt.

- [ ] **Step 5: Commit**

```bash
git add packages/economy
git commit -m "feat: implement national economy and market clearing"
```

---

### Task 6: Individual Companies

**Files:**
- Create: `packages/companies/package.json`
- Create: `packages/companies/src/decision.ts`
- Create: `packages/companies/src/accounting.ts`
- Create: `packages/companies/src/insolvency.ts`
- Create: `packages/companies/src/index.ts`
- Test: `packages/companies/src/companies.test.ts`

**Interfaces:**
- Consumes: company state, market prices, nation policy, deterministic RNG stream
- Produces: `CompanyMonthlyResult` and company state updates

- [ ] **Step 1: Write failing insolvency test**

```ts
it('enters distress after three consecutive cash shortfalls', () => {
  const company = companyFixture({ cash: 0, monthlyFixedCost: 10 });
  const result = runCompanyMonths(company, 3, lossMarketFixture());
  expect(result.company.status).toBe('distressed');
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/companies test`
Expected: FAIL because company system does not exist.

- [ ] **Step 3: Implement production, employment, investment, debt, distress, and bankruptcy**

Bankruptcy after six consecutive unserviceable months. When bankrupt, 70% of employees become unemployed immediately; 30% are absorbed by healthy companies in the same region with spare capacity.

- [ ] **Step 4: Run company and integration tests**

Run: `pnpm --filter @sovereign/companies test && pnpm test`
Expected: PASS; bankruptcy never creates or deletes population.

- [ ] **Step 5: Commit**

```bash
git add packages/companies
git commit -m "feat: simulate individual company decisions and failure"
```

---

### Task 7: Population Cohorts and Employment

**Files:**
- Create: `packages/population/package.json`
- Create: `packages/population/src/employment.ts`
- Create: `packages/population/src/welfare.ts`
- Create: `packages/population/src/opinion.ts`
- Create: `packages/population/src/index.ts`
- Test: `packages/population/src/population.test.ts`

**Interfaces:**
- Consumes: cohort state, regional jobs, prices, taxes, public spending
- Produces: employment, disposable income, happiness, anger, population changes

- [ ] **Step 1: Write failing distributional policy test**

```ts
it('hurts low-income happiness more when consumption tax rises', () => {
  const result = updateCohorts(cohortFixture(), economyFixture({ consumptionTaxChange: 0.03 }));
  expect(result.lowIncome.happinessDelta).toBeLessThan(result.highIncome.happinessDelta);
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/population test`
Expected: FAIL because population system does not exist.

- [ ] **Step 3: Implement cohort employment, disposable income, welfare, happiness, and anger**

Cohorts are keyed by region × income band. Birth/death aging is intentionally deferred, but population cannot change except by explicit mortality/migration events.

- [ ] **Step 4: Run population and pipeline tests**

Run: `pnpm --filter @sovereign/population test && pnpm --filter @sovereign/simulation-core test`
Expected: PASS; employment never exceeds cohort population.

- [ ] **Step 5: Commit**

```bash
git add packages/population
git commit -m "feat: add distributional population cohorts"
```

---

### Task 8: Politics and Diplomacy

**Files:**
- Create: `packages/politics/package.json`
- Create: `packages/politics/src/support.ts`
- Create: `packages/politics/src/stability.ts`
- Create: `packages/politics/src/index.ts`
- Create: `packages/diplomacy/package.json`
- Create: `packages/diplomacy/src/relations.ts`
- Create: `packages/diplomacy/src/ai.ts`
- Create: `packages/diplomacy/src/index.ts`
- Test: `packages/politics/src/politics.test.ts`
- Test: `packages/diplomacy/src/diplomacy.test.ts`

**Interfaces:**
- Consumes: economy/population output and relation state
- Produces: support, stability, relation changes, next-turn AI commands

- [ ] **Step 1: Write failing political and diplomatic tests**

```ts
it('support falls when unemployment and inflation both rise', () => {
  const result = updatePolitics(politicsFixture(), { unemploymentDelta: 0.02, inflationDelta: 0.03 });
  expect(result.supportDelta).toBeLessThan(0);
});

it('rejects trade agreement when threat outweighs dependence and trust', () => {
  const decision = evaluateTradeProposal(relationFixture({ trust: 20, threat: 80, dependence: 10 }));
  expect(decision.accept).toBe(false);
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/politics test && pnpm --filter @sovereign/diplomacy test`
Expected: FAIL because packages do not exist.

- [ ] **Step 3: Implement bounded support/stability and explainable diplomatic AI**

Every AI decision returns `{ action, score, reasons[] }`. Relation metrics remain within 0–100 except grievance, which is also capped at 100.

- [ ] **Step 4: Run package and full replay tests**

Run: `pnpm test`
Expected: PASS; identical seeds produce identical AI decisions.

- [ ] **Step 5: Commit**

```bash
git add packages/politics packages/diplomacy
git commit -m "feat: add politics and explainable nation ai"
```

---

### Task 9: Cause Attribution and Monthly Reports

**Files:**
- Create: `packages/simulation-core/src/explanations.ts`
- Create: `packages/simulation-core/src/report.ts`
- Test: `packages/simulation-core/src/explanations.test.ts`

**Interfaces:**
- Consumes: previous state, next state, subsystem contribution records
- Produces: `MonthlyReport` with sorted cause items

- [ ] **Step 1: Write failing cause ordering test**

```ts
it('sorts inflation causes by absolute contribution', () => {
  const result = explainMetric('inflation', [
    { source: 'oil-import-price', contribution: 0.011 },
    { source: 'electricity-subsidy', contribution: -0.003 },
    { source: 'currency-depreciation', contribution: 0.008 },
  ]);
  expect(result.causes.map((item) => item.source)).toEqual([
    'oil-import-price',
    'currency-depreciation',
    'electricity-subsidy',
  ]);
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/simulation-core test`
Expected: FAIL because explanation generator does not exist.

- [ ] **Step 3: Implement contribution accumulation and Japanese text formatting**

Cause objects store machine-readable source, signed contribution, Japanese label, and detail. Do not infer causes by comparing only final states; subsystems must explicitly emit contributions.

- [ ] **Step 4: Run report and deterministic snapshot tests**

Run: `pnpm test`
Expected: PASS; reports are byte-equivalent for replayed input.

- [ ] **Step 5: Commit**

```bash
git add packages/simulation-core
git commit -m "feat: explain monthly national indicator changes"
```

---

### Task 10: Versioned Save Repository and Recovery

**Files:**
- Create: `packages/save-schema/package.json`
- Create: `packages/save-schema/src/schema.ts`
- Create: `packages/save-schema/src/checksum.ts`
- Create: `packages/save-schema/src/migrations.ts`
- Create: `packages/save-schema/src/repository.ts`
- Create: `packages/save-schema/src/index.ts`
- Test: `packages/save-schema/src/repository.test.ts`

**Interfaces:**
- Consumes: serializable `WorldState`
- Produces: `SaveRepository`, `SaveEnvelopeV1`, `exportSave`, `importSave`, `loadLatestValid`

- [ ] **Step 1: Write failing recovery test**

```ts
it('loads the previous generation when the newest save is corrupt', async () => {
  const storage = memoryStorageWithGenerations([validEnvelope(1), corruptEnvelope(2)]);
  const repo = new SaveRepository(storage);
  const loaded = await repo.loadLatestValid();
  expect(loaded.snapshot.turn).toBe(1);
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/save-schema test`
Expected: FAIL because save repository does not exist.

- [ ] **Step 3: Implement SHA-256 checksum, ten generations, migration, export/import**

Store one save before every turn advancement and every three real-time minutes while a game is open. Never delete a prior generation until the new one has been fully written and verified.

- [ ] **Step 4: Run corruption, migration, and round-trip tests**

Run: `pnpm --filter @sovereign/save-schema test`
Expected: PASS; corrupt newest save is skipped with a Japanese recovery message.

- [ ] **Step 5: Commit**

```bash
git add packages/save-schema
git commit -m "feat: add versioned resilient local saves"
```

---

### Task 11: Worker API and React Application Shell

**Files:**
- Create: `apps/web/package.json`
- Create: `apps/web/vite.config.ts`
- Create: `apps/web/index.html`
- Create: `apps/web/src/main.tsx`
- Create: `apps/web/src/app/App.tsx`
- Create: `apps/web/src/app/store.ts`
- Create: `apps/web/src/worker/protocol.ts`
- Create: `apps/web/src/worker/simulation.worker.ts`
- Create: `apps/web/src/worker/client.ts`
- Test: `apps/web/src/worker/client.test.ts`

**Interfaces:**
- Consumes: `createInitialWorld`, `advanceMonth`, `SaveRepository`
- Produces: typed messages `new-game`, `advance`, `save`, `load`; React application state

- [ ] **Step 1: Write failing worker protocol test**

```ts
it('returns a monthly result for a valid advance request', async () => {
  const worker = createInProcessWorkerHarness();
  const created = await worker.request({ type: 'new-game', playerNationId: 'nation:arcadia', seed: 'demo' });
  const advanced = await worker.request({ type: 'advance', gameId: created.gameId, months: 1, commands: [] });
  expect(advanced.type).toBe('advance-complete');
  expect(advanced.world.turn).toBe(1);
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/web test`
Expected: FAIL because the worker protocol does not exist.

- [ ] **Step 3: Implement a discriminated-union protocol and worker client**

Every request includes `requestId`; every response echoes it. Worker errors return `{ type: 'error', requestId, code, message }` and never leak raw stack traces to UI.

- [ ] **Step 4: Run worker tests and production build**

Run: `pnpm --filter @sovereign/web test && pnpm --filter @sovereign/web build`
Expected: PASS; Vite emits separate worker and app bundles.

- [ ] **Step 5: Commit**

```bash
git add apps/web
git commit -m "feat: connect react shell to simulation worker"
```

---

### Task 12: Playable Dashboard, Policies, Turn Controls, and Report

**Files:**
- Create: `apps/web/src/features/dashboard/DashboardPage.tsx`
- Create: `apps/web/src/features/dashboard/MetricCard.tsx`
- Create: `apps/web/src/features/policies/PolicyPanel.tsx`
- Create: `apps/web/src/features/turn-controls/TurnControls.tsx`
- Create: `apps/web/src/features/report/MonthlyReportPanel.tsx`
- Create: `apps/web/src/features/report/ExplanationList.tsx`
- Create: `apps/web/src/styles.css`
- Test: `apps/web/src/features/turn-controls/TurnControls.test.tsx`
- Test: `apps/web/src/features/policies/PolicyPanel.test.tsx`

**Interfaces:**
- Consumes: application store and worker client
- Produces: playable dashboard for policy edits and 1/3/6/12 month advancement

- [ ] **Step 1: Write failing interaction tests**

```tsx
it('queues a tax command and advances one month', async () => {
  render(<App />);
  await userEvent.selectOptions(screen.getByLabelText('所得税率'), '0.24');
  await userEvent.click(screen.getByRole('button', { name: '1か月進める' }));
  expect(await screen.findByText('2035年2月')).toBeInTheDocument();
  expect(screen.getByText(/所得税率の変更/)).toBeInTheDocument();
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/web test`
Expected: FAIL because feature components do not exist.

- [ ] **Step 3: Implement the dashboard**

Display exactly these primary metrics: GDP, GDP growth, CPI inflation, unemployment, treasury, debt/GDP, support, stability, trade balance, exchange rate. Policy controls: income tax, corporate tax, consumption tax, policy rate, education, healthcare, industrial subsidy.

- [ ] **Step 4: Run component tests and accessibility checks**

Run: `pnpm --filter @sovereign/web test && pnpm --filter @sovereign/web build`
Expected: PASS; all controls have visible labels and keyboard focus.

- [ ] **Step 5: Commit**

```bash
git add apps/web/src
git commit -m "feat: deliver playable national dashboard"
```

---

### Task 13: Multi-Month Advance and Crisis Auto-Stop

**Files:**
- Create: `packages/simulation-core/src/advance-many.ts`
- Create: `packages/simulation-core/src/alerts.ts`
- Modify: `apps/web/src/worker/simulation.worker.ts`
- Modify: `apps/web/src/features/turn-controls/TurnControls.tsx`
- Test: `packages/simulation-core/src/advance-many.test.ts`

**Interfaces:**
- Consumes: `advanceMonth`, alert rules
- Produces: `advanceMonths(input, count, stopRules)` with partial completion result

- [ ] **Step 1: Write failing auto-stop test**

```ts
it('stops a twelve-month run when inflation jumps by two points', () => {
  const result = advanceMonths(crisisFixture(), 12, defaultStopRules);
  expect(result.completedMonths).toBeLessThan(12);
  expect(result.stopReason?.code).toBe('inflation-shock');
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/simulation-core test`
Expected: FAIL because multi-month advancement does not exist.

- [ ] **Step 3: Implement one-month iteration with checks after every report**

Never skip intermediate months. Return all monthly summaries but retain full state only for the last completed month.

- [ ] **Step 4: Run simulation and UI tests**

Run: `pnpm test`
Expected: PASS; UI displays the exact month and reason where advancement stopped.

- [ ] **Step 5: Commit**

```bash
git add packages/simulation-core apps/web
git commit -m "feat: add safe multi-month advancement"
```

---

### Task 14: Long-Run Simulation Harness

**Files:**
- Create: `tooling/package.json`
- Create: `tooling/src/run-long-simulation.ts`
- Create: `tooling/src/write-balance-csv.ts`
- Test: `tooling/src/run-long-simulation.test.ts`

**Interfaces:**
- Consumes: seed world, full pipeline, deterministic AI
- Produces: CLI `pnpm balance --turns 1200 --seeds 100 --out artifacts/balance.csv`

- [ ] **Step 1: Write failing 1,200-turn test**

```ts
it('runs 1,200 turns without violating invariants', () => {
  const result = runLongSimulation({ turns: 1200, seed: 'long-run-1' });
  expect(result.completedTurns).toBe(1200);
  expect(result.invariantFailures).toEqual([]);
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/tooling test`
Expected: FAIL because the harness does not exist.

- [ ] **Step 3: Implement CLI and aggregate statistics**

Output per seed: final GDP, inflation, unemployment, debt/GDP, support, bankruptcies, trade agreements, crisis stops, and runtime milliseconds.

- [ ] **Step 4: Run 1,200-turn and 100-seed smoke tests**

Run: `pnpm balance --turns 1200 --seeds 10 --out artifacts/balance-smoke.csv`
Expected: exit code 0, no invariant failures, CSV exists.

- [ ] **Step 5: Commit**

```bash
git add tooling artifacts/.gitkeep
git commit -m "test: add deterministic long-run balance harness"
```

---

### Task 15: End-to-End Acceptance and Static Deployment

**Files:**
- Create: `apps/web/playwright.config.ts`
- Create: `apps/web/e2e/game-flow.spec.ts`
- Create: `apps/web/public/_headers`
- Create: `docs/deployment.md`
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: built web application
- Produces: verified static artifact `apps/web/dist`

- [ ] **Step 1: Write the end-to-end acceptance test**

```ts
import { expect, test } from '@playwright/test';

test('starts a nation, changes policy, advances, saves and reloads', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'アルカディア共和国で開始' }).click();
  await page.getByLabel('所得税率').selectOption('0.24');
  await page.getByRole('button', { name: '1か月進める' }).click();
  await expect(page.getByText('2035年2月')).toBeVisible();
  await page.getByRole('button', { name: '保存' }).click();
  await page.reload();
  await page.getByRole('button', { name: '続きから' }).click();
  await expect(page.getByText('2035年2月')).toBeVisible();
});
```

- [ ] **Step 2: Run and verify failure**

Run: `pnpm --filter @sovereign/web test:e2e`
Expected: FAIL until the complete vertical slice is wired.

- [ ] **Step 3: Complete missing UI wiring and static-host headers**

Set security headers for static hosting: CSP without remote script execution, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, and deny framing.

- [ ] **Step 4: Run the complete release gate**

Run: `pnpm lint && pnpm typecheck && pnpm test && pnpm build && pnpm test:e2e`
Expected: all commands exit 0.

- [ ] **Step 5: Commit**

```bash
git add apps/web .github docs/deployment.md
git commit -m "release: complete sovereign vertical slice acceptance"
```

---

## Plan Self-Review

### Spec coverage

- Deterministic monthly progression: Tasks 2–3
- Four-nation playable content: Task 4
- Economy, companies, population, politics, diplomacy: Tasks 5–8
- Explainable metric changes: Task 9
- Local save and recovery: Task 10
- Browser worker and UI: Tasks 11–12
- Multi-month progression and crisis stopping: Task 13
- Long-run testing: Task 14
- Public static artifact: Task 15

### Deferred to dedicated follow-up plans

These are part of the approved final scope but intentionally excluded from the first vertical slice:

1. Full 24-commodity supply chain and logistics network
2. Banking, securities, mergers, nationalization, corruption, lobbying
3. Full demographic aging, migration, religion, culture, crime, healthcare
4. Elections, parliament, legislation, constitutions, courts, bureaucracy
5. International organizations, sanctions networks, espionage
6. Military units, logistics, fronts, occupation, peace negotiations
7. Research trees, education institutions, disasters, epidemics
8. Full map, tutorial, achievements, cloud save, localization

Each deferred group receives its own spec and implementation plan after the vertical slice passes its acceptance gate.
