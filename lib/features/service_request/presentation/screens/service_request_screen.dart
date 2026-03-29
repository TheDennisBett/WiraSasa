import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/features/service_request/presentation/providers/booking_flow_provider.dart';
import 'package:wirasasa/shared_widgets/primary_button.dart';
import 'package:wirasasa/shared_widgets/section_header.dart';
import 'package:wirasasa/shared_widgets/surface_card.dart';

class ServiceRequestScreen extends ConsumerStatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  ConsumerState<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends ConsumerState<ServiceRequestScreen> {
  static const List<TimeOfDay> _timeSlots = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
  ];

  DateTime? _selectedSchedule;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedSchedule ??= ref.read(bookingFlowProvider).scheduledDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final bookingFlow = ref.watch(bookingFlowProvider);
    final provider = bookingFlow.selectedProvider;
    final serviceType = bookingFlow.serviceType;

    if (provider == null || serviceType == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule Service')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Select a provider from discovery before opening the request flow.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final effectiveSchedule = _selectedSchedule ?? bookingFlow.scheduledDateTime;
    final selectedDayKey = _dayKeyFor(effectiveSchedule);
    final selectedSlot = effectiveSchedule == null
        ? null
        : TimeOfDay.fromDateTime(effectiveSchedule);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Service')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader(title: 'Choose day'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ChoicePill(
                label: 'Today',
                isSelected: selectedDayKey == 'today',
                onTap: () => _selectDay(DateTime.now()),
              ),
              _ChoicePill(
                label: 'Tomorrow',
                isSelected: selectedDayKey == 'tomorrow',
                onTap: () => _selectDay(DateTime.now().add(const Duration(days: 1))),
              ),
              _ChoicePill(
                label: effectiveSchedule == null
                    ? 'Pick date'
                    : _formatDate(effectiveSchedule),
                isSelected: selectedDayKey == 'custom',
                onTap: _pickCustomDate,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Choose time'),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((slot) {
                return _ChoicePill(
                  label: _formatTime(slot),
                  isSelected:
                      selectedSlot?.hour == slot.hour &&
                      selectedSlot?.minute == slot.minute,
                  onTap: () => _selectTime(slot),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request Summary',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  '$serviceType • ${provider.name}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  effectiveSchedule == null
                      ? 'Instant booking. Provider arrives ${provider.eta.replaceAll(' ETA', '')} after acceptance.'
                      : 'Scheduled for ${_formatSchedule(effectiveSchedule)}',
                  style: const TextStyle(color: AppColors.slate, height: 1.35),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.distance} • KES${provider.pricePerHour}/hr',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (bookingFlow.isConfirmed) ...[
            const SizedBox(height: 24),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.green),
                      SizedBox(width: 8),
                      Text(
                        'Confirmed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${provider.name} has been locked for ${bookingFlow.serviceType}.',
                    style: const TextStyle(color: AppColors.slate, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    effectiveSchedule == null
                        ? 'Booking type: Instant'
                        : 'Booking type: Scheduled for ${_formatSchedule(effectiveSchedule)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (bookingFlow.confirmedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Confirmed at ${_formatSchedule(bookingFlow.confirmedAt!)}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: bookingFlow.isConfirmed ? 'Request Confirmed' : 'Confirm Request',
            onPressed: bookingFlow.isConfirmed ? null : _confirmRequest,
          ),
        ],
      ),
    );
  }

  void _selectDay(DateTime day) {
    final base = _selectedSchedule ?? DateTime.now();
    final next = DateTime(
      day.year,
      day.month,
      day.day,
      base.hour,
      base.minute,
    );
    setState(() => _selectedSchedule = next);
    ref.read(bookingFlowProvider.notifier).setSchedule(next);
  }

  void _selectTime(TimeOfDay time) {
    final base = _selectedSchedule ?? DateTime.now();
    final next = DateTime(
      base.year,
      base.month,
      base.day,
      time.hour,
      time.minute,
    );
    setState(() => _selectedSchedule = next);
    ref.read(bookingFlowProvider.notifier).setSchedule(next);
  }

  Future<void> _pickCustomDate() async {
    final current = _selectedSchedule ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }
    _selectDay(picked);
  }

  void _confirmRequest() {
    ref.read(bookingFlowProvider.notifier).confirmRequest();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request confirmed with the selected provider.'),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFE5F7EB) : AppColors.mist,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.green : AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

String _dayKeyFor(DateTime? value) {
  if (value == null) {
    return '';
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final normalized = DateTime(value.year, value.month, value.day);
  if (normalized == today) {
    return 'today';
  }
  if (normalized == tomorrow) {
    return 'tomorrow';
  }
  return 'custom';
}

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}';
}

String _formatTime(TimeOfDay value) {
  final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _formatSchedule(DateTime value) {
  final date = _formatDate(value);
  return '$date • ${_formatTime(TimeOfDay.fromDateTime(value))}';
}
