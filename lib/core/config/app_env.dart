class AppEnv {
  static const apiBaseUrl = String.fromEnvironment(
    'WIRASASA_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5098',
  );

  static const showDevOtp = bool.fromEnvironment('WIRASASA_SHOW_DEV_OTP');
}
