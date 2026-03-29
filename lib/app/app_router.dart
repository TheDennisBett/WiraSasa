import 'package:flutter/material.dart';
import 'package:wirasasa/features/auth/login/presentation/screens/login_screen.dart';
import 'package:wirasasa/features/auth/otp/presentation/screens/otp_screen.dart';
import 'package:wirasasa/features/home/presentation/screens/app_shell.dart';
import 'package:wirasasa/features/map_discovery/presentation/models/map_discovery_arguments.dart';
import 'package:wirasasa/features/map_discovery/presentation/screens/map_discovery_screen.dart';
import 'package:wirasasa/features/provider_mode/presentation/screens/provider_mode_screen.dart';
import 'package:wirasasa/features/provider_profile/presentation/models/provider_profile_arguments.dart';
import 'package:wirasasa/features/provider_profile/presentation/screens/provider_profile_screen.dart';
import 'package:wirasasa/features/service_request/presentation/screens/service_request_screen.dart';

class AppRouter {
  static const shell = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const mapDiscovery = '/map-discovery';
  static const providerProfile = '/provider-profile';
  static const serviceRequest = '/service-request';
  static const providerMode = '/provider-mode';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _page(const LoginScreen(), settings);
      case otp:
        return _page(const OtpScreen(), settings);
      case shell:
        return _page(const AppShell(), settings);
      case mapDiscovery:
        final arguments = settings.arguments as MapDiscoveryArguments?;
        return _page(
          MapDiscoveryScreen(
            serviceType: arguments?.serviceType ?? 'Electrician',
            scheduledDateTime: arguments?.scheduledDateTime,
            initialQuery: arguments?.initialQuery,
          ),
          settings,
        );
      case providerProfile:
        final arguments = settings.arguments as ProviderProfileArguments?;
        return _page(
          ProviderProfileScreen(
            provider: arguments?.provider,
            serviceType: arguments?.serviceType,
            scheduledDateTime: arguments?.scheduledDateTime,
          ),
          settings,
        );
      case serviceRequest:
        return _page(const ServiceRequestScreen(), settings);
      case providerMode:
        return _page(const ProviderModeScreen(), settings);
      default:
        return _page(const AppShell(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<void>(builder: (_) => child, settings: settings);
  }
}
