# Architecture

## Chosen Style
The project is structured around clean architecture boundaries:

- `presentation`: screens, widgets, navigation, Riverpod UI state
- `domain`: business entities and use cases to be introduced as features mature
- `data`: repository implementations, DTOs, and API/local persistence adapters

## Phase 1 Implementation
- `lib/app`: app bootstrap, route table, shared application providers
- `lib/core`: constants, theme, and reusable utilities
- `lib/features`: feature-first modules with presentation entry points
- `lib/shared_widgets`: reusable UI building blocks
- `lib/models` and `lib/repositories`: transitional cross-feature primitives for mock scaffolding

## Why This Holds Up
Phase 1 intentionally keeps infrastructure thin while preserving seams for expansion. Routes, visual tokens, and app state are centralized, which reduces churn when later phases add domain logic and repository-backed flows.
