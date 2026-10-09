---
name: domain-modeling
description: Build and sharpen a project's domain model (GLOSSARY.md + ADRs).
---

Build and maintain the project's shared language alongside design work.

- Lazily create `GLOSSARY.md` at the repo root on the first resolved term — don't scaffold it before there's language worth capturing.
- Update it inline as each term gets resolved during grilling or design; one short entry per term (name, meaning, what's explicitly out of scope).
- Keep implementation details out of the glossary — it records domain language, not function names or file layouts.
- Offer an ADR (Architecture Decision Record) only when a decision is hard-to-reverse AND surprising AND involves a real trade-off. Otherwise the glossary entry plus conversation history is enough.
