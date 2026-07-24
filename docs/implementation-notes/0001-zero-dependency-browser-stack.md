# ADR 0001: Standards-only browser stack for the vertical slice

The first playable version uses TypeScript and browser standards without runtime libraries.
The package registry is not available in the implementation environment, and Replit is not used.
The deterministic simulation, worker boundary, persistence boundary, and UI boundary remain independent.
A later React migration can replace only `src/ui` without changing the simulation APIs or save schema.
