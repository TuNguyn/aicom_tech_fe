import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_line.dart';
import '../../domain/usecases/appointments/get_appointment_lines.dart';

// [STATE] Cấu trúc phẳng hỗ trợ Infinite Scroll và Home Page Count riêng biệt
class AppointmentsState {
  final List<AppointmentLine>
  appointments; // Danh sách hiển thị ở trang Appointments
  final AsyncValue<void> loadingStatus;
  final int page; // Trang hiện tại
  final bool hasMore; // Server còn dữ liệu trang sau không?
  final bool isLoadingMore; // Đang load trang tiếp theo?
  final int totalCount; // Tổng số lượng của danh sách đang xem (theo ngày chọn)
  final int
  todayCount; // [MỚI] Tổng số lượng của ngày HÔM NAY (dùng cho Home Page)
  final DateTime? selectedDate; // Ngày đang chọn

  AppointmentsState({
    this.appointments = const [],
    this.loadingStatus = const AsyncValue.data(null),
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.totalCount = 0,
    this.todayCount = 0, // Mặc định 0
    this.selectedDate,
  });

  AppointmentsState copyWith({
    List<AppointmentLine>? appointments,
    AsyncValue<void>? loadingStatus,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    int? totalCount,
    int? todayCount,
    DateTime? selectedDate,
  }) {
    return AppointmentsState(
      appointments: appointments ?? this.appointments,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalCount: totalCount ?? this.totalCount,
      todayCount: todayCount ?? this.todayCount,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final GetAppointmentLines _getAppointmentLines;

  AppointmentsNotifier(this._getAppointmentLines)
    : super(AppointmentsState(selectedDate: DateTime.now()));

  // --- 1. Hàm load danh sách (Dùng cho Appointments Page) ---
  Future<void> fetchAppointments({
    required DateTime startDate,
    required DateTime endDate,
    bool isRefresh = false,
  }) async {
    // Chặn nếu đang load dở hoặc đã hết dữ liệu (khi load more)
    if (state.isLoadingMore || (!isRefresh && !state.hasMore)) return;

    if (isRefresh) {
      // Refresh: Reset về trang 1, hiện loading to, xóa list cũ
      state = state.copyWith(
        loadingStatus: const AsyncValue.loading(),
        page: 1,
        hasMore: true,
        appointments: [],
        totalCount: 0,
      );
    } else {
      // Load More: Hiện spinner nhỏ ở đáy
      state = state.copyWith(isLoadingMore: true);
    }

    // Xác định trang cần gọi
    final nextPage = isRefresh ? 1 : state.page + 1;

    // Gọi API
    final result = await _getAppointmentLines(
      startDate: startDate,
      endDate: endDate,
      page: nextPage,
      limit: 20, // Load 20 items mỗi lần
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          loadingStatus: AsyncValue.error(failure.message, StackTrace.current),
          isLoadingMore: false,
        );
      },
      (paginatedResult) {
        state = state.copyWith(
          loadingStatus: const AsyncValue.data(null),
          // Nếu refresh: lấy list mới. Nếu load more: nối đuôi list cũ.
          appointments: isRefresh
              ? paginatedResult.data
              : [...state.appointments, ...paginatedResult.data],
          page: paginatedResult.currentPage,
          hasMore: paginatedResult.hasNextPage,
          isLoadingMore: false,
          totalCount:
              paginatedResult.totalItems, // Update totalCount cho list đang xem
        );
      },
    );
  }

  // --- 2. Hàm chỉ lấy số lượng hôm nay (Dùng cho Home Page) ---
  Future<void> fetchTodayCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Gọi API với limit=1 (tối ưu) chỉ để lấy meta.totalItems
    final result = await _getAppointmentLines(
      startDate: startOfDay,
      endDate: endOfDay,
      page: 1,
      limit: 1,
    );

    result.fold(
      (failure) => null, // Fail silently
      (paginatedResult) {
        // Chỉ update todayCount, KHÔNG ảnh hưởng list appointments
        state = state.copyWith(todayCount: paginatedResult.totalItems);
      },
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void reset() {
    state = AppointmentsState(selectedDate: DateTime.now());
  }

  // --- 3. SOCKET UPDATE LOGIC (Đã sửa lại để update cả Today Count) ---

  void onAppointmentReceived(AppointmentLine incomingAppointment) {
    // A. Cập nhật vào List hiển thị (nếu đang xem)
    final currentList = List<AppointmentLine>.from(state.appointments);
    final index = currentList.indexWhere(
      (app) => app.id == incomingAppointment.id,
    );

    // Biến tạm để cập nhật totalCount (của list đang xem)
    int newTotalCount = state.totalCount;

    if (index != -1) {
      // Update: Thay thế item cũ
      currentList[index] = incomingAppointment;
    } else {
      // Insert: Thêm vào đầu danh sách
      currentList.insert(0, incomingAppointment);
      // Sort lại theo thời gian
      currentList.sort((a, b) => a.beginTime.compareTo(b.beginTime));
      // Tăng số lượng list đang xem lên 1
      newTotalCount += 1;
    }

    // B. [FIX LỖI] Cập nhật todayCount (cho Home Page)
    final now = DateTime.now();
    final isToday =
        incomingAppointment.beginTime.year == now.year &&
        incomingAppointment.beginTime.month == now.month &&
        incomingAppointment.beginTime.day == now.day;

    int newTodayCount = state.todayCount;
    // Nếu là item mới (index == -1) VÀ là ngày hôm nay -> Tăng count cho Home Page
    if (isToday && index == -1) {
      newTodayCount += 1;
    }

    state = state.copyWith(
      appointments: currentList,
      totalCount: newTotalCount,
      todayCount: newTodayCount,
    );
  }

  void removeAppointment(String targetAppointmentId) {
    final currentList = List<AppointmentLine>.from(state.appointments);
    final initialLength = currentList.length;

    currentList.removeWhere((app) => app.appointmentId == targetAppointmentId);

    // Nếu có sự thay đổi trong list
    if (currentList.length != initialLength) {
      state = state.copyWith(
        appointments: currentList,
        // Giảm totalCount của list đang xem
        totalCount: (state.totalCount > 0) ? state.totalCount - 1 : 0,
      );
    }

    // [FIX LỖI] Luôn refresh lại todayCount để đảm bảo Home Page chính xác
    // (Vì item bị xóa có thể thuộc ngày hôm nay nhưng không nằm trong list đang xem)
    fetchTodayCount();
  }
}
