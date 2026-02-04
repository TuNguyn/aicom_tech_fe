import '../../domain/entities/paginated_result.dart';

// Class Generic để parse response từ server
class PaginatedResponseModel<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponseModel({required this.data, required this.meta});

  // Factory parse JSON generic
  // [fromJsonT]: Hàm callback để parse từng item trong list (VD: AppointmentLineModel.fromJson)
  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // 1. Trỏ đúng vào nơi chứa list data (tuỳ backend trả về, thường là data.data)
    // Nếu API trả về trực tiếp { "data": [...], "meta": ... } thì dùng json['data']
    // Nếu API bọc trong { "data": { "data": [...] } } thì phải trỏ sâu hơn
    final dataContent = json['data'] is Map ? json['data'] : json;

    // 2. Parse List Data
    final listData = (dataContent['data'] as List)
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();

    // 3. Parse Meta Data
    final metaData = PaginationMeta.fromJson(dataContent['meta']);

    return PaginatedResponseModel(data: listData, meta: metaData);
  }

  // Hàm map từ Model sang Entity (Domain)
  PaginatedResult<E> toEntity<E>(E Function(T) toEntityCallback) {
    return PaginatedResult<E>(
      data: data.map((item) => toEntityCallback(item)).toList(),
      currentPage: meta.currentPage,
      totalPages: meta.totalPages,
      totalItems: meta.totalItems,
      itemsPerPage: meta.itemsPerPage,
    );
  }
}

// Class chứa thông tin phân trang từ server
class PaginationMeta {
  final int itemsPerPage;
  final int totalItems;
  final int currentPage;
  final int totalPages;

  PaginationMeta({
    required this.itemsPerPage,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
