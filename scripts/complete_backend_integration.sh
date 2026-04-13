#!/usr/bin/env bash
set -euo pipefail

API_URL="${API_URL:-http://0.0.0.0:5098}"
PUBLIC_HEALTH_URL="${PUBLIC_HEALTH_URL:-http://127.0.0.1:5098/health}"
FRONTEND_WEB_ORIGIN="${FRONTEND_WEB_ORIGIN:-http://127.0.0.1:3000}"
DOTNET_CLI_HOME="${DOTNET_CLI_HOME:-/tmp/dotnet-home}"
NUGET_PACKAGES="${NUGET_PACKAGES:-/tmp/nuget-packages}"

export DOTNET_CLI_HOME
export NUGET_PACKAGES

if [[ ! -f "Wirasasa.sln" || ! -d "src/Wirasasa.Api" ]]; then
  echo "Run this script from the backend repo root, for example:"
  echo '  cd "/home/bett/wirasasa backend"'
  echo "  ./complete_backend_integration.sh"
  exit 1
fi

echo "== Wirasasa backend integration setup =="
echo "Backend root: $(pwd)"
echo "API URL: ${API_URL}"
echo "Flutter web origin note: ${FRONTEND_WEB_ORIGIN}"
echo

echo "== Checking toolchain =="
dotnet --info >/dev/null
dotnet --version
echo

echo "== Restoring packages =="
dotnet restore Wirasasa.sln
echo

echo "== Building solution =="
dotnet build Wirasasa.sln -v minimal --no-restore
echo

echo "== Applying EF migrations =="
dotnet ef database update \
  --project src/Wirasasa.Infrastructure \
  --startup-project src/Wirasasa.Api
echo

echo "== Running backend tests =="
dotnet test Wirasasa.sln -v minimal --no-build
echo

echo "== Backend integration summary =="
echo "Protected Flutter calls must send: Authorization: Bearer <access_token>"
echo "Flutter local web may need scoped CORS for: ${FRONTEND_WEB_ORIGIN}"
echo "Start Flutter with one of:"
echo "  flutter run -d chrome --dart-define=WIRASASA_API_BASE_URL=http://127.0.0.1:5098 --dart-define=WIRASASA_SHOW_DEV_OTP=true"
echo "  flutter run -d emulator-5554 --dart-define=WIRASASA_API_BASE_URL=http://10.0.2.2:5098 --dart-define=WIRASASA_SHOW_DEV_OTP=true"
echo

echo "== Starting API =="
echo "Health check after startup: ${PUBLIC_HEALTH_URL}"
echo "Press Ctrl+C to stop."
ASPNETCORE_URLS="${API_URL}" dotnet run \
  --no-launch-profile \
  --project src/Wirasasa.Api
