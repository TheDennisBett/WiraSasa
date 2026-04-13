import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app_providers.dart';
import 'package:wirasasa/core/network/api_client.dart';
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

  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  DateTime? _selectedSchedule;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: 'Please help with the requested service.',
    );
    _locationController = TextEditingController(text: 'Westlands');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedSchedule ??= ref.read(bookingFlowProvider).scheduledDateTime;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingFlow = ref.watch(bookingFlowProvider);
    final session = ref.watch(authSessionProvider);
    final provider = bookingFlow.selectedProvider;
    final serviceCode = bookingFlow.serviceCode;
    final serviceName = bookingFlow.serviceName;

    if (provider == null || serviceCode == null || serviceName == null) {
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

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule Service')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Sign in first before creating a service request.',
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
    final primaryService = provider.primaryService;
    final request = bookingFlow.lastCreatedRequest;

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
          const SectionHeader(title: 'Describe the job'),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              children: [
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location label',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                  '$serviceName • ${provider.displayName}',
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
                  '${provider.distance} • ${primaryService?.currency ?? 'KES'}${primaryService?.basePrice.toStringAsFixed(0) ?? '--'}/${primaryService?.pricingUnit ?? 'job'}',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (request != null) ...[
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
                        'Request Created',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Request ID: ${request.id}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${request.status}',
                    style: const TextStyle(color: AppColors.slate),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.scheduledAtUtc == null
                        ? 'Booking type: Instant'
                        : 'Booking type: Scheduled for ${_formatSchedule(request.scheduledAtUtc!.toLocal())}',
                    style: const TextStyle(color: AppColors.slate),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: _isSubmitting
                ? 'Creating Request...'
                : request == null
                    ? 'Confirm Request'
                    : 'Request Created',
            onPressed: _isSubmitting || request != null ? null : _confirmRequest,
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

  Future<void> _confirmRequest() async {
    final bookingFlow = ref.read(bookingFlowProvider);
    final session = ref.read(authSessionProvider);
    final provider = bookingFlow.selectedProvider;
    final serviceCode = bookingFlow.serviceCode;
    final serviceName = bookingFlow.serviceName;
    if (session == null ||
        provider == null ||
        serviceCode == null ||
        serviceName == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final created = await ref.read(serviceRequestsApiProvider).create(
            bearerToken: session.accessToken,
            serviceCode: serviceCode,
            serviceName: serviceName,
            description: _descriptionController.text.trim(),
            locationLabel: _locationController.text.trim(),
            latitude: provider.latitude,
            longitude: provider.longitude,
            scheduledAtUtc: (_selectedSchedule ?? bookingFlow.scheduledDateTime)
                ?.toUtc(),
            budgetAmount:
                provider.primaryService?.basePrice ?? bookingFlow.lastCreatedRequest?.budgetAmount ?? 0,
            currency: provider.primaryService?.currency ?? 'KES',
            providerId: provider.id,
          );
      ref.read(bookingFlowProvider.notifier).setCreatedRequest(created);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${created.id} created successfully.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
