# Backend Next Steps

## Short Answer
Yes, you need a backend for this product if you want real users, providers, bookings, tracking, OTP, and payments to work across devices.

Yes, a separate backend project is the better choice.

For this app, the recommended setup is:
- frontend: this Flutter project
- backend: a separate `.NET` project
- database: `PostgreSQL`
- cache: `Redis`

## Why You Need A Backend
This Flutter project is the client application. It handles:
- screens
- navigation
- local UI state
- form input
- map presentation

But it should not be the system of record for:
- user accounts
- provider accounts
- schedules
- service requests
- job status
- tracking updates
- payments
- notifications

Without a backend:
- data only lives on one device
- clients and providers cannot share the same live request state
- OTP verification is insecure or impossible to manage correctly
- payment logic cannot be trusted
- tracking history and audit data are not centralized

The frontend is the interface. The backend is the shared business system.

## Why A Separate Backend Project Is Better
You can technically put backend code beside this project, but a separate backend project is cleaner.

Recommended approach:
- keep this repo for Flutter
- create a separate repo for the API/backend

Why this is better:
- Flutter and `.NET` have different build systems, dependencies, tooling, and deployment pipelines
- backend release cycles are usually different from mobile/web UI release cycles
- testing is cleaner when frontend and backend responsibilities are split
- CI/CD is easier to reason about
- the backend may later serve other clients beyond this Flutter app
- team collaboration is simpler when the API has its own boundary

## Recommended Repository Setup

### Option 1: Separate Repositories
Best choice.

Example:

```text
wirasasa-mobile/
  lib/
  android/
  ios/
  web/
  docs/

wirasasa-backend/
  src/
  tests/
  docs/
```

Use this if:
- you want clear ownership
- you expect the backend to grow
- you may add admin panels, partner APIs, or provider dashboards later

### Option 2: Monorepo
Acceptable, but not my first recommendation here.

Example:

```text
wirasasa/
  mobile/
  backend/
  docs/
```

Use this if:
- one small team manages everything
- you want one repository for all work

Avoid mixing the `.NET` backend directly inside the current Flutter source structure.

## Final Recommendation
Use another project for the backend.

That means:
- keep `/home/bett/Wirasasa` as the Flutter client app
- create a new backend project such as `wirasasa-backend`

## Recommended Backend Stack
- `ASP.NET Core Web API`
- `Entity Framework Core`
- `PostgreSQL`
- `Redis`
- OpenAPI / Swagger
- background jobs with hosted services first
- `SignalR` later for real-time tracking if needed

## Why .NET Is A Good Fit
- strong for API development
- strong authentication and authorization support
- good background processing support
- mature database ecosystem
- easy OpenAPI generation
- good long-term maintainability for business systems

## Recommended Database
Use `PostgreSQL`.

Why:
- your domain is relational
- bookings, jobs, payments, and tracking history fit well in relational tables
- PostgreSQL works very well with `.NET`
- it scales well enough for this product type
- you can later use `PostGIS` for geospatial queries

## Database Comparison

### PostgreSQL
Recommended primary database.

Use it for:
- users
- roles
- providers
- provider services
- schedules
- service requests
- job lifecycle
- payment records
- ratings
- tracking points

### SQL Server
Use only if your environment already strongly depends on it.

Good if:
- your hosting is Microsoft-heavy
- your team already knows SQL Server deeply

Otherwise, PostgreSQL is the better greenfield default.

### SQLite
Only for local development or throwaway demos.

Do not use it for production for this app.

### MongoDB
Not recommended as the primary database for version one.

Reason:
- this system is more transactional and relational than document-driven

## What The Backend Must Do

### Authentication
- send OTP
- verify OTP
- issue access tokens
- manage refresh tokens if needed
- enforce roles such as client and provider

### Provider Management
- create provider profile
- manage services offered
- manage pricing
- manage availability
- manage verification status

### Service Requests
- create request
- assign or match provider
- persist selected schedule
- update request status
- keep status history

### Job Tracking
- receive provider location updates
- store tracking points
- expose latest tracking data to clients

### Payments
- create invoice
- record payment status
- generate receipts
- prepare provider payout data

### Notifications
- push notifications
- SMS for OTP or status updates
- email if needed

## Suggested Backend Modules
- `Auth`
- `Users`
- `Providers`
- `ServiceRequests`
- `Jobs`
- `Tracking`
- `Payments`
- `Notifications`

Start as a modular monolith.

Do not start with microservices.

## Suggested Backend Project Structure

