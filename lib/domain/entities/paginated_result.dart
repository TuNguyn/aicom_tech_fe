// Class này dùng chung cho mọi Entity (AppointmentLine, Ticket, Product...)
class PaginatedResult<T> {
  final List<T> data; // Danh sách dữ liệu (VD: List<AppointmentLine>)
  final int currentPage; // Trang hiện tại
  final int totalPages; // Tổng số trang
  final int totalItems; // Tổng số bản ghi
  final int itemsPerPage; // Số item trên 1 trang

  const PaginatedResult({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  // Helper: Kiểm tra xem còn trang sau không
  bool get hasNextPage => currentPage < totalPages;
}
