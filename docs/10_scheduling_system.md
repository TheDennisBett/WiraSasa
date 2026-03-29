# Scheduling System

## Instant Booking
- user taps a service card directly from Home
- app navigates immediately to Map Discovery
- no date or time step interrupts the flow

## Scheduled Booking
- user taps `Later` inside the search container
- app opens a modal with Material date picker and time picker
- confirmation stores the schedule in Riverpod
- the next service selection sends the scheduled date and time into Map Discovery

## State Provider
Scheduling state is handled by `scheduleProvider`.

### Stored Fields
- `DateTime? scheduledTime`
- `bool isScheduledBooking`

## Navigation Contract
Map Discovery now accepts:
- `serviceType`
- `scheduledDateTime` as an optional value

If `scheduledDateTime` is `null`, the request is instant. If it is present, the request is scheduled.

## UX Goal
The experience stays map-first and fast by keeping instant booking as the default path while allowing scheduling as a lightweight optional detour.