```text
wirasasa-backend/
  src/
    Wirasasa.Api/
    Wirasasa.Application/
    Wirasasa.Domain/
    Wirasasa.Infrastructure/
  tests/
    Wirasasa.Api.Tests/
    Wirasasa.Application.Tests/
    Wirasasa.IntegrationTests/
  docs/
```

## What Each Layer Does

### `Wirasasa.Api`
- controllers or minimal APIs
- auth middleware
- OpenAPI config
- request validation
- dependency injection setup

### `Wirasasa.Application`
- use cases
- commands and queries
- DTOs
- business workflows

### `Wirasasa.Domain`
- entities
- enums
- value objects
- business rules

### `Wirasasa.Infrastructure`
- EF Core
- PostgreSQL persistence
- Redis integration
- OTP providers
- SMS/email providers
- external payment integrations

## Initial Database Tables
Start with these:
- `users`
- `user_roles`
- `provider_profiles`
- `provider_services`
- `provider_availability`
- `service_requests`
- `service_request_status_history`
- `jobs`
- `job_tracking_points`
- `invoices`
- `payments`
- `ratings`
- `device_tokens`

## Recommended Initial API Endpoints

### Auth
- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`
- `POST /api/auth/refresh`

### Providers
- `GET /api/providers`
- `GET /api/providers/{id}`
- `POST /api/providers`
- `PATCH /api/providers/{id}`

### Service Requests
- `POST /api/service-requests`
- `GET /api/service-requests/{id}`
- `GET /api/service-requests`
- `PATCH /api/service-requests/{id}/status`

### Tracking
- `POST /api/provider-locations`
- `GET /api/jobs/{id}/tracking`

### Payments
- `POST /api/payments/initiate`
- `GET /api/invoices/{id}`
- `GET /api/receipts/{id}`

## Security Requirements
- use HTTPS everywhere
- use JWT bearer authentication
- keep OTP verification server-side
- hash and protect sensitive tokens
- do not trust prices, roles, or job status coming from the Flutter client
- validate every state transition on the server

## Real-Time Recommendation

### Phase 1
Use normal API polling:
- client polls request status
- provider posts location every few seconds

### Phase 2
Add real-time:
- `SignalR` for live location and job status updates

Do not make real-time infrastructure your first blocker.

## Caching Recommendation
Use `Redis` for:
- OTP expiration
- rate limiting
- temporary session data
- hot lookup caching

Do not use Redis as the primary system of record.

## File Storage Recommendation
Use external object storage later for:
- provider verification documents
- invoice PDFs
- receipt files
- media uploads

Examples:
- Azure Blob Storage
- Amazon S3
- Cloudflare R2

## Deployment Recommendation
Start simple.

Recommended:
- API hosting: Azure App Service, Azure Container Apps, Fly.io, or Render
- database: managed PostgreSQL
- cache: managed Redis

Avoid Kubernetes at the beginning unless you already know you need it.

## What You Need To Create

### 1. Backend Repository
Create a new repository such as:

```text
wirasasa-backend
```

### 2. .NET Solution
Create a solution with:
- API project
- application project
- domain project
- infrastructure project
- test projects

### 3. Database
Provision:
- PostgreSQL database
- Redis instance

### 4. Environment Variables
You will need variables such as:
- `ConnectionStrings__Postgres`
- `ConnectionStrings__Redis`
- `Jwt__Issuer`
- `Jwt__Audience`
- `Jwt__SigningKey`
- `Otp__Provider`
- `Sms__ApiKey`
- `Payments__ApiKey`

### 5. Tooling
You will need:
- `.NET SDK`
- PostgreSQL
- EF Core migrations
- Swagger / OpenAPI
- logging and monitoring

## Flutter Integration Plan
Once the backend exists, this Flutter app should move from mock data to repository-backed APIs.

Replace:
- `MockData`
- mock repositories
- local-only request flow assumptions

With:
- HTTP API clients
- DTOs
- repository implementations
- authenticated requests
- server-driven request and tracking state

## Suggested Development Order
1. Build auth and user accounts.
2. Build provider profile and provider services.
3. Build service request creation and retrieval.
4. Build request status transitions.
5. Build tracking updates.
6. Build payments and receipts.
7. Add push notifications.

## What Not To Do Early
- do not start with microservices
- do not over-design event-driven architecture too early
- do not depend on web sockets before the basic request lifecycle works
- do not keep business truth only in Flutter state

## Final Recommendation
If you want one clear path:

- keep this Flutter app as the frontend project
- create a separate `.NET` backend project
- use `ASP.NET Core Web API`
- use `PostgreSQL`
- use `Redis`
- start with a modular monolith

That is the cleanest and most maintainable setup for this product.
