# PROJECT SOVEREIGN v0.7 Political Drama Update Design

## 1. Purpose

v0.7 changes PROJECT SOVEREIGN from a nation-management dashboard into a game with a clear emotional and strategic loop.

The player must understand:

- who is accompanying them;
- what the nation is trying to achieve;
- how close the administration is to collapse;
- why a war is being fought;
- what was gained or lost by victory;
- what kind of leader the player became.

The update keeps the existing deterministic economy, policy, event, diplomacy and war simulation. It adds presentation, consequences and character-driven decisions around those systems instead of replacing them with a separate tactical game.

## 2. Confirmed Product Direction

| Item | Decision |
|---|---|
| Main direction | Political drama plus national strategy |
| Visual tone | Slightly pop, approachable and game-like |
| Secretary system | Select one of three secretaries at game start |
| Character balance | Two women and one man |
| Character presentation | Upper-body portrait plus small circular icon |
| Money scale | Internal `1B` equals `10億円` |
| Runtime dependency | No external image or icon service required |
| Save compatibility | Existing v0.5-v0.6.2 saves must migrate automatically |
| Simulation style | Deterministic and explainable |

## 3. Core Game Loop

The v0.7 monthly loop is:

1. The selected secretary delivers a monthly briefing.
2. The player sees the national ambition, current threats and game-over risks.
3. The player chooses policy, project, diplomacy, event and war decisions.
4. The secretary and ministers react before the turn is confirmed.
5. The turn resolves using the existing simulation.
6. Results show gains, losses, causes, character reactions and progress toward the ending.
7. New story events, relationship events or last-chance crises may open.

The player must always have a visible answer to these questions:

- What should I decide now?
- What happens if I ignore it?
- What did my last decision achieve?
- How close am I to winning or losing?

## 4. New Game Setup

A new game begins with two decisions.

### 4.1 National Ambition

The player selects one long-term ambition. It provides a visible goal and ending route but does not prevent other endings.

| ID | Name | Primary victory conditions |
|---|---|---|
| `economic_power` | 経済大国 | High GDP, positive fiscal balance, strong companies and trade surplus |
| `welfare_state` | 福祉国家 | High approval, low unemployment, stable prices and strong public services |
| `diplomatic_union` | 外交連邦 | Multiple alliances, strong international reputation and sustained peace |
| `military_hegemony` | 軍事覇権 | High military readiness, successful wars and strategic influence |
| `survival_50_years` | 国家存続50年 | Avoid collapse and retain government for 600 turns |

The command room shows a compact progress meter and the next unmet requirement.

### 4.2 Secretary Selection

The player chooses one secretary. The choice changes advice, dialogue, relationship events and one balanced gameplay trait.

#### A. 九条 澪 — Chief Secretary

- Gender: woman
- Personality: calm, precise and responsible
- Specialty: fiscal management, domestic policy and crisis control
- Strength: fiscal and game-over forecasts show one additional month of detail
- Gameplay effect: emergency domestic measures cost 5% less
- Drawback: diplomatic relationship gains are 5% smaller
- Dialogue style: factual, restrained, gradually emotional under severe pressure

#### B. 天城 ひなた — Diplomatic Secretary

- Gender: woman
- Personality: bright, socially perceptive and persuasive
- Specialty: diplomacy, trade and public support
- Strength: trade agreement and relationship gains are 8% larger
- Gameplay effect: international reputation penalties recover 5% faster
- Drawback: military emergency measures cost 5% more
- Dialogue style: conversational, optimistic and direct when trust is high

#### C. 黒崎 蓮 — Strategic Secretary

- Gender: man
- Personality: assertive, competitive and pragmatic
- Specialty: military affairs, national security and emergency response
- Strength: military readiness recovers 8% faster outside active war
- Gameplay effect: defensive war morale loss is 10% smaller
- Drawback: welfare-policy approval gains are 5% smaller
- Dialogue style: blunt, challenging and quietly loyal

