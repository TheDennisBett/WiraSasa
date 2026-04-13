import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app_providers.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/models/app_mode.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final session = ref.watch(authSessionProvider);
    final user = session?.user;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user?.initials ?? 'WS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Guest',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.phoneNumber ?? 'Sign in to load account data',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      selected: mode == AppMode.client,
                      label: 'Client',
                      onTap: () => ref
                          .read(appModeProvider.notifier)
                          .setMode(AppMode.client),
                    ),
                  ),
                  Expanded(
                    child: _ModeButton(
                      selected: mode == AppMode.provider,
                      label: 'Provider',
                      onTap: () {
                        if (!(user?.roles.contains('provider') ?? false)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sign in with a provider account to open provider mode.',
                              ),
                            ),
                          );
                          return;
                        }
                        ref
                            .read(appModeProvider.notifier)
                            .setMode(AppMode.provider);
                        Navigator.pushNamed(context, AppRouter.providerMode);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const _AccountMenuTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                  ),
                  const _AccountMenuTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                  ),
                  const _AccountMenuTile(
                    icon: Icons.shield_outlined,
                    label: 'Safety',
                  ),
                  const _AccountMenuTile(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                  ),
                  const _AccountMenuTile(
                    icon: Icons.description_outlined,
                    label: 'Legal',
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.line)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.slate,
                        size: 30,
                      ),
                      title: const Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () {
                        ref.read(authSessionProvider.notifier).clear();
                        ref.read(appModeProvider.notifier).setMode(AppMode.client);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.login,
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.ink : AppColors.slate,
          ),
        ),
      ),
    );
  }
}

class _AccountMenuTile extends StatelessWidget {
  const _AccountMenuTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: AppColors.slate, size: 30),
        title: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.muted,
        ),
        onTap: () {},
      ),
    );
  }
}
