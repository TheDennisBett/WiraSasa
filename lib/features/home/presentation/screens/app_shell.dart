import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app_providers.dart';
import 'package:wirasasa/features/account/presentation/screens/account_screen.dart';
import 'package:wirasasa/features/activity/presentation/screens/activity_screen.dart';
import 'package:wirasasa/features/home/presentation/screens/home_screen.dart';
import 'package:wirasasa/shared_widgets/app_bottom_nav_bar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellIndexProvider);
    final pages = const [HomeScreen(), ActivityScreen(), AccountScreen()];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: index,
        onTap: (value) => ref.read(shellIndexProvider.notifier).setIndex(value),
      ),
    );
  }
}
