class MapDiscoveryArguments {
  const MapDiscoveryArguments({
    required this.serviceCode,
    required this.serviceName,
    this.scheduledDateTime,
    this.initialQuery,
  });

  final String serviceCode;
  final String serviceName;
  final DateTime? scheduledDateTime;
  final String? initialQuery;

  bool get isScheduledBooking => scheduledDateTime != null;
}
