class OtpScreenArguments {
  const OtpScreenArguments({
    required this.challengeId,
    required this.phoneNumber,
    required this.requestedRole,
    required this.identifier,
    required this.channel,
    this.displayName,
    this.devOtpCode,
    this.maskedDestination,
  });

  final String challengeId;
  final String phoneNumber;
  final String requestedRole;
  final String identifier;
  final String channel;
  final String? displayName;
  final String? devOtpCode;
  final String? maskedDestination;

  String get destination {
    final masked = maskedDestination?.trim();
    if (masked != null && masked.isNotEmpty) {
      return masked;
    }
    if (phoneNumber.trim().isNotEmpty) {
      return phoneNumber;
    }
    return identifier;
  }
}
