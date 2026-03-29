# Backend / Frontend Integration Runbook

This document explains how to connect the Flutter app in `/home/bett/Wirasasa` to the backend in `/home/bett/wirasasa backend` without hardcoding URLs.

## Goal

Use environment configuration for the API base URL, then connect the Flutter auth, provider discovery, booking, tracking, and payment flows to the backend so you can test end to end.

## Repositories

- frontend: `/home/bett/Wirasasa`
- backend: `/home/bett/wirasasa backend`

## 1. Backend Runtime Configuration

The backend already uses configuration files and connection strings. For local frontend testing, run it without the launch profile so you control the host and port explicitly.

From the backend repo root:

```bash
cd "/home/bett/wirasasa backend"
ASPNETCORE_URLS=http://0.0.0.0:5098 dotnet run --no-launch-profile --project src/Wirasasa.Api
```

Why this matters:

- `0.0.0.0` allows emulator or device access
- `5098` is a stable local test port
- `--no-launch-profile` prevents `launchSettings.json` from overriding your URL

## 2. Frontend Runtime Configuration

Do not hardcode the backend URL in widgets, repositories, or view models.

Use `--dart-define` and read it through `String.fromEnvironment`.

Recommended environment variable name:

```text
WIRASASA_API_BASE_URL
```

Recommended frontend config file to add:

`lib/core/config/app_env.dart`

```dart
class AppEnv {
  static const apiBaseUrl = String.fromEnvironment(
    'WIRASASA_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5098',
  );
}
```

Then every API client should read from `AppEnv.apiBaseUrl`.

## 3. Correct Base URL By Platform

### Flutter Web on the same machine

```text
http://127.0.0.1:5098
```

Run:

```bash
cd /home/bett/Wirasasa
flutter run -d chrome --dart-define=WIRASASA_API_BASE_URL=http://127.0.0.1:5098
```

### Android emulator

Use the Android emulator loopback alias:

```text
http://10.0.2.2:5098
```

Run:

```bash
cd /home/bett/Wirasasa
flutter run -d emulator-5554 --dart-define=WIRASASA_API_BASE_URL=http://10.0.2.2:5098
```

### iOS simulator

Use:

```text
http://127.0.0.1:5098
```

Run:

```bash
cd /home/bett/Wirasasa
flutter run -d ios --dart-define=WIRASASA_API_BASE_URL=http://127.0.0.1:5098
```

### Physical device on the same Wi‑Fi

Replace with your machine LAN IP:

```text
http://<your-lan-ip>:5098
```

Example:

```bash
cd /home/bett/Wirasasa
flutter run --dart-define=WIRASASA_API_BASE_URL=http://192.168.1.25:5098
```

## 4. Required Frontend Dependency

The Flutter app currently has no HTTP client package in `pubspec.yaml`.

Add one:

```bash
cd /home/bett/Wirasasa
flutter pub add http
```

If you later want interceptors, retries, and better typed networking, switch to `dio`. For the first integration pass, `http` is enough.

## 5. Suggested Frontend Integration Structure

Recommended files to add in the Flutter app:

```text
lib/
  core/
    config/
      app_env.dart
    network/
      api_client.dart
  features/
    auth/
      data/
        auth_api.dart
    providers/
      data/
        providers_api.dart
    service_requests/
      data/
        service_requests_api.dart
    tracking/
      data/
        tracking_api.dart
    payments/
      data/
        payments_api.dart
```

Recommended minimal API client:

`lib/core/network/api_client.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wirasasa/core/config/app_env.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${AppEnv.apiBaseUrl}$path').replace(queryParameters: query);

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? bearerToken,
    Map<String, String>? query,
  }) async {
    final response = await _http.get(
      _uri(path, query),
      headers: {
        'Accept': 'application/json',
        if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      },
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    String? bearerToken,
  }) async {
    final response = await _http.post(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode(body),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Object? body,
    String? bearerToken,
  }) async {
    final response = await _http.patch(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode(body),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
```

## 6. Screen-to-Endpoint Mapping

Map the current Flutter screens to the backend like this:

### Login screen

File now:

- `lib/features/auth/login/presentation/screens/login_screen.dart`

Use:

