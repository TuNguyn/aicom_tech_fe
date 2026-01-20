// Shared pagination models used for paginated API responses
// These are infrastructure models that can be reused across different features

class PaginationMeta {
  final int itemsPerPage;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final List<List<String>> sortBy;

  PaginationMeta({
    required this.itemsPerPage,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.sortBy,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      itemsPerPage: json['itemsPerPage'] as int,
      totalItems: json['totalItems'] as int,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      sortBy: (json['sortBy'] as List<dynamic>)
          .map((item) => (item as List<dynamic>).cast<String>())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemsPerPage': itemsPerPage,
      'totalItems': totalItems,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'sortBy': sortBy,
    };
  }
}

class PaginationLinks {
  final String current;

  PaginationLinks({required this.current});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      current: json['current'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
    };
  }
}
