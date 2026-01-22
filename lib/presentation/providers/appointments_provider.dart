import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/appointment_line_model.dart';
import '../../domain/usecases/appointments/get_appointment_lines.dart';

class AppointmentsState {
  final Map<DateTime, List<AppointmentLineModel>> appointmentsByDate;
  final AsyncValue<void> loadingStatus;
  final DateTime? selectedDate;

  AppointmentsState({
    this.appointmentsByDate = const {},
    this.loadingStatus = const AsyncValue.data(null),
    this.selectedDate,
  });

  AppointmentsState copyWith({
    Map<DateTime, List<AppointmentLineModel>>? appointmentsByDate,
    AsyncValue<void>? loadingStatus,
    DateTime? selectedDate,
  }) {
    return AppointmentsState(
      appointmentsByDate: appointmentsByDate ?? this.appointmentsByDate,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  List<AppointmentLineModel> getAppointmentsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return appointmentsByDate[dateKey] ?? [];
  }
}

class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final GetAppointmentLines _getAppointmentLines;

  bool _isDataLoaded = false;

  AppointmentsNotifier(this._getAppointmentLines)
      : super(AppointmentsState(selectedDate: DateTime.now()));

  Future<void> loadAppointmentsForDateRange(DateTime startDate, DateTime endDate) async {
    // Skip if already loaded or currently loading
    if (_isDataLoaded || state.loadingStatus.isLoading) {
      return;
    }

    state = state.copyWith(loadingStatus: const AsyncValue.loading());

    final result = await _getAppointmentLines(
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          loadingStatus: AsyncValue.error(failure.message, StackTrace.current),
        );
        // Don't set _isDataLoaded on error
      },
      (response) {
        // Group appointments by date
        final Map<DateTime, List<AppointmentLineModel>> groupedAppointments = {};

        for (final appointment in response.data) {
          final dateKey = DateTime(
            appointment.beginTime.year,
            appointment.beginTime.month,
            appointment.beginTime.day,
          );

          if (!groupedAppointments.containsKey(dateKey)) {
            groupedAppointments[dateKey] = [];
          }
          groupedAppointments[dateKey]!.add(appointment);
        }

        state = state.copyWith(
          appointmentsByDate: groupedAppointments,
          loadingStatus: const AsyncValue.data(null),
        );
        _isDataLoaded = true; // Mark as loaded on success
      },
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<void> refreshAppointments() async {
    _isDataLoaded = false; // Reset flag to allow reload

    // Reload appointments for current week
    final now = DateTime.now();
    final weekday = now.weekday;
    final startDate = now.subtract(Duration(days: weekday - 1)); // Monday
    final endDate = startDate.add(const Duration(days: 6)); // Sunday

    await loadAppointmentsForDateRange(startDate, endDate);
  }

  /// Reset state and clear all data (called on logout)
  void reset() {
    _isDataLoaded = false;
    state = AppointmentsState(selectedDate: DateTime.now());
  }
}
