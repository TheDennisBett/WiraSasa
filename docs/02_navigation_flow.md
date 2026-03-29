# Navigation Flow

## Root Flow
1. `LoginScreen`
2. `OtpScreen`
3. `AppShell`

## Shell Tabs
- Home
- Activity
- Account

## Secondary Routes
- Map Discovery
- Provider Profile
- Service Request
- Provider Mode

## Scheduling Flow
1. User lands on Home
2. User books instantly by tapping a service card, or taps `Later`
3. `Later` opens the scheduling modal for date and time selection
4. Home stores `serviceType` and optional `scheduledDateTime` in shared booking state and passes them to Map Discovery
5. Map Discovery renders the booking context as instant or scheduled and preserves the selected provider
6. Provider Profile and Service Request keep the same provider and schedule through confirmation

## Routing Decision
Navigation still uses `MaterialApp.onGenerateRoute` with typed route arguments for map discovery and provider profile. Riverpod now carries the booking context across discovery, profile, request, and confirmation without introducing a routing package yet.
