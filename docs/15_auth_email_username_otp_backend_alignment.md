# Auth Login Backend Alignment

This document aligns the new Flutter login UI with the .NET backend auth contract.

## 1. Frontend Change Summary

The Flutter login screen no longer starts with only a phone number.

Current UI:

- heading: `Enter Email Address or Username`
- field label: `Email address Or Username`
- field placeholder: `Enter email or Address`
- password field below the identifier field
- main button: `Send Token`
- after tapping `Send Token`, a modal asks:
  - `Send via Sms`
  - `Send via email`
- each delivery option uses a radio-style selector
- social sign-in buttons were removed
- `Forgot password` opens a reset-password page
- create-account link remains below forgot password

Important: Flutter only changed the UI for now. Backend validation and OTP delivery still need to be implemented.

## 2. Backend Ownership

Implement the login behavior in the .NET backend.

Do not make Flutter validate passwords or decide whether an account can receive OTP. Flutter should only collect:

- identifier: email address, username, or phone number
- password
- requested role
- selected OTP delivery channel: `sms` or `email`

The backend must:

- normalize and resolve the identifier
- validate the password
- verify the user has the requested role
- verify the selected OTP channel is available for that account
- create and persist the OTP challenge
- deliver OTP using SMS or email provider
- return a challenge id to Flutter

## 3. Recommended New Backend Endpoint

Add one dedicated endpoint for password-first OTP login:

```text
POST /api/auth/start-password-otp
```

Request:

```json
{
  "identifier": "jane@example.com",
  "password": "StrongPass123!",
  "requestedRole": "client",
  "deliveryChannel": "email"
}
```

Alternative SMS request:

```json
{
  "identifier": "0711333444",
  "password": "StrongPass123!",
  "requestedRole": "client",
  "deliveryChannel": "sms"
}
```

Response:

```json
{
  "challengeId": "otp_xxx",
  "destination": "j***@example.com",
  "deliveryChannel": "email",
  "expiresInSeconds": 300,
  "nextAction": "verifyOtp",
  "devOtpCode": "123456"
}
```

Production note:

- `devOtpCode` must only be returned in local/development mode.
- In production, return `null` or omit it.

## 4. Why a New Endpoint

The current auth flow was built for phone-only OTP:

- `POST /api/auth/check-user`
- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`

The new UI requires password validation before OTP. Overloading `send-otp` would make the old and new flows ambiguous.

Use a new endpoint so the contract is explicit:

```text
identifier + password + deliveryChannel -> OTP challenge
```

Keep `verify-otp` unchanged if possible because it already verifies by `challengeId`.

## 5. Backend Contract Changes

In:

```text
/home/bett/wirasasa backend/src/Wirasasa.Application/Contracts.cs
```

Add:

```csharp
public sealed record StartPasswordOtpRequest(
    string Identifier,
    string Password,
    string RequestedRole,
    string DeliveryChannel);

public sealed record StartPasswordOtpResponse(
    string ChallengeId,
    string Destination,
    string DeliveryChannel,
    int ExpiresInSeconds,
    string NextAction,
    string? DevOtpCode);
```

If the backend already has `SendOtpResponse`, you may reuse it only if it can represent:

- masked destination
- channel
- challenge id
- expiry
- development OTP

Otherwise, keep the dedicated response shape.

## 6. Backend Controller Changes

In:

```text
/home/bett/wirasasa backend/src/Wirasasa.Api/Controllers/AuthController.cs
```

Add:

```csharp
[HttpPost("start-password-otp")]
[ProducesResponseType(typeof(StartPasswordOtpResponse), StatusCodes.Status200OK)]
public ActionResult<StartPasswordOtpResponse> StartPasswordOtp(
    [FromBody] StartPasswordOtpRequest request) =>
    Ok(authService.StartPasswordOtp(request));
