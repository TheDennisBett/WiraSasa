import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/core/network/api_models.dart';

final bookingFlowProvider =
    NotifierProvider<BookingFlowNotifier, BookingFlowState>(
      BookingFlowNotifier.new,
    );

@immutable
class BookingFlowState {
  const BookingFlowState({
    this.serviceCode,
    this.serviceName,
    this.selectedProvider,
    this.scheduledDateTime,
    this.lastCreatedRequest,
    this.isConfirmed = false,
    this.confirmedAt,
  });

  final String? serviceCode;
  final String? serviceName;
  final ProviderSummary? selectedProvider;
  final DateTime? scheduledDateTime;
  final ServiceRequest? lastCreatedRequest;
  final bool isConfirmed;
  final DateTime? confirmedAt;

  bool get hasProviderSelection => selectedProvider != null;
  bool get isScheduledBooking => scheduledDateTime != null;

  BookingFlowState copyWith({
    String? serviceCode,
    String? serviceName,
    ProviderSummary? selectedProvider,
    DateTime? scheduledDateTime,
    bool clearSchedule = false,
    ServiceRequest? lastCreatedRequest,
    bool clearCreatedRequest = false,
    bool? isConfirmed,
    DateTime? confirmedAt,
    bool clearConfirmation = false,
  }) {
    return BookingFlowState(
      serviceCode: serviceCode ?? this.serviceCode,
      serviceName: serviceName ?? this.serviceName,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      scheduledDateTime: clearSchedule
          ? null
          : scheduledDateTime ?? this.scheduledDateTime,
      lastCreatedRequest: clearCreatedRequest
          ? null
          : lastCreatedRequest ?? this.lastCreatedRequest,
      isConfirmed: clearConfirmation ? false : isConfirmed ?? this.isConfirmed,
      confirmedAt: clearConfirmation ? null : confirmedAt ?? this.confirmedAt,
    );
  }
}

class BookingFlowNotifier extends Notifier<BookingFlowState> {
  @override
  BookingFlowState build() => const BookingFlowState();

  void startFlow({
    required String serviceCode,
    required String serviceName,
    DateTime? scheduledDateTime,
  }) {
    state = BookingFlowState(
      serviceCode: serviceCode,
      serviceName: serviceName,
      scheduledDateTime: scheduledDateTime,
    );
  }

  void selectProvider(ProviderSummary provider) {
    state = state.copyWith(
      selectedProvider: provider,
      serviceCode: provider.primaryService?.serviceCode ?? state.serviceCode,
      serviceName: provider.primaryService?.serviceName ?? state.serviceName,
      clearCreatedRequest: true,
      clearConfirmation: true,
    );
  }

  void setSchedule(DateTime? scheduledDateTime) {
    state = state.copyWith(
      scheduledDateTime: scheduledDateTime,
      clearSchedule: scheduledDateTime == null,
      clearCreatedRequest: true,
      clearConfirmation: true,
    );
  }

  void setCreatedRequest(ServiceRequest request) {
    state = state.copyWith(
      lastCreatedRequest: request,
      isConfirmed: true,
      confirmedAt: DateTime.now(),
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
