# End-to-End Backend / Flutter Test Plan

This guide verifies that the Flutter app in `/home/bett/Wirasasa` talks to the .NET backend in `/home/bett/wirasasa backend` through the real API, not mock data.

## 1. Preconditions

Confirm these are ready before testing:

- backend repo exists at `/home/bett/wirasasa backend`
- Flutter repo exists at `/home/bett/Wirasasa`
- PostgreSQL is running and the backend connection string is configured
- .NET SDK is installed
- Flutter SDK is installed
- an Android emulator, iOS simulator, or Chrome device is available

Useful checks:

```bash
dotnet --version
flutter doctor
flutter devices
```

## 2. Start and Validate the Backend

Open a terminal and run:

```bash
cd "/home/bett/wirasasa backend"
./complete_backend_integration.sh
```

The script will:

1. restore backend packages
2. build `Wirasasa.sln`
3. apply EF migrations
4. run backend tests
5. start the API on `http://0.0.0.0:5098`

Leave this terminal open. The API stops when you press `Ctrl+C`.

Expected backend result:

```text
== Starting API ==
Health check after startup: http://127.0.0.1:5098/health
Press Ctrl+C to stop.
```

In a second terminal, confirm the API is reachable:

```bash
curl http://127.0.0.1:5098/health
```

Expected response:

```json
{"status":"ok","service":"Wirasasa.Api"}
```

## 3. Run Frontend Static Checks

In a new terminal:

```bash
cd /home/bett/Wirasasa
flutter analyze
flutter test
```

Expected result:

- `flutter analyze` reports `No issues found`
- `flutter test` reports `All tests passed`

## 4. Start Flutter Against the Backend

Choose one target.

### Flutter Web

Use this when testing in Chrome on the same machine:

```bash
cd /home/bett/Wirasasa
flutter run -d chrome \
  --dart-define=WIRASASA_API_BASE_URL=http://127.0.0.1:5098 \
  --dart-define=WIRASASA_SHOW_DEV_OTP=true
```

If browser requests fail but mobile works, the backend needs scoped CORS for the Flutter web origin.

### Android Emulator

Use Android's host loopback alias:

```bash
cd /home/bett/Wirasasa
flutter run -d emulator-5554 \
  --dart-define=WIRASASA_API_BASE_URL=http://10.0.2.2:5098 \
  --dart-define=WIRASASA_SHOW_DEV_OTP=true
```

If your emulator id differs, check it with:

```bash
flutter devices
```

### iOS Simulator

Use localhost:

```bash
cd /home/bett/Wirasasa
flutter run -d ios \
  --dart-define=WIRASASA_API_BASE_URL=http://127.0.0.1:5098 \
  --dart-define=WIRASASA_SHOW_DEV_OTP=true
```

## 5. Test Create Account and Login

Use a phone number and email that do not already exist.

Example:

```text
Phone: 0711333444
First name: Jane
Last name: Tester
Email: jane.tester.e2e@example.com
Password: StrongPass123!
```

Steps:

1. Open the Flutter app.
2. On the login screen, enter the phone number.
3. Tap `Sign In`.
4. Confirm the app says no account exists and opens the create-account screen.
5. Fill in phone number, first name, last name, email, and password.
6. Tap `Create Account`.
7. Confirm the app returns to login with the phone number prefilled.
8. Tap `Sign In` again.
9. Confirm the OTP screen opens.
10. Enter the displayed `Dev OTP` code.
11. Tap `Verify`.
12. Confirm the app navigates to the main shell/home screen.

Expected backend endpoints exercised:

- `POST /api/auth/check-user`
- `POST /api/auth/register-account`
- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`

Security check:

- `Dev OTP` should only appear because the app was launched with `WIRASASA_SHOW_DEV_OTP=true`.
- Run without that flag before any non-local test.

## 6. Test Existing User Login

Steps:

1. Stop and restart the Flutter app if needed.
2. Enter the same phone number used above.
3. Tap `Sign In`.
4. Confirm the app goes directly to OTP instead of create account.
5. Enter the displayed `Dev OTP`.
6. Tap `Verify`.
7. Confirm the main shell/home screen opens.

Expected backend endpoints exercised:

- `POST /api/auth/check-user`
- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`

## 7. Test Home Catalog

Steps:

1. After login, stay on the home screen.
2. Confirm service categories load from the backend.
3. Confirm no mock-only placeholder message appears.
4. Tap a service category such as electrician, plumber, mechanic, or gardener.

Expected backend endpoint exercised:

- `GET /api/catalog/services`

Pass criteria:

- service categories render without an error state
- tapping a category opens provider discovery

## 8. Test Provider Discovery

Steps:

1. Open provider discovery from a service category.
2. Confirm the provider list loads.
3. Confirm provider cards show server-backed data such as provider name, rating, price, and ETA.
4. Tap a provider.

Expected backend endpoint exercised:

- `GET /api/providers?serviceCode=<service>&query=<query>&onlineOnly=true`

Pass criteria:

- provider list renders
- selecting a provider opens provider profile

## 9. Test Provider Profile

Steps:

1. From provider discovery, open a provider profile.
2. Confirm provider details load.
3. Confirm service rate, bio, rating, distance, and ETA appear.
4. Tap `Request Service`.

Expected backend endpoint exercised:

- `GET /api/providers/{id}`

Pass criteria:

- provider profile renders without error
- `Request Service` opens the service request screen

## 10. Test Service Request Creation

Steps:

1. On the service request screen, choose a day.
2. Choose a time.
3. Enter a description.
4. Enter a location label.
5. Tap `Confirm Request`.
6. Confirm the app shows `Request Created`.
7. Record the request id shown in the UI.

