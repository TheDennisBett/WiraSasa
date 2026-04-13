import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';
import 'package:wirasasa/features/auth/data/auth_api.dart';
import 'package:wirasasa/features/home/data/catalog_api.dart';
import 'package:wirasasa/features/payments/data/payments_api.dart';
import 'package:wirasasa/features/providers/data/providers_api.dart';
import 'package:wirasasa/features/service_request/data/service_requests_api.dart';
import 'package:wirasasa/features/tracking/data/tracking_api.dart';
import 'package:wirasasa/models/app_mode.dart';

final shellIndexProvider = NotifierProvider<ShellIndexNotifier, int>(
  ShellIndexNotifier.new,
);

final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(
  AppModeNotifier.new,
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.read(apiClientProvider)),
);

final catalogApiProvider = Provider<CatalogApi>(
  (ref) => CatalogApi(ref.read(apiClientProvider)),
);

final providersApiProvider = Provider<ProvidersApi>(
  (ref) => ProvidersApi(ref.read(apiClientProvider)),
);

final serviceRequestsApiProvider = Provider<ServiceRequestsApi>(
  (ref) => ServiceRequestsApi(ref.read(apiClientProvider)),
);

final trackingApiProvider = Provider<TrackingApi>(
  (ref) => TrackingApi(ref.read(apiClientProvider)),
);

final paymentsApiProvider = Provider<PaymentsApi>(
  (ref) => PaymentsApi(ref.read(apiClientProvider)),
);

final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthSession?>(
  AuthSessionNotifier.new,
);

class ShellIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

class AppModeNotifier extends Notifier<AppMode> {
  @override
  AppMode build() => AppMode.client;

  void setMode(AppMode mode) => state = mode;
}

class AuthSessionNotifier extends Notifier<AuthSession?> {
  @override
  AuthSession? build() => null;

  void setSession(AuthSession session) => state = session;

  void clear() => state = null;
}
