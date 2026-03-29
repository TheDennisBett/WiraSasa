class MockSessionRepository {
  Future<bool> hasActiveSession() async => false;

  Future<void> saveSession() async {}
}
