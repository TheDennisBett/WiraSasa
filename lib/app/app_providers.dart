import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/models/app_mode.dart';

final shellIndexProvider = NotifierProvider<ShellIndexNotifier, int>(
  ShellIndexNotifier.new,
);

final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(
  AppModeNotifier.new,
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
