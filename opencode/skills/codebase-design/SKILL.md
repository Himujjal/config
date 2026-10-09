---
name: codebase-design
description: Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary.
---

# Codebase Design — Deep-Module Vocabulary

Use this vocabulary whenever you design or critique a module's shape. Name the concepts explicitly so the user and other skills share terms.

## Glossary

- **Module**: A unit of code with a boundary — a file, package, service, or component that hides something behind an interface.
- **Interface**: What a module promises to callers: function signatures, types, events, config, CLI flags. The contract callers program against.
- **Implementation**: How the module keeps its promise: algorithms, data structures, I/O, internal helpers. Freely changeable as long as the interface holds.
- **Depth**: Benefit provided relative to interface cost. A deep module does a lot through a little (small interface, rich behavior). A shallow module adds interface without much benefit (pass-through wrappers, thin getters over bare data).
- **Seam**: The line where one module ends and another begins. Good seams hide volatility (things that change together stay together) and expose stability.
- **Adapter**: Translation layer at a seam — converts one interface to another (e.g. repository impl for a port, framework handler for a domain function). Adapters let the core stay framework-free.
- **Leverage**: How much work each interface element unlocks. High-leverage interfaces: one call replaces pages of caller code. Low-leverage interfaces: callers do the real work, the module just holds data.
- **Locality**: Everything needed to understand a behavior lives near that behavior. A reader (human or AI) shouldn't chase five files to follow one path.

## Deep vs shallow

Deep module — small surface, large payoff:

```
  ┌──────────────────┐
  │   parseInvoice() │  <- one function, one type in
  └────────┬─────────┘
           │  validation, OCR cleanup,
           │  tax rules, currency
           ▼  normalization hidden inside
     (rich implementation)
```

Shallow module — large surface, little payoff:

```
  ┌────────┐ ┌────────┐ ┌────────┐
  │ getA() │ │ getB() │ │ getC() │  <- three getters,
  └────────┘ └────────┘ └────────┘     caller assembles meaning
           (bare data, no behavior)
```

Prefer deepening an existing module over adding a new shallow one. Before creating a module, ask: what complexity does it hide, and what does its interface cost?

## Principles

1. **Deletion test**: If deleting the module and inlining its code at call sites would barely lose anything, the module is too shallow — inline it or deepen it.
2. **The interface is the test surface**: Tests should exercise the module through its public interface, not its internals. If you can't test behavior without mocking internals, the seam is in the wrong place.
3. **One adapter is hypothetical, two adapters are real**: Don't generalize a seam for a second implementation you don't have. Build the first adapter concretely; extract the shared port only when the second adapter actually arrives.
4. **Comments describe what the interface hides**: Document _why_ the interface looks this way and what complexity it absorbs — not what the code literally does.
5. **Push complexity down, not up**: Callers should be simple; the module earns its keep by handling edge cases, errors, and variations internally.

## Designing for testability

- **Accept dependencies, don't construct them**: Take collaborators as parameters (ports, function args, constructor injection) so tests can substitute fakes. Example: `createOrder(db, mailer, input)` beats a function that imports a singleton DB and SMTP client.
- **Return results, don't perform effects**: Prefer returning a value describing what should happen (a receipt, a list of commands/events) and letting a thin adapter execute it. Example: return `{ charge, receipt, emails }` instead of charging and emailing mid-function — the pure core is trivially testable.
- **Keep the surface small**: Fewer public functions means fewer behaviors to test and fewer ways to misuse the module. Example: one `transferFunds(from, to, amount)` with internal validation beats exposing `validateBalance`, `debitAccount`, `creditAccount`, `logLedger` separately and hoping callers sequence them correctly.

## Relationships

- Depth and testability reinforce each other: deep modules with small interfaces are the easiest to test through the public surface.
- Seams and adapters go together: every seam needs at least one adapter on the outside; ports face inward, adapters face outward.
- Leverage vs locality trade-off: centralizing behavior raises leverage but can hurt locality — keep the interface near its heaviest users.

## Rejected framings

- **"More files = cleaner"**: Splitting code without deepening modules just spreads complexity across files and hurts locality.
- **"Mock everything"**: Heavy mocking of internals signals a wrong seam — fix the interface instead of mocking around it.
- **"Generic framework first"**: Building the abstraction before two real use cases produces speculative ports. One concrete adapter first.

## Going deeper

Optional follow-ups when the design warrants more rigor:

- `DEEPENING.md` — checklist for finding deepening opportunities in an existing module (swallow helpers, absorb conditionals, merge pass-throughs).
- `DESIGN-IT-TWICE.md` — exercise that forces two competing interface sketches before committing, to compare depth and test surface side by side.

Suggest these only when the user is actively reshaping a module and would benefit from the extra pass — never required.
