import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_line.dart';
import '../../domain/usecases/appointments/get_appointment_lines.dart';

class AppointmentsState {
  final Map<DateTime, List<AppointmentLine>> appointmentsByDate;
  final AsyncValue<void> loadingStatus;
  final DateTime? selectedDate;

  AppointmentsState({
    this.appointmentsByDate = const {},
    this.loadingStatus = const AsyncValue.data(null),
    this.selectedDate,
  });

  AppointmentsState copyWith({
    Map<DateTime, List<AppointmentLine>>? appointmentsByDate,
    AsyncValue<void>? loadingStatus,
    DateTime? selectedDate,
  }) {
    return AppointmentsState(
      appointmentsByDate: appointmentsByDate ?? this.appointmentsByDate,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  List<AppointmentLine> getAppointmentsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return appointmentsByDate[dateKey] ?? [];
  }
}

class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final GetAppointmentLines _getAppointmentLines;

  bool _isDataLoaded = false;

  AppointmentsNotifier(this._getAppointmentLines)
    : super(AppointmentsState(selectedDate: DateTime.now()));

  Future<void> loadAppointmentsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
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
        _isDataLoaded = true;
      },
      (appointments) {
        final Map<DateTime, List<AppointmentLine>> groupedAppointments = {};

        for (final appointment in appointments) {
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
        _isDataLoaded = true;
      },
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<void> refreshAppointments() async {
    _isDataLoaded = false;

    final now = DateTime.now();
    final weekday = now.weekday;
    final startDate = now.subtract(Duration(days: weekday - 1));
    final endDate = startDate.add(const Duration(days: 6));

    await loadAppointmentsForDateRange(startDate, endDate);
  }

  void reset() {
    _isDataLoaded = false;
    state = AppointmentsState(selectedDate: DateTime.now());
  }
}
