# PROJECT SOVEREIGN v0.7.1-v0.7.3 Command Room, National Map, and War Room Design

## 1. Purpose

This update turns the v0.7.0 command room into the main place where the player reads the nation, makes decisions, and sees the consequences of those decisions.

The update has three sequential milestones implemented on one feature branch and delivered through one pull request:

- v0.7.1: Command Room 2.0;
- v0.7.2: domestic situation map and regional inspector;
- v0.7.3: three-phase war room.

Each milestone must remain independently testable and be committed separately.

## 2. Confirmed Direction

| Item | Decision |
|---|---|
| Home screen | The command room is the primary national decision screen |
| Navigation | Do not add permanent sidebar tabs |
| Map placement | Embed the domestic map in the center of the command room |
| Map type | Original schematic SVG regions, not a real geographic map |
| Region count | Use the existing three regions per nation |
| War experience | Automatically switch between planning, operations, settlement, and legacy |
| Player role | Choose national-level war posture, not individual unit tactics |
| Rendering | Partial DOM updates; no full-page reload per click |
| Dialogs | Use in-game overlays; never use browser `alert` or `confirm` |
| Currency | Continue the shared yen formatter from v0.7.0 |
| Dependencies | No external map, icon, image, or paid runtime service |
| Save compatibility | New-game-only release; do not migrate v0.7.0 or older saves |
| Determinism | Identical seed, state, and commands produce identical results |
| Accessibility | Color is never the only status signal; respect reduced motion |

## 3. User Experience Goals

From the command room, the player must immediately understand:

1. the three most important issues this month;
2. which region is causing or suffering from each issue;
3. what changed since last month and why;
4. the selected secretary's recommended action;
5. the current cost, posture, front status, and outlook of an active war;
6. the action that can be taken next.

The command room must feel like a game screen, not a collection of reports.

## 4. Release Scope

### v0.7.1 — Command Room 2.0

Add:

- compact national status strip;
- exactly three primary issue cards when three or more issues exist;
- one actionable secretary proposal per turn;
- accept, inspect, and decline proposal actions;
- monthly delta strip;
- direct deep links from issues to the relevant control;
- responsive desktop and mobile layout.

### v0.7.2 — Domestic Situation Map

Add:

- SVG map using the player's existing regions;
- seven map layers;
- regional status derivation;
- regional inspector;
- regional issue and action links;
- accessible severity patterns and short feedback animations.

### v0.7.3 — Three-Phase War Room

Add:

- pre-war planning view;
- active-war operations view;
- post-war settlement view;
- ongoing war-legacy view;
- strategic war posture commands;
- supply and front-status derivation;
- persistent regional war damage and economic consequences.

## 5. Command Room 2.0

### 5.1 Desktop Layout

The command room uses these areas:

1. top: national status strip and ambition;
2. center-left: priorities, secretary proposal, and monthly deltas;
3. center-right: domestic map and region inspector;
4. right rail: secretary portrait and briefing on wide screens;
5. bottom: the existing pending-command and turn dock.

The primary controls must fit common 1366 x 768 and 1920 x 1080 viewports without nested scrolling panels.

### 5.2 Mobile Layout

Below 760 px, display in this order:

1. national status strip;
2. critical issues;
3. secretary proposal;
4. domestic map;
5. region inspector;
6. monthly deltas;
7. supporting panels.

The secretary portrait becomes a compact icon. Critical warnings and turn controls remain reachable without horizontal scrolling.

### 5.3 Status Strip

Show no more than eight metrics:

- date and turn;
- treasury;
- monthly fiscal balance;
- approval;
- growth;
- unemployment;
- highest survival risk;
- ambition progress.

Each metric includes a favorable, unfavorable, or neutral direction derived from the previous completed turn.

## 6. Monthly Priorities

Create `src/gameplay/monthly-priorities.ts`.

```ts
export interface MonthlyPriority {
  id: string;
  category: 'fiscal' | 'economy' | 'employment' | 'welfare' | 'security' | 'war' | 'event' | 'ambition';
  severity: 'normal' | 'warning' | 'danger' | 'critical';
  title: string;
  currentLabel: string;
  consequence: string;
  deadlineMonths: number | null;
  regionId: RegionId | null;
  recommendedAction: PriorityActionLink;
  evidence: Array<{ label: string; value: string }>;
}

export interface PriorityActionLink {
  tab: TabId;
  section?: ProjectSection;
  targetId?: string;
  label: string;
}
```

`getMonthlyPriorities(world)` returns at most three results.

Deterministic precedence:

1. pending last-chance decision;
2. survival risk at 90 or above;
3. active-war capital or supply emergency;
4. required event expiring this turn;
5. survival risk at 70 or above;
6. existing priority issues;
7. required event with a later deadline;
8. severe regional issue;
9. opportunity event;
10. ambition opportunity.

Ties use stable category and ID ordering. No random ranking is allowed.

Each card shows the condition, consequence, deadline, recommended action, and optional related region. Action links open the existing tab or project section and highlight the target control. Region links select the region without leaving the command room.

## 7. Secretary Proposal

At most one actionable proposal is generated per turn.

```ts
export interface SecretaryProposal {
  id: string;
  secretaryId: SecretaryId;
  priorityId: string;
  headline: string;
  rationale: string;
  expectedBenefit: string;
  expectedCost: string;
  command: PlayerCommand | null;
  actionLink: PriorityActionLink;
  status: 'new' | 'accepted' | 'declined' | 'inspected';
  createdTurn: number;
}
```

- Accept queues the command when possible, otherwise opens the recommended control.
- Inspect opens an in-game detail overlay with evidence and side effects.
- Decline records the decision and shows a short character reaction.

Declining does not automatically reduce trust. Existing major-decision trust rules remain authoritative.

Store only the latest proposal status and the most recent 24 proposal decisions. Do not store generated HTML or redundant metric data.

## 8. Monthly Delta Strip

Store a compact previous-turn player snapshot:

```ts
export interface MonthlyMetricSnapshot {
  turn: number;
  treasury: number;
  monthlyBalance: number;
  approval: number;
  growthRate: number;
  inflation: number;
  unemployment: number;
  tradeBalance: number;
  stability: number;
}
```

Display at most six changes, sorted by normalized significance. Each item shows label, signed value, status, and a cause button when turn-contribution data exists. Cause buttons open the existing turn explanation overlay.

## 9. Domestic Situation Map

Create:

- `src/gameplay/regional-status.ts`;
- `src/ui/national-map-view.ts`;
- `src/ui/region-inspector.ts`.

### 9.1 Geometry

Use the existing three regions per nation. Map them to a stable nation-specific three-zone SVG template.

Every region is a focusable SVG path with `data-region-id`. Boundaries remain visible. Desktop labels must be readable; mobile may hide labels and rely on the inspector title. No map tiles or geographic data are loaded.

### 9.2 Layers

```ts
export type NationalMapLayer =
  | 'overview'
  | 'economy'
  | 'employment'
  | 'people'
  | 'infrastructure'
  | 'resources'
  | 'crisis';
```

| Layer | Inputs |
|---|---|
| Overview | Highest regional severity |
| Economy | Company profit, distress, capacity, business confidence |
| Employment | Employment, population cohorts, unemployment pressure |
| People | Happiness, anger, approval pressure, stability |
| Infrastructure | Infrastructure, healthcare, education |
| Resources | Resource type, abundance, stock pressure, production relevance |
| Crisis | Active crises and public-service stress |

### 9.3 Regional Derivation

`deriveRegionalStatus(world, regionId)` returns a non-mutating view model with scores from 0 to 100:

```ts
export interface RegionalStatus {
  regionId: RegionId;
  name: string;
  population: number;
  dominantIndustry: string;
  economyScore: number;
  employmentScore: number;
  peopleScore: number;
  infrastructureScore: number;
  resourceScore: number;
  crisisScore: number;
  overallSeverity: 'stable' | 'watch' | 'warning' | 'critical';
  issues: RegionalIssue[];
  actionLinks: PriorityActionLink[];
  badges: RegionalBadge[];
}
```

Use existing region, company, population cohort, commodity, crisis, project, and war data. Derived scores are never duplicated in save data.

Initial regional issues:

- company distress;
- employment pressure;
- low happiness;
- high anger;
- weak infrastructure;
- weak healthcare;
- weak education;
- resource shortage;
- active crisis;
- war damage.

Do not add regional taxes or separate regional budgets.

### 9.4 Region Inspector

Show:

- name and population;
- dominant industry;
- six dimension scores;
- resource;
- distressed and bankrupt company count;
- active project and crisis badges;
- up to three issues;
- up to three action buttons.

Selected region, layer, and expanded-map state are UI-only state and are not saved.

### 9.5 Visual Language

Use fill, pattern, label, and icon together:

- stable: calm fill and check pattern;
- watch: muted fill and dot pattern;
- warning: amber fill and diagonal pattern;
- critical: red fill and warning icon;
- project: construction badge;
- resource: resource icon;
- crisis: one-time severity pulse;
- war: front-line overlay.

Reduced-motion mode removes pulsing and uses immediate state changes.

## 10. War Room

Create:

- `src/gameplay/war-operations.ts`;
- `src/ui/war-room-view.ts`.

### 10.1 Phase Resolution

```ts
export type WarRoomPhase = 'planning' | 'operations' | 'settlement' | 'legacy';
```

- planning: no active player war and no pending settlement;
- operations: an active war includes the player;
- settlement: `world.narrative.pendingWarSettlement` exists;
- legacy: no active war and ongoing war-legacy effects exist.

Only one player war is controlled at a time in v0.7.3. Non-player wars continue normally.

### 10.2 Planning Phase

Keep the existing declaration preview authoritative. Show opponent, objective, monthly cost, duration, casualties, international penalty, domestic support effect, rewards, secretary opinion, survival-risk interaction, and a game confirmation overlay.

### 10.3 Strategic Posture

```ts
export type WarPosture = 'conserve' | 'balanced' | 'breakthrough';
```

| Posture | Score progress | Casualties | Cost | Supply pressure |
|---|---:|---:|---:|---:|
| Conserve | 0.75x | 0.70x | 0.80x | 0.75x |
| Balanced | 1.00x | 1.00x | 1.00x | 1.00x |
| Breakthrough | 1.30x | 1.35x | 1.25x | 1.35x |

Multipliers apply only to the player's side. Existing secretary modifiers and seeded RNG still apply. Changes take effect in the next military update.

Add to `WarState`:

```ts
playerPosture: WarPosture;
playerPostureChangedTurn: number;
```

### 10.4 Front Supply and Damage

Extend `WarFrontState`:

```ts
export interface WarFrontState {
  id: string;
  regionId: RegionId;
  attackerControl: number;
  intensity: number;
  supply: number;
  monthlyCasualties: number;
  damage: number;
}
```

New fronts start with supply 70, casualties 0, and damage 0.

Supply uses logistics, equipment, readiness, intensity, posture, regional infrastructure, exhaustion, and active resource/trade benefits. It remains bounded from 0 to 100 and is saved because it influences subsequent combat.

High damage to a player region creates a post-war regional issue and reduces infrastructure once when war ends. Recovery uses existing public works and fiscal systems.

### 10.5 Operations View

Show:

- war title and objective;
- attacker and defender score;
- predicted state;
- total cost and casualties;
- player exhaustion;
- current posture;
- each front's control, intensity, supply, casualties, damage, and status;
- posture controls;
- peace action;
- capital and survival warnings.

Do not expose units, battalions, target selection, or tactical placement.

### 10.6 Settlement View

Keep existing settlement logic authoritative. Show outcome, duration, total cost, casualties, approval and reputation changes, rewards, stance, governance, projected monthly net benefit, and resistance. Confirmation uses an in-game overlay.

### 10.7 Legacy View

When war ends, show active resource rights, trade route duration, territory tax bonus, client-state influence, occupation resistance, gross benefit, occupation cost, net benefit, and recent war record.

The command room shows a compact legacy card only while ongoing effects exist.

## 11. State and Save Rules

Add to `NarrativeState`:

```ts
export interface CommandRoomState {
  latestProposalId: string | null;
  proposalHistory: Array<{
    proposalId: string;
    turn: number;
    status: 'accepted' | 'declined' | 'inspected';
  }>;
  previousMetrics: MonthlyMetricSnapshot | null;
}
```

The game version becomes `0.7.3`. The loader accepts only v0.7.3 saves. v0.7.0 and older saves are rejected with a clear Japanese message. Do not add migration code or migration tests. Schema version remains 2 because this is a clean new-game schema.

## 12. UI Boundaries and Partial Rendering

Create `src/ui/command-center-v2.ts` as the composition layer. Existing `command-center-view.ts` becomes a compatibility re-export or is removed after all callers move.

Add controller actions for:

- `data-map-layer`;
- `data-region-id`;
- `data-region-action`;
- `data-secretary-proposal-action`;
- `data-war-posture`;
- `data-war-room-action`;
- deep-link target highlighting.

UI-only state:

```ts
interface CommandRoomUiState {
  mapLayer: NationalMapLayer;
  selectedRegionId: RegionId | null;
  mapExpanded: boolean;
  proposalOverlayOpen: boolean;
}
```

Update only the affected map, inspector, proposal, or war-room region. Never reconstruct the full application shell for these interactions.

## 13. Error Handling

- Missing selected region: select the first player region.
- Missing front region: omit that front card and emit a development-only warning.
- Invalid proposal command: open its action link and show a non-blocking message.
- No valid war target: disable confirmation and explain the cause.
- Invalid posture in imported JSON: reject the save as invalid v0.7.3 data.
- More than one active player war: render the oldest active player war and show a data warning.

All player-visible failures use the status region or game overlay. Browser dialogs are prohibited.

## 14. Testing

### Unit

Test:

- deterministic priority ranking and three-card limit;
- secretary proposal generation and actions;
- monthly snapshots and signed deltas;
- regional scores, thresholds, action links, and all seven layers;
- posture multipliers;
- supply boundaries;
- front and prediction labels;
- legacy net benefit;
- v0.7.3 save validation and rejection of earlier versions.

### Integration

Test:

- issue deep links;
- region selection and inspector rendering;
- proposal acceptance queueing a command;
- posture taking effect next turn;
- posture affecting progress, cost, casualties, and supply;
- planning to operations to settlement to legacy transition;
- front damage creating a regional issue;
- save and reload preserving posture and front state;
- identical seed and commands producing identical results.

### UI Contracts

Assert:

- status strip;
- three priority cards maximum;
- proposal controls;
- delta strip;
- map layers and region paths;
- inspector;
- posture controls and front cards;
- settlement and legacy summaries;
- yen-formatted money;
- no new permanent navigation tab;
- no shipped `alert(` or `confirm(`.

### Chromium E2E

Desktop:

1. reach Command Room 2.0;
2. open an issue deep link;
3. inspect and accept a proposal;
4. switch seven map layers;
5. select each region and use a regional action;
6. expand and collapse the map;
7. declare war;
8. change posture;
9. offer peace;
10. complete settlement and inspect legacy;
11. save and reload v0.7.3 state.

Mobile:

1. issue, proposal, map, inspector, and turn dock remain reachable;
2. map regions are tappable;
3. posture controls do not overflow;
4. no nested horizontal scrolling.

### Long Run

- 120-month peaceful determinism;
- 1,200-turn durability;
- prolonged conserve war remains finite and non-negative;
- breakthrough produces higher average progress, cost, and casualties than balanced under the same seed;
- regional scores remain 0-100;
- legacy income and costs expire correctly.

## 15. Acceptance Criteria

The update is complete when:

1. the command room shows three priorities, one proposal, monthly deltas, map, and inspector;
2. issue and region actions reach the relevant control directly;
3. all seven map layers use existing game data;
4. the war room automatically shows planning, operations, settlement, or legacy;
5. posture deterministically changes progress, cost, casualties, and supply;
6. war damage remains bounded and visible regionally;
7. v0.7.3 saves preserve the new state;
8. v0.7.0 and older saves are rejected without migration;
9. desktop and mobile E2E pass;
10. tests, typecheck, build, and deployment verification pass;
11. one PR delivers milestone commits for v0.7.1, v0.7.2, and v0.7.3.

## 16. Non-Goals

Do not add:

- a real geographic map;
- map zoom/pan libraries;
- tactical unit placement;
- generals, battalions, or unit micromanagement;
- separate regional tax and budget systems;
- a full foreign-territory administration screen;
- multiplayer;
- runtime AI advice;
- additional permanent sidebar tabs.