```

Final route:

```text
POST /api/auth/start-password-otp
```

## 7. Application Service Behavior

In `AuthService`, implement:

```text
StartPasswordOtp(StartPasswordOtpRequest request)
```

Required behavior:

1. trim identifier
2. parse requested role
3. parse delivery channel: `sms` or `email`
4. resolve user by identifier:
   - if identifier contains `@`, search by normalized email
   - if identifier looks like a phone number, normalize phone and search by phone
   - if username is supported, search by normalized username
5. if user does not exist, return a generic invalid-credentials error
6. verify password hash using the backend password hasher
7. confirm user has the requested role
8. confirm delivery channel is available:
   - `sms` requires a stored phone number
   - `email` requires a stored email address
9. create OTP challenge with:
   - challenge id
   - user id or resolved phone/email destination
   - delivery channel
   - requested role
   - expiry time
   - OTP code hash, not raw code
10. deliver OTP:
   - SMS sender for `sms`
   - email sender for `email`
11. return response with masked destination

Invalid credential response should be generic:

```text
Invalid email/username or password.
```

Do not reveal whether the account, password, role, email, or phone was wrong.

## 8. Password Verification

The backend already stores `PasswordHash` for the create-account flow.

Use the same password hasher used during registration.

Example behavior:

```csharp
var result = passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
if (result == PasswordVerificationResult.Failed)
{
    throw new InvalidOperationException("Invalid email/username or password.");
}
```

If `PasswordHash` is empty for seeded or legacy users, either:

- reject password login and require password reset, or
- seed those users with known development-only passwords

Do not bypass password verification in production.

## 9. OTP Challenge Storage

The current `OtpChallenge` model may be phone-based.

Update it to support email and SMS safely.

Recommended fields:

```text
Id
UserId
Destination
DeliveryChannel
CodeHash
ExpiresAtUtc
RequestedRole
ConsumedAtUtc
CreatedAtUtc
```

Security recommendations:

- store a hash of the OTP, not the raw OTP
- expire in 5 minutes
- mark as consumed after successful verification
- rate-limit challenge creation per account and destination
- rate-limit verification attempts per challenge

If you keep raw OTP in development for now, document it as temporary and keep it out of production.

## 10. Email Sender Abstraction

Add an email sender interface in the application layer or infrastructure boundary:

```csharp
public interface IEmailOtpSender
{
    Task SendOtpAsync(string email, string code, CancellationToken cancellationToken = default);
}
```

For local development, use a development sender:

```text
DevelopmentEmailOtpSender
```

It can log the OTP to console while email provider credentials are not configured.

For production, replace it with an SMTP, SendGrid, AWS SES, Mailgun, or similar provider implementation.

## 11. SMS Sender Abstraction

Do not block the new email flow on SMS setup.

Add or keep an SMS interface:

```csharp
public interface ISmsOtpSender
{
    Task SendOtpAsync(string phoneNumber, string code, CancellationToken cancellationToken = default);
}
```

For now:

- `deliveryChannel = "email"` should work first
- `deliveryChannel = "sms"` can return a clear provider-not-configured error until SMS is wired

Example:

```text
SMS OTP delivery is not configured yet. Choose email instead.
```

## 12. Forgot Password Backend Contract

The new Flutter page has:

- title: `Forgot password`
- field label: `Enter email/phone number`
- button: `Reset password`

Add endpoint:

```text
POST /api/auth/forgot-password
```

Request:

```json
{
  "identifier": "jane@example.com"
}
```

Response:

```json
{
  "message": "If the account exists, a password reset link has been sent."
}
```

Security rule:

- Always return the same success message whether or not the account exists.
- Do not leak account existence.

Recommended backend behavior:

1. normalize identifier
2. look up user by email or phone
3. if user exists:
   - create reset token
   - store hashed reset token with expiry
   - send reset link by email if email exists
4. always return the generic success response

Add later:

```text
POST /api/auth/reset-password
```

Request:

```json
{
  "token": "reset_token_from_email",
  "newPassword": "NewStrongPass123!"
}
```

## 13. Flutter API Changes After Backend Is Ready

After the backend endpoint is implemented, update:

```text
/home/bett/Wirasasa/lib/features/auth/data/auth_api.dart
```

Add:

```dart
Future<OtpChallenge> startPasswordOtp({
  required String identifier,
  required String password,
  required String requestedRole,
  required String deliveryChannel,
}) async {
  final response = await _client.postJson(
    '/api/auth/start-password-otp',
    body: {
      'identifier': identifier,
      'password': password,
      'requestedRole': requestedRole,
      'deliveryChannel': deliveryChannel,
    },
  );
  return OtpChallenge.fromJson(response as Map<String, dynamic>);
}
```

Then update:

```text
/home/bett/Wirasasa/lib/features/auth/login/presentation/screens/login_screen.dart
```

Replace the placeholder snackbar after channel selection with:

```dart
final challenge = await ref.read(authApiProvider).startPasswordOtp(
  identifier: identifier,
  password: password,
  requestedRole: 'client',
  deliveryChannel: channel.name,
);