These effects must be small enough that no secretary is the universally correct choice.

## 5. Secretary Relationship System

Each save stores:

- selected secretary ID;
- trust from 0 to 100;
- stress from 0 to 100;
- unlocked relationship events;
- viewed dialogue flags.

### 5.1 Trust

Trust changes through major decisions, not every minor numeric adjustment.

Examples:

- following urgent advice: `+2`;
- resolving a secretary-specific crisis: `+3`;
- repeatedly ignoring critical warnings: `-2`;
- breaking a publicly stated promise: `-4`;
- protecting the nation at personal political cost: `+4`.

Trust levels:

| Range | State | Behaviour |
|---|---|---|
| 0-19 | Distrust | Minimal advice, resignation or disclosure events possible |
| 20-39 | Distant | Formal dialogue, no personal events |
| 40-69 | Professional | Standard advice and normal reactions |
| 70-89 | Trusted | Additional warnings and personal dialogue |
| 90-100 | Absolute trust | Secret events and special ending conditions |

### 5.2 Stress

Stress rises when several severe crises are active, the nation is at war or collapse clocks advance. It falls during stable months.

Stress only changes expression and dialogue frequency in v0.7. It must not create hidden random penalties.

### 5.3 Expressions and Assets

Each secretary has five upper-body expressions:

- normal;
- pleased;
- worried;
- shocked;
- angry.

Each also has one small icon used in event lists, history and compact layouts.

Asset requirements:

- original characters;
- transparent background;
- consistent camera angle, lighting and costume language;
- slightly pop political-strategy style;
- readable at 96 px and 320 px;
- no embedded text;
- WebP primary format and PNG fallback;
- generated and refined through image-generation and design tooling, then stored locally in the repository.

## 6. Command Room Redesign

The command room becomes the emotional and strategic home screen.

### 6.1 Desktop Layout

- Left and center: national state, actions, events and risks.
- Right: secretary portrait and dialogue panel.
- Header: current ambition, year/month, treasury in yen and administration survival status.
- Lower region: pending orders and turn button.

The portrait must not cover controls or force an internal page scroll at common desktop sizes.

### 6.2 Compact Layout

At narrow widths:

- portrait becomes a small icon;
- dialogue becomes a collapsible briefing strip;
- all critical warnings remain visible without opening the portrait panel.

### 6.3 Secretary Briefing

The briefing contains at most three sections:

1. Most urgent threat.
2. Best opportunity.
3. One recommended action.

Example:

> 大統領、国庫は現在420億円です。このままでは4か月後に追加借入が必要です。今月は軍事計画の延期か、法人税の一時調整を優先してください。

The briefing must cite the source metrics used to generate it. Advice is deterministic and must not call an external AI service.

## 7. Game-Over and Survival Risk System

Game-over conditions must be visible before they trigger. Each failure route has a risk meter, a persistence clock and a last-chance event.

### 7.1 Failure Routes

#### Fiscal Default

Triggered when all conditions persist for three consecutive turns:

- treasury is zero or negative;
- borrowing capacity is exhausted;
- monthly operating balance remains negative.

#### Government Collapse

Triggered when both conditions persist for three consecutive turns:

- approval is below 15;
- political stability is below 20.

#### Military Coup

Triggered when all conditions persist for two consecutive turns:

- military loyalty is below 20;
- political stability is below 25;
- domestic unrest is above 75.

#### War Defeat

Triggered immediately when either condition is met during an active war:

- capital control reaches zero;
- military readiness is 5 or lower while enemy occupation is 70 or higher.

#### State Collapse

Triggered when at least three of the following remain critical for two consecutive turns:

- treasury below zero;
- food security below 15;
- stability below 15;
- infrastructure function below 20;
- government legitimacy below 15.

### 7.2 Risk Presentation

The UI shows:

- risk name;
- current risk percentage;
- number of months before failure;
- exact causes;
- available recovery actions;
- the metric that must recover to stop the clock.

