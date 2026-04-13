import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app_providers.dart';
import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/models/app_mode.dart';

class ProviderModeScreen extends ConsumerStatefulWidget {
  const ProviderModeScreen({super.key});

  @override
  ConsumerState<ProviderModeScreen> createState() => _ProviderModeScreenState();
}

class _ProviderModeScreenState extends ConsumerState<ProviderModeScreen> {
  late Future<ProviderDashboard> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    if (session == null) {
      return const Scaffold(body: Center(child: Text('Sign in first.')));
    }

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ProviderDashboard>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              final message = error is ApiException
                  ? error.message
                  : 'Failed to load provider dashboard.';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          setState(() => _dashboardFuture = _loadDashboard());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final dashboard = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFF3F5F8),
                      child: IconButton(
                        onPressed: () {
                          ref
                              .read(appModeProvider.notifier)
                              .setMode(AppMode.client);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Provider Home',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8FFF0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        dashboard.isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Incoming requests',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${dashboard.incomingRequests.length} new jobs waiting',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Switch back to client mode anytime from the back button.',
                        style: TextStyle(color: Colors.white, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ProviderStat(
                        label: 'Today earnings',
                        value: 'KES ${dashboard.todayEarnings.toStringAsFixed(0)}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProviderStat(
                        label: 'Completed jobs',
                        value: dashboard.completedJobs.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Incoming Request Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                ...dashboard.incomingRequests.map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFFFF4),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_outlined,
                                  color: AppColors.green,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.clientName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${request.serviceName} • ${request.locationLabel}',
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${request.scheduledAtUtc == null ? 'Instant booking' : _formatDateTime(request.scheduledAtUtc!.toLocal())} • Budget ${request.currency} ${request.budgetAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.slate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateStatus(
                                    requestId: request.requestId,
                                    status: 'rejected',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    side: const BorderSide(color: AppColors.line),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => _updateStatus(
                                    requestId: request.requestId,
                                    status: 'accepted',
                                  ),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    backgroundColor: AppColors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('Accept Job'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<ProviderDashboard> _loadDashboard() {
    final session = ref.read(authSessionProvider);
    if (session == null) {
      return Future.error('Sign in first.');
    }
    return ref.read(providersApiProvider).getDashboard(session.accessToken);
  }

  Future<void> _updateStatus({
    required String requestId,
    required String status,
  }) async {
    final session = ref.read(authSessionProvider);
    if (session == null) {
      return;
    }
    try {
      await ref.read(serviceRequestsApiProvider).updateStatus(
            bearerToken: session.accessToken,
            id: requestId,
            status: status,
            note: 'Updated from provider mode.',
          );
      if (!mounted) {
        return;
      }
      setState(() => _dashboardFuture = _loadDashboard());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request marked as $status.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class _ProviderStat extends StatelessWidget {
  const _ProviderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final period = value.hour < 12 ? 'AM' : 'PM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} • $hour:$minute $period';
}