Navigator.pushNamed(
  context,
  AppRouter.otp,
  arguments: OtpScreenArguments(
    challengeId: challenge.challengeId,
    phoneNumber: challenge.phoneNumber,
    requestedRole: 'client',
    displayName: null,
    devOtpCode: challenge.devOtpCode,
  ),
);
```

Note: `OtpScreenArguments.phoneNumber` should later be renamed to something neutral like `destination` or `identifier`, because OTP may now go to email.

## 14. Backend Tests To Add

Add tests in:

```text
/home/bett/wirasasa backend/tests/Wirasasa.Application.Tests/AuthServiceTests.cs
```

Required cases:

- `StartPasswordOtp` succeeds with email identifier and `deliveryChannel = email`
- `StartPasswordOtp` succeeds with phone identifier and `deliveryChannel = sms` when SMS sender is configured
- invalid password returns generic invalid-credentials error
- unknown identifier returns generic invalid-credentials error
- requested role mismatch fails
- email channel fails if user has no email
- SMS channel fails if user has no phone
- challenge expires after configured duration
- `VerifyOtp` consumes challenge and rejects reuse
- `ForgotPassword` always returns generic success message

Add API tests in:

```text
/home/bett/wirasasa backend/tests/Wirasasa.Api.Tests
```

Required endpoint tests:

- `POST /api/auth/start-password-otp` returns `200` for valid email/password/email channel
- `POST /api/auth/start-password-otp` returns `400` for invalid credentials
- `POST /api/auth/forgot-password` returns generic success

## 15. Manual Backend Test Payloads

Email OTP login:

```bash
curl -X POST http://127.0.0.1:5098/api/auth/start-password-otp \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "jane@example.com",
    "password": "StrongPass123!",
    "requestedRole": "client",
    "deliveryChannel": "email"
  }'
```

SMS OTP login:

```bash
curl -X POST http://127.0.0.1:5098/api/auth/start-password-otp \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "0711333444",
    "password": "StrongPass123!",
    "requestedRole": "client",
    "deliveryChannel": "sms"
  }'
```

Forgot password:

```bash
curl -X POST http://127.0.0.1:5098/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "jane@example.com"
  }'
```

## 16. Suggested Implementation Order

Use this order to keep the backend and Flutter synced:

1. Add backend contracts for `StartPasswordOtpRequest`, `StartPasswordOtpResponse`, and `ForgotPasswordRequest`.
2. Add backend auth controller endpoints.
3. Add repository lookup by email and username if username is supported.
4. Add password verification in `AuthService.StartPasswordOtp`.
5. Extend OTP challenge model for delivery channel and destination.
6. Add development email OTP sender.
7. Add SMS not-configured guard if SMS is not ready.
8. Add forgot-password token creation and generic response.
9. Add backend unit/API tests.
10. Run `dotnet test Wirasasa.sln -v minimal`.
11. Update Flutter `AuthApi`.
12. Connect login modal selection to backend endpoint.
13. Rename OTP destination variables from phone-specific naming to neutral naming.
14. Run `flutter analyze` and `flutter test`.
15. Run the end-to-end test plan in `docs/14_end_to_end_backend_frontend_test_plan.md`.

## 17. Acceptance Criteria

Backend and Flutter are synced when:

- Flutter login accepts email/username and password
- backend validates password before OTP creation
- email OTP works without SMS configuration
- SMS option fails gracefully until SMS is configured
- OTP verification still works through `challengeId`
- forgot-password endpoint returns a generic success response
- no endpoint leaks whether an account exists during failed login/reset flows
- tests pass on both backend and Flutter