Risk stages:

- 0-39: stable;
- 40-69: warning;
- 70-89: emergency;
- 90-99: final warning;
- 100: game over.

The percentage is presentation derived from current thresholds and persistence. It is not a separate random value.

### 7.3 Last-Chance Event

Before fiscal default, government collapse, coup or state collapse, one final event appears. It offers two or three costly but valid rescue choices. The player may also accept defeat.

Examples:

- emergency international loan;
- national unity cabinet;
- concessions to military leadership;
- temporary rationing and emergency powers.

Last-chance choices must carry long-term penalties, so they are not optimal routine actions.

### 7.4 Game-Over Screen

The final screen shows:

- failure route;
- date and years governed;
- the three decisions that most contributed;
- the secretary's final dialogue;
- national statistics;
- restart, load previous save and view history actions.

## 8. War Purpose, Rewards and Consequences

The existing war simulation remains the source of military victory or defeat. v0.7 adds a purpose before war and a peace settlement after victory.

### 8.1 War Objectives

The player must choose one objective before declaring an offensive war.

| Objective | Main reward | Main risk |
|---|---|---|
| `defend_ally` | Alliance trust, prestige and limited reparations | War cost with limited economic return |
| `secure_resources` | Temporary resource-production rights | International reputation loss and resistance |
| `open_trade_route` | Trade-income bonus and lower shipping cost | Benefit depends on future trade volume |
| `territorial_expansion` | Territory, population and tax base | Occupation cost, unrest and diplomatic penalty |
| `regime_change` | Friendly government and strategic influence | High war cost and unstable post-war government |

Defensive wars automatically use `national_defense` and do not require an objective selection.

### 8.2 War Declaration Preview

Before confirmation the player sees:

- war objective;
- expected monthly cost in yen;
- estimated duration range;
- expected casualties range;
- likely diplomatic reaction;
- possible rewards;
- secretary and relevant minister opinion.

The preview uses current military and diplomatic metrics. It is explicitly an estimate, not a guarantee.

### 8.3 Victory Report

A victory report separates rewards and costs.

Example:

```text
戦争に勝利しました

獲得
・北部資源地域の採掘権：24か月
・石油生産量：+24%
・賠償金：380億円
・国威：+18

代償
・戦費：640億円
・戦死者：12,840人
・国際評価：-11
・占領地域の反乱危険度：34%
```

### 8.4 Peace Settlement

After victory the player selects one settlement:

- Lenient: smaller rewards, lower backlash and faster reputation recovery.
- Balanced: standard rewards and standard occupation risk.
- Harsh: larger immediate rewards, high resistance and future retaliation risk.

For territorial expansion, the settlement also selects governance:

- direct rule;
- autonomous administration;
- client state;
- resource rights only;
- return territory for diplomatic concessions.

v0.7 does not add tactical unit control or a full geographic conquest map. Those remain future scope.

## 9. Victory Conditions and Endings

### 9.1 Ambition Victory

An ambition ending becomes available when all primary conditions remain satisfied for 12 consecutive turns. The player may end the game or continue in free play.

### 9.2 Performance Endings

The final ending also considers the player's complete record.

Main endings:

- 奇跡の経済改革者;
- 国民に愛された大統領;
- 平和を築いた連邦の父／母;
- 世界を震わせた覇権者;
- 鉄血の独裁者;
- 50年を守り抜いた国家元首.

Hidden endings:

- 秘書だけが最後まで残った政権;
- 戦争を一度も起こさず大国化;
- 崩壊寸前から三度国家を救済.

An ending screen contains:

- ending illustration or character composition;
- title and narrative summary;
- secretary relationship result;
- major achievements;
- failures and sacrifices;
- score breakdown;
- shareable text summary without automatic posting.

## 10. Japanese Yen Display

### 10.1 Scale

Internal values remain unchanged.

- `1B = 10億円 = 1,000,000,000円`.

### 10.2 Common Formatter

