import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app_providers.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/features/home/presentation/providers/schedule_provider.dart';
import 'package:wirasasa/features/map_discovery/presentation/models/map_discovery_arguments.dart';
import 'package:wirasasa/features/service_request/presentation/providers/booking_flow_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;
  late Future<List<ServiceCategory>> _servicesFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _servicesFuture = ref.read(catalogApiProvider).getServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<ServiceCategory>>(
          future: _servicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              final message = error is ApiException
                  ? error.message
                  : 'Failed to load services.';
              return _LoadErrorState(
                message: message,
                onRetry: () {
                  setState(() {
                    _servicesFuture = ref.read(catalogApiProvider).getServices();
                  });
                },
              );
            }

            final services = snapshot.data ?? const <ServiceCategory>[];
            final grouped = <String, List<ServiceCategory>>{};
            for (final category in services) {
              grouped.putIfAbsent(category.group, () => []).add(category);
            }

            final normalizedQuery = _query.trim().toLowerCase();
            final results = normalizedQuery.isEmpty
                ? services
                : services.where((category) {
                    return category.name.toLowerCase().contains(normalizedQuery) ||
                        category.group.toLowerCase().contains(normalizedQuery) ||
                        category.code.toLowerCase().contains(normalizedQuery);
                  }).toList();
            final isSearching = normalizedQuery.isNotEmpty;
            final recentServices = services.take(2).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _SearchBar(
                  controller: _searchController,
                  isScheduled: scheduleState.isScheduledBooking,
                  scheduledTime: scheduleState.scheduledTime,
                  onChanged: (value) => setState(() => _query = value),
                  onSubmitted: (value) {
                    final match = results.isNotEmpty ? results.first : null;
                    if (match != null) {
                      _openService(match);
                    }
                  },
                  onLaterTap: _openSchedulingModal,
                ),
                if (scheduleState.isScheduledBooking &&
                    scheduleState.scheduledTime != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFFFF4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, color: AppColors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Scheduled for ${_formatDateTime(scheduleState.scheduledTime!)}',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                if (isSearching) ...[
                  const Text(
                    'Search results',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'No services found from the catalog response.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  else
                    ...results.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RecentServiceTile(
                          category: category,
                          onTap: () => _openService(category),
                        ),
                      ),
                    ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FA),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Services',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...recentServices.map(
                          (service) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecentServiceTile(
                              category: service,
                              onTap: () => _openService(service),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final entry in grouped.entries) ...[
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      categories: entry.value,
                      onTap: _openService,
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openSchedulingModal() async {
    final schedule = ref.read(scheduleProvider);
    DateTime selectedDate = schedule.scheduledTime ?? DateTime.now();
    TimeOfDay selectedTime = schedule.scheduledTime == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay.fromDateTime(schedule.scheduledTime!);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF2FFF4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Schedule service',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Pick date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateChanged: (value) {
                        setModalState(() => selectedDate = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Time',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatTime(selectedTime),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(scheduleProvider.notifier).clear();
                            ref.read(bookingFlowProvider.notifier).setSchedule(
                              null,
                            );
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            side: const BorderSide(color: AppColors.line),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final scheduled = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                            ref
                                .read(scheduleProvider.notifier)
                                .setSchedule(scheduled);
                            ref
                                .read(bookingFlowProvider.notifier)
                                .setSchedule(scheduled);
                            Navigator.pop(context);
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            backgroundColor: AppColors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openService(ServiceCategory service) {
    final scheduleState = ref.read(scheduleProvider);
    ref
        .read(bookingFlowProvider.notifier)
        .startFlow(
          serviceCode: service.code,
          serviceName: service.name,
          scheduledDateTime: scheduleState.isScheduledBooking
              ? scheduleState.scheduledTime
              : null,
        );
    Navigator.pushNamed(
      context,
      AppRouter.mapDiscovery,
      arguments: MapDiscoveryArguments(
        serviceCode: service.code,
        serviceName: service.name,
        scheduledDateTime: scheduleState.isScheduledBooking
            ? scheduleState.scheduledTime
            : null,
        initialQuery: _query.isEmpty ? service.name : _query,
      ),
    );
  }
}

class _LoadErrorState extends StatelessWidget {
  const _LoadErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onLaterTap,
    required this.isScheduled,
    required this.scheduledTime,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final Future<void> Function() onLaterTap;
  final bool isScheduled;
  final DateTime? scheduledTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.green, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: isScheduled && scheduledTime != null
                    ? 'Scheduled: ${_formatShortDateTime(scheduledTime!)}'
                    : 'Which service do you need?',
                border: InputBorder.none,
                isCollapsed: true,
                filled: false,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onLaterTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Later',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentServiceTile extends StatelessWidget {
  const _RecentServiceTile({required this.category, required this.onTap});

  final ServiceCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.icon, color: category.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.description,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.onTap});

  final List<ServiceCategory> categories;
  final ValueChanged<ServiceCategory> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isWide = categories.length == 1;
        return SizedBox(
          width: isWide
              ? MediaQuery.of(context).size.width - 40
              : (MediaQuery.of(context).size.width - 52) / 2,
          child: InkWell(
            onTap: () => onTap(category),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(category.icon, color: category.color, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.description,
                    style: const TextStyle(color: AppColors.muted, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

String _formatTime(TimeOfDay value) {
  final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _formatDateTime(DateTime value) {
  return '${value.day}/${value.month}/${value.year} • ${_formatTime(TimeOfDay.fromDateTime(value))}';
}

String _formatShortDateTime(DateTime value) {
  return '${value.day}/${value.month} ${_formatTime(TimeOfDay.fromDateTime(value))}';
}