Expected backend endpoint exercised:

- `POST /api/service-requests`

Pass criteria:

- request creation returns a server-generated request id
- status comes from the backend response
- the app does not locally invent a final status

## 11. Test Activity / Request History

Steps:

1. Navigate to the activity tab.
2. Confirm the request created above appears.
3. Confirm the service name, location, price, booking type, and status render.
4. Pull back and retry if the screen shows a temporary loading error.

Expected backend endpoint exercised:

- `GET /api/service-requests`

Pass criteria:

- the list is server-backed
- the newly created request appears

## 12. Test Provider Mode Dashboard

The provider dashboard requires a user authenticated with the `provider` role. If your current Flutter UI only signs in as `client`, use a seeded provider account or create/sign in through the backend test payloads.

Steps:

1. Sign in as a provider user.
2. Open provider mode.
3. Confirm dashboard metrics load.
4. Confirm incoming requests appear when the provider has assigned requests.

Expected backend endpoint exercised:

- `GET /api/providers/me/dashboard`

Pass criteria:

- provider dashboard loads with bearer authentication
- client-only accounts should not pass provider-only authorization

## 13. Test Request Status Transitions

Use provider mode when available.

Steps:

1. In provider mode, find an incoming `pending` request.
2. Tap `Accept Job`.
3. Confirm the app shows a success message.
4. Confirm the dashboard refreshes.
5. Optionally test `Reject` with a different pending request.

Expected backend endpoint exercised:

- `PATCH /api/service-requests/{id}/status`

Pass criteria:

- `pending -> accepted` succeeds for provider users
- invalid transitions should return an API error
- the app displays backend error messages through `ApiException`

## 14. Test Tracking API

Tracking requires a request that has a `jobId`, usually after the request is accepted and moved into an active job state.

Manual API check:

```bash
curl -H "Authorization: Bearer <access_token>" \
  http://127.0.0.1:5098/api/jobs/<job_id>/tracking
```

Provider location post:

```bash
curl -X POST http://127.0.0.1:5098/api/provider-locations \
  -H "Authorization: Bearer <provider_access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "jobId": "<job_id>",
    "latitude": -1.2600,
    "longitude": 36.8040,
    "heading": 90,
    "speedKph": 24
  }'
```

Expected backend endpoints exercised:

- `POST /api/provider-locations`
- `GET /api/jobs/{id}/tracking`

Pass criteria:

- provider can post tracking points
- client/provider can read tracking history for an authorized job

## 15. Test Payments

Payments require a completed or invoice-backed service request depending on backend rules.

Manual API check:

```bash
curl -X POST http://127.0.0.1:5098/api/payments/initiate \
  -H "Authorization: Bearer <client_access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "serviceRequestId": "<request_id>",
    "amount": 2500,
    "currency": "KES",
    "paymentMethod": "mpesa",
    "markAsPaid": true
  }'
```

Then fetch the invoice and receipt returned by the payment response:

```bash
curl -H "Authorization: Bearer <client_access_token>" \
  http://127.0.0.1:5098/api/invoices/<invoice_id>

curl -H "Authorization: Bearer <client_access_token>" \
  http://127.0.0.1:5098/api/receipts/<receipt_id>
```

Expected backend endpoints exercised:

- `POST /api/payments/initiate`
- `GET /api/invoices/{id}`
- `GET /api/receipts/{id}`

Pass criteria:

- payment response includes invoice and payment details
- receipt is present when `markAsPaid` is accepted by the backend
- frontend and manual checks treat backend payment status as the source of truth

## 16. Negative Tests

Run these to verify security behavior:

1. Start Flutter without `--dart-define=WIRASASA_SHOW_DEV_OTP=true`.
2. Request OTP.
3. Confirm the OTP screen does not display the dev code.
4. Call a protected endpoint without a token:

```bash
curl http://127.0.0.1:5098/api/service-requests
```

Expected result:

- protected endpoints reject missing tokens
- provider-only endpoints reject client-only users
- invalid status transitions return a backend error
- duplicate phone/email during create account returns a backend validation error

## 17. Troubleshooting

If Flutter cannot reach the API:

- Web: use `http://127.0.0.1:5098`
- Android emulator: use `http://10.0.2.2:5098`
- iOS simulator: use `http://127.0.0.1:5098`
- physical device: use `http://<your-machine-lan-ip>:5098`
- confirm backend is running on `0.0.0.0:5098`
- confirm `curl http://127.0.0.1:5098/health` works
- for Flutter Web, check backend CORS

If login fails:

- confirm the phone number is normalized to Kenya format
- try a new phone/email pair for create account
- verify backend logs for validation errors
- confirm `WIRASASA_SHOW_DEV_OTP=true` is only used for local testing

If provider mode fails:

- confirm the signed-in user has the `provider` role
- confirm the request is assigned to that provider
- confirm the provider account has a provider profile

## 18. Final Acceptance Checklist

Mark the integration complete only when all items pass:

- backend script completes restore, build, migrations, and tests
- backend health endpoint returns `ok`
- Flutter analyze passes
- Flutter tests pass
- create-account flow succeeds
- existing-user OTP login succeeds
- home catalog loads from backend
- provider discovery loads from backend
- provider profile loads from backend
- service request creation returns a server id
- activity history shows server-backed requests
- provider dashboard loads for provider users
- request status updates are accepted or rejected by backend rules
- tracking endpoints work for an active job
- payment initiation, invoice fetch, and receipt fetch work
- protected endpoints reject missing or wrong-role tokens
