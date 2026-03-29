# Database Design

## Phase 1
No persistent database is implemented yet. Mock repositories and in-memory data supply the UI.

## Planned Core Tables
- `users`
- `profiles`
- `provider_services`
- `service_requests`
- `jobs`
- `job_tracking_points`
- `invoices`
- `receipts`
- `ratings`
- `messages`

## Modeling Principle
The same identity can participate as both client and provider. Role-specific data should extend the user account rather than duplicating it.
