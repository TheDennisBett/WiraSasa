# State Management

## Tooling
Riverpod is the state management foundation.

## Active Providers
- `shellIndexProvider`: active bottom navigation tab
- `appModeProvider`: current operating mode, client or provider
- `scheduleProvider`: stores `scheduledTime` and `isScheduledBooking`

## Scheduling Behavior
- default state is instant booking
- confirming the scheduling modal stores a `DateTime`
- the next service selection consumes that state and passes it into Map Discovery
- after navigation, the schedule is cleared so the default flow remains instant

## Planned Expansion
Later phases should introduce feature-scoped providers for:
- auth session
- home discovery
- map/provider matching
- provider job queue
- activity history
