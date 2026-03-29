# State Management

## Tooling
Riverpod is the state management foundation.

## Active Providers
- `shellIndexProvider`: active bottom navigation tab
- `appModeProvider`: current operating mode, client or provider
- `scheduleProvider`: stores `scheduledTime` and `isScheduledBooking`
- `bookingFlowProvider`: stores `serviceType`, `selectedProvider`, `scheduledDateTime`, and confirmation state

## Scheduling Behavior
- default state is instant booking
- confirming the scheduling modal stores a `DateTime`
- the next service selection consumes that state and passes it into Map Discovery
- provider selection and schedule now remain available through provider profile, service request, and confirmation

## Planned Expansion
Later phases should introduce feature-scoped providers for:
- auth session
- home discovery
- provider job queue
- activity history
