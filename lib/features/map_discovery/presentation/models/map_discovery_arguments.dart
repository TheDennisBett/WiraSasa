class MapDiscoveryArguments {
  const MapDiscoveryArguments({
    required this.serviceType,
    this.scheduledDateTime,
    this.initialQuery,
  });

  final String serviceType;
  final DateTime? scheduledDateTime;
  final String? initialQuery;

  bool get isScheduledBooking => scheduledDateTime != null;
}
