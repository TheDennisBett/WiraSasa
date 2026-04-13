class OtpScreenArguments {
  const OtpScreenArguments({
    required this.challengeId,
    required this.phoneNumber,
    required this.requestedRole,
    this.displayName,
    this.devOtpCode,
  });

  final String challengeId;
  final String phoneNumber;
  final String requestedRole;
  final String? displayName;
  final String? devOtpCode;
}
