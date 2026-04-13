# Create Account Backend Integration

## Purpose
The Flutter login screen now has a dedicated `Create Account` page with these fields:
- phone number
- first name
- last name
- email
- password

That screen is wired to call:

```text
POST /api/auth/register-account
```

This endpoint does not exist in the current backend yet.

## Current Backend Limitation
The current backend contract only supports:

```text
POST /api/auth/register
```

with:

```json
{
  "phoneNumber": "+254711222333",
  "displayName": "New Customer",
  "requestedRole": "client"
}
```

That is not enough for the new form because the new UI needs:
- first name
- last name
- email
- password

## New Backend Endpoint To Add

### Route

```text
POST /api/auth/register-account
```

### Request Body

```json
{
  "phoneNumber": "+254711222333",
  "firstName": "Jane",
  "lastName": "Doe",
  "email": "jane@example.com",
  "password": "StrongPass123!",
  "requestedRole": "client"
}
```

### Recommended Response

Return the same user shape already used by the frontend auth models:

```json
{
  "userId": "usr_xxx",
  "phoneNumber": "+254711222333",
  "displayName": "Jane Doe",
  "roles": ["client"]
}
```

## Backend Contracts To Change
In `/home/bett/wirasasa backend/src/Wirasasa.Application/Contracts.cs`, add a new request model such as:

```csharp
public sealed record RegisterAccountRequest(
    string PhoneNumber,
    string FirstName,
    string LastName,
    string Email,
    string Password,
    string RequestedRole);
```

## Backend Controller To Add
In `/home/bett/wirasasa backend/src/Wirasasa.Api/Controllers/AuthController.cs`, add:

```csharp
[HttpPost("register-account")]
[ProducesResponseType(typeof(AuthenticatedUserDto), StatusCodes.Status200OK)]
public ActionResult<AuthenticatedUserDto> RegisterAccount([FromBody] RegisterAccountRequest request) =>
    Ok(authService.RegisterAccount(request));
```

## Application Service Behavior
In the auth service, the new `RegisterAccount` flow should:
1. validate phone number format
2. validate email format
3. check whether phone already exists
4. check whether email already exists
5. hash the password
6. save the user
7. return the created user DTO

## Database Fields Required
Your user table should store at least:
- `id`
- `phone_number`
- `first_name`
- `last_name`
- `display_name`
- `email`
- `password_hash`
- `created_at_utc`
- `updated_at_utc`

Recommended constraints:
- unique on `phone_number`
- unique on `email`

## Password Handling Rules
- never store raw passwords
- hash passwords with a strong password hasher
- do not return password or password hash to the frontend

For `.NET`, use the platform password hasher or a strong industry-standard hashing approach.

## Validation Rules
Recommended backend validation:
- first name: required
- last name: required
- email: required and unique
- password: minimum 8 characters
- phone number: required and unique
- requested role: only known roles allowed

## Frontend File Already Wired
The Flutter form now lives in:

```text
lib/features/auth/create_account/presentation/screens/create_account_screen.dart
```

The API call is already prepared in:

```text
lib/features/auth/data/auth_api.dart
```

It calls:

```text
/api/auth/register-account
```

## Frontend Flow
1. user taps `Create Account` on the login screen
2. user fills the new account form
3. frontend calls `POST /api/auth/register-account`
4. backend saves the user to the database
5. frontend returns to login with the phone number prefilled
6. user signs in and requests OTP

## What You Need To Do Next In The Backend
1. add `RegisterAccountRequest`
2. add `AuthController.RegisterAccount`
3. add `AuthService.RegisterAccount`
4. update the persistence layer to save `firstName`, `lastName`, `email`, and `passwordHash`
5. add uniqueness checks for phone and email
6. test the endpoint from Swagger or curl

## Suggested Manual Test
After backend implementation:

1. open Flutter login
2. tap `Create Account`
3. submit the form
4. confirm the user row is saved in PostgreSQL
5. return to login
6. sign in with the same phone number
7. continue OTP flow
