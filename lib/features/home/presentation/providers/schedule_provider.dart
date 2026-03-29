import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleProvider = NotifierProvider<ScheduleNotifier, ScheduleState>(
  ScheduleNotifier.new,
);

@immutable
class ScheduleState {
  const ScheduleState({
    required this.scheduledTime,
    required this.isScheduledBooking,
  });

  final DateTime? scheduledTime;
  final bool isScheduledBooking;
}

class ScheduleNotifier extends Notifier<ScheduleState> {
  @override
  ScheduleState build() {
    return const ScheduleState(scheduledTime: null, isScheduledBooking: false);
  }

  void setSchedule(DateTime scheduledTime) {
    state = ScheduleState(
      scheduledTime: scheduledTime,
      isScheduledBooking: true,
    );
  }

  void clear() {
    state = const ScheduleState(scheduledTime: null, isScheduledBooking: false);
  }
}
