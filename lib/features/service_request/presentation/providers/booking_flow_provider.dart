import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/core/utils/mock_data.dart';

final bookingFlowProvider =
    NotifierProvider<BookingFlowNotifier, BookingFlowState>(
      BookingFlowNotifier.new,
    );

@immutable
class BookingFlowState {
  const BookingFlowState({
    this.serviceType,
    this.selectedProvider,
    this.scheduledDateTime,
    this.isConfirmed = false,
    this.confirmedAt,
  });

  final String? serviceType;
  final ProviderPreview? selectedProvider;
  final DateTime? scheduledDateTime;
  final bool isConfirmed;
  final DateTime? confirmedAt;

  bool get hasProviderSelection => selectedProvider != null;
  bool get isScheduledBooking => scheduledDateTime != null;

  BookingFlowState copyWith({
    String? serviceType,
    ProviderPreview? selectedProvider,
    DateTime? scheduledDateTime,
    bool clearSchedule = false,
    bool? isConfirmed,
    DateTime? confirmedAt,
    bool clearConfirmation = false,
  }) {
    return BookingFlowState(
      serviceType: serviceType ?? this.serviceType,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      scheduledDateTime: clearSchedule
          ? null
          : scheduledDateTime ?? this.scheduledDateTime,
      isConfirmed: clearConfirmation ? false : isConfirmed ?? this.isConfirmed,
      confirmedAt: clearConfirmation ? null : confirmedAt ?? this.confirmedAt,
    );
  }
}

class BookingFlowNotifier extends Notifier<BookingFlowState> {
  @override
  BookingFlowState build() => const BookingFlowState();

  void startFlow({
    required String serviceType,
    DateTime? scheduledDateTime,
  }) {
    state = BookingFlowState(
      serviceType: serviceType,
      scheduledDateTime: scheduledDateTime,
    );
  }

  void selectProvider(ProviderPreview provider) {
    state = state.copyWith(
      selectedProvider: provider,
      serviceType: provider.service,
      clearConfirmation: true,
    );
  }

  void setSchedule(DateTime? scheduledDateTime) {
    state = state.copyWith(
      scheduledDateTime: scheduledDateTime,
      clearSchedule: scheduledDateTime == null,
      clearConfirmation: true,
    );
  }

  void confirmRequest() {
    state = state.copyWith(
      isConfirmed: true,
      confirmedAt: DateTime.now(),
    );
  }

  void reset() {
    state = const BookingFlowState();
  }
}
