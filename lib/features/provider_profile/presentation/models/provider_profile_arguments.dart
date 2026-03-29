import 'package:wirasasa/core/utils/mock_data.dart';

class ProviderProfileArguments {
  const ProviderProfileArguments({
    required this.provider,
    required this.serviceType,
    this.scheduledDateTime,
  });

  final ProviderPreview provider;
  final String serviceType;
  final DateTime? scheduledDateTime;
}