All visible monetary values must use one formatter with the conceptual interface:

```ts
formatYenFromB(valueB: number, options?: {
  signed?: boolean;
  compact?: boolean;
  maximumFractionDigits?: number;
}): string
```

Rules:

- zero: `0円`;
- absolute value below `0.1B`: show in `万円`;
- `0.1B` through below `1000B`: show in `億円`;
- `1000B` and above: show in `兆円`;
- preserve negative signs;
- use Japanese thousands separators;
- avoid meaningless decimal digits;
- full values appear in a tooltip or detail label when compact formatting rounds a value.

Examples:

| Internal value | Display |
|---:|---:|
| `0` | `0円` |
| `0.001B` | `100万円` |
| `0.8B` | `8億円` |
| `8B` | `80億円` |
| `120B` | `1,200億円` |
| `1000B` | `1兆円` |
| `1250B` | `1.25兆円` |
| `-6.4B` | `-64億円` |

### 10.3 Covered Values

The formatter must cover:

- treasury;
- national budget;
- revenue and expenditure;
- debt and borrowing capacity;
- trade values;
- war cost and reparations;
- company revenue, value and support;
- projects and policy costs;
- event rewards and penalties;
- turn-result comparisons;
- historical records and tooltips.

No player-facing `B` suffix may remain for money. Non-money scientific or quantity units may retain their existing notation.

## 11. Icon and Visual System

### 11.1 Principles

- slightly rounded and friendly;
- readable at small sizes;
- consistent stroke and silhouette;
- category meaning must not depend on colour alone;
- no emoji as permanent production icons;
- no runtime network dependency.

### 11.2 Categories

| Category | Motif |
|---|---|
| Finance | coin and treasury building |
| Economy | factory and upward graph |
| Diplomacy | handshake and globe |
| Military | shield and crossed insignia |
| Public life | people and home |
| Crisis | warning triangle with category symbol |
| War victory | laurel and flag |
| Game-over risk | broken state crest |
| Character trust | linked stars or ribbon |
| Ending progress | crown or national emblem |

### 11.3 Production Workflow

- Use image-generation tooling for the three original character portrait sets.
- Use Canva or equivalent design tooling to refine composition, crop, background transparency and export sizes.
- Use a coherent SVG icon family for functional UI icons; customise only when a project-specific symbol is required.
- Store all final assets in the repository and document source and usage.
- Generate a contact sheet for visual review before integration.
- Check every icon in light and dark appearance and at 16, 20, 24 and 32 px.

## 12. Data Model and Migration

The save schema advances to v0.7 and adds:

```ts
interface PoliticalDramaState {
  nationalAmbitionId: NationalAmbitionId;
  selectedSecretaryId: SecretaryId;
  secretaryTrust: number;
  secretaryStress: number;
  unlockedSecretaryEvents: string[];
  gameOverClocks: Record<GameOverRoute, number>;
  warRecords: WarRecord[];
  activeOccupationEffects: OccupationEffect[];
  endingProgress: Record<EndingId, number>;
  unlockedEndings: EndingId[];
}
```

Migration rules for existing saves:

- do not change any existing economic or political values;
- set ambition to `survival_50_years` until the player chooses another goal;
- pause before the next turn and request a secretary selection;
- initialise trust at 50 and stress from current crisis severity;
- derive game-over clocks from current state but start persistence at zero;
- preserve all history and current wars;
- do not game-over an old save on the first migrated turn.

## 13. Module Boundaries

Proposed focused units:

- `src/format/yen.ts`: all money formatting;
- `src/gameplay/secretaries.ts`: profiles, traits, trust and stress changes;
- `src/gameplay/briefing.ts`: deterministic briefing view model;
- `src/gameplay/game-over.ts`: risk calculation, clocks and final conditions;
- `src/gameplay/war-objectives.ts`: objective selection and preview;
- `src/gameplay/war-settlement.ts`: victory rewards, costs and post-war effects;
- `src/gameplay/endings.ts`: ambition progress and ending resolution;
- `src/ui/secretary-presenter.ts`: portrait, dialogue and expression selection;
- `src/ui/icon-registry.ts`: stable semantic icon mapping;
- `src/persistence/migrations/v07.ts`: save migration.

