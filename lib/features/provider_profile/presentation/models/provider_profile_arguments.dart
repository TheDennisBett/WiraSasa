import 'package:wirasasa/core/network/api_models.dart';

class ProviderProfileArguments {
  const ProviderProfileArguments({
    required this.provider,
    required this.serviceCode,
    required this.serviceName,
    this.scheduledDateTime,
  });

  final ProviderSummary provider;
  final String serviceCode;
  final String serviceName;
  final DateTime? scheduledDateTime;
}
