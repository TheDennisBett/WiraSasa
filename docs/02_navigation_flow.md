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
4. Home passes `serviceType` and optional `scheduledDateTime` to Map Discovery
5. Map Discovery renders the booking context as instant or scheduled

## Routing Decision
Navigation still uses `MaterialApp.onGenerateRoute` with typed route arguments for map discovery. This keeps the scaffold simple while allowing the map flow to receive scheduling context without introducing a routing package yet.
