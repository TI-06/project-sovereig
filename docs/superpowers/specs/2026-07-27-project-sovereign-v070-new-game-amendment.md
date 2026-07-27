# PROJECT SOVEREIGN v0.7 New-Game-Only Amendment

This amendment overrides the save-compatibility statements in the v0.7 political-drama design.

## Confirmed Change

- v0.7 starts from a newly created game.
- Existing v0.5, v0.6.0, v0.6.1 and v0.6.2 save data is not migrated.
- v0.7 uses schema version 2 and game version 0.7.0.
- A v0.7 save may be resumed and exported normally.
- Older or malformed save files are rejected with a clear Japanese message.
- The new-game flow requires nation, national ambition and secretary selection before creating the world.
- No compatibility branches, default-secretary fallbacks or hidden migration logic are added.

## UI Consequences

- The start screen prioritizes a new game.
- A resume button appears only when a valid v0.7 save exists.
- Import accepts only schema-version-2 v0.7 saves.
- The game-over screen does not offer loading an old-version save; it offers restart and current-version resume where applicable.