Existing simulation modules remain authoritative for fiscal, diplomatic, military and market calculations. New modules consume their outputs and apply explicit v0.7 effects through typed commands.

## 14. Error Handling and Safety Rules

- Missing portrait asset: show the secretary icon and continue.
- Unknown secretary ID in a save: migrate to 九条 澪 and record a migration warning.
- Invalid war objective: block declaration and show a clear error.
- Victory without a stored objective: treat as defensive victory for migrated saves.
- Formatting a non-finite value: return `—` and log a development warning.
- Multiple game-over routes at once: choose the route with the highest risk, then the longest persistence, while listing all contributing failures.
- No external AI, image or icon call is made while the game runs.

## 15. Testing Strategy

### 15.1 Unit Tests

- yen formatting boundaries and negative values;
- each secretary trait and drawback;
- trust changes and clamping;
- deterministic briefing selection;
- all game-over thresholds and persistence resets;
- last-chance event creation;
- all war-objective rewards and settlement trade-offs;
- ending eligibility and 12-turn persistence;
- v0.6.2 save migration.

### 15.2 Integration Tests

- secretary selection persists after reload;
- command-room briefing reflects current metrics;
- game-over warning links to valid recovery actions;
- war objective flows from declaration to victory report and settlement;
- money displays in yen across command room, turn result and company screens;
- detailed policy values are not overwritten by secretary recommendations.

### 15.3 E2E Tests

- new game: ambition and secretary selection;
- old save: migration and secretary prompt;
- fiscal collapse countdown and rescue;
- government collapse game-over;
- war declaration, victory reward and peace settlement;
- ambition victory and free-play continuation;
- responsive portrait presentation;
- missing image fallback;
- no remaining player-facing monetary `B` suffix.

### 15.4 Balance and Durability

- preserve the existing 1,200-turn invariant test;
- run at least one 600-turn scenario per ambition;
- run severe-crisis recovery scenarios with each secretary;
- verify no secretary produces more than a 10% long-term score advantage under equivalent decisions;
- verify harsh peace settlements produce meaningful delayed costs;
- verify old 2047 saves cannot immediately trigger game over after migration.

## 16. Release and Repository Strategy

v0.7 follows the repository's verified reconstruction model:

1. Reconstruct v0.6.2 source.
2. Apply the v0.7 patch.
3. Verify package version.
4. Run automated tests, type checking and static build.
5. Run deployment marker inspection.
6. Export reconstructed source, build log and deployment artifact.
7. Merge only after GitHub Actions succeeds.

Character and icon assets are included in the release patch or release asset structure and must be reproducible from the documented source files.

## 17. Acceptance Criteria

v0.7 is accepted when:

- a player selects one of three visibly distinct secretaries;
- the secretary appears and reacts in the command room;
- the player always sees major game-over risks and time remaining;
- every game-over route has a visible warning and last-chance path;
- offensive wars require a purpose;
- victory clearly lists gains and costs in yen;
- peace settlement choices create different future consequences;
- at least five ambition/performance endings are reachable;
- all monetary UI uses yen with `1B = 10億円`;
- functional icons and character assets are visually coherent;
- existing saves migrate without losing data;
- the full verification pipeline passes.

## 18. Explicit Non-Goals for v0.7

- tactical battlefield control;
- freehand world-map conquest;
- real-time combat;
- voice acting;
- animated Live2D characters;
- generative dialogue at runtime;
- multiplayer;
- more than three selectable secretaries;
- a full cabinet-management simulation.

These exclusions keep v0.7 focused on adding emotional stakes, readable failure, meaningful victory and character attachment to the existing nation simulation.