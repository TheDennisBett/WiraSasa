# Google Maps And Booking Flow

## What Changed
- provider discovery now uses `google_maps_flutter` instead of a custom-painted placeholder
- provider profile now shows a real Google Map with a route polyline and a moving provider marker
- `bookingFlowProvider` preserves `serviceType`, `selectedProvider`, and `scheduledDateTime` through request confirmation
- service request now confirms against preserved booking state instead of hard-coded mock summary text

## Android Setup
- `android/app/src/main/AndroidManifest.xml` now reads `com.google.android.geo.API_KEY`
- `android/app/src/main/res/values/strings.xml` contains `REPLACE_WITH_ANDROID_GOOGLE_MAPS_API_KEY`
- replace that placeholder with a valid Android Maps SDK key before running on device

## iOS Setup
- `ios/Runner/Info.plist` now contains `REPLACE_WITH_IOS_GOOGLE_MAPS_API_KEY`
- replace that value with a valid iOS Maps SDK key before running on device

## Booking Flow Contract
1. Home seeds booking state with service and schedule.
2. Map Discovery selects and preserves the active provider.
3. Provider Profile continues with the same provider and schedule.
4. Service Request can update the schedule and confirm without losing the selected provider.

## Known Limits
- desktop fallback keeps overlays but does not embed Google Maps
- tracking movement is still demo data until backend location updates are available
