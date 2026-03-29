# Map System

## Current Implementation
- `google_maps_flutter` powers Map Discovery and Provider Profile on Android and iOS
- discovery uses real map markers, camera movement, and a selected-provider route polyline
- provider profile uses a real map canvas with a moving provider marker to represent live tracking progress

## Remaining Work
- live geolocation
- provider clustering
- ETA and distance computation
- backend-driven client-provider live tracking after job acceptance

## Design Goal
The map should remain the primary canvas, with booking context delivered through floating overlays and bottom sheets.