- `POST /api/auth/check-user`
- `POST /api/auth/register` when `nextAction == createAccount`
- `POST /api/auth/send-otp`

Recommended flow:

1. user enters phone number
2. call `check-user`
3. if new user, collect display name and call `register`
4. call `send-otp`
5. navigate to OTP screen

### OTP screen

File now:

- `lib/features/auth/otp/presentation/screens/otp_screen.dart`

Use:

- `POST /api/auth/verify-otp`
- `POST /api/auth/refresh`

Store:

- `accessToken`
- `refreshToken`
- `user.userId`
- `user.roles`

Important:

- refresh rotates the access token
- after refresh, discard the old access token

### Home screen

Replace category mocks with:

- `GET /api/catalog/services`

### Map discovery

Replace provider mocks with:

- `GET /api/providers?serviceCode=<service>&onlineOnly=true`

### Provider profile

Load provider details with:

- `GET /api/providers/{id}`

### Service request flow

Use:

- `POST /api/service-requests`
- `GET /api/service-requests/{id}`
- `GET /api/service-requests`

### Provider mode

Use:

- `GET /api/providers/me/dashboard`
- `PATCH /api/service-requests/{id}/status`
- `POST /api/provider-locations`

### Tracking

Use:

- `GET /api/jobs/{id}/tracking`

### Payments

Use:

- `POST /api/payments/initiate`
- `GET /api/invoices/{id}`
- `GET /api/receipts/{id}`

## 7. End-to-End Manual Test Flow

Use this exact sequence once the frontend starts calling the backend:

1. Start backend on `0.0.0.0:5098`.
2. Start Flutter with `--dart-define=WIRASASA_API_BASE_URL=<correct-url-for-platform>`.
3. Enter a new phone number on the login screen.
4. Call `check-user`.
5. If new, call `register`.
6. Call `send-otp`.
7. On OTP screen, call `verify-otp`.
8. Load service categories from `GET /api/catalog/services`.
9. Select a service and load providers from `GET /api/providers`.
10. Open provider detail with `GET /api/providers/{id}`.
11. Create a booking using `POST /api/service-requests`.
12. Provider accepts the request using `PATCH /api/service-requests/{id}/status`.
13. Provider posts location using `POST /api/provider-locations`.
14. Client reads tracking using `GET /api/jobs/{id}/tracking`.
15. Complete job and initiate payment.

## 8. Current Backend Behavior Relevant To Frontend

- root: `GET /`
- health: `GET /health`
- Swagger UI: `GET /swagger`
- API docs JSON: `GET /swagger/v1/swagger.json`

Detailed backend endpoint docs are already in:

- `/home/bett/wirasasa backend/docs/endpoints.md`
- `/home/bett/wirasasa backend/docs/test-payloads.md`
- `/home/bett/wirasasa backend/docs/api-test-results.md`

## 9. Web-Specific Note

If you test from Flutter Web in Chrome, the backend must allow the frontend origin via CORS. If browser calls fail while mobile/emulator calls work, add CORS middleware on the backend for the Flutter web origin.

## 10. Recommended Next Implementation Order In Flutter

1. Add `app_env.dart`
2. Add `ApiClient`
3. Replace login and OTP flow first
4. Replace home categories and provider discovery
5. Replace service request create/read flow
6. Replace provider mode dashboard and status transitions
7. Replace tracking and payment flows

## 11. Run Commands

### Backend

```bash
cd "/home/bett/wirasasa backend"
ASPNETCORE_URLS=http://0.0.0.0:5098 dotnet run --no-launch-profile --project src/Wirasasa.Api
```

### Flutter Web

```bash
cd /home/bett/Wirasasa
flutter pub add http
flutter run -d chrome --dart-define=WIRASASA_API_BASE_URL=http://127.0.0.1:5098
```

### Android Emulator

```bash
cd /home/bett/Wirasasa
flutter pub add http
flutter run -d emulator-5554 --dart-define=WIRASASA_API_BASE_URL=http://10.0.2.2:5098
```

### iOS Simulator

```bash
cd /home/bett/Wirasasa
flutter pub add http
flutter run -d ios --dart-define=WIRASASA_API_BASE_URL=http://127.0.0.1:5098
```
