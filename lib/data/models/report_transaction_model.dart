import 'common/pagination_models.dart';

/// Model for individual transaction item
class ReportTransactionModel {
  final String id;
  final String ticketCode;
  final String itemName;
  final int qty;
  final double price;
  final double total;
  final double tips;
  final double commission;
  final DateTime createdAt;

  ReportTransactionModel({
    required this.id,
    required this.ticketCode,
    required this.itemName,
    required this.qty,
    required this.price,
    required this.total,
    required this.tips,
    required this.commission,
    required this.createdAt,
  });

  factory ReportTransactionModel.fromJson(Map<String, dynamic> json) {
    return ReportTransactionModel(
      id: json['id'] as String,
      ticketCode: json['ticketCode'] as String,
      itemName: json['itemName'] as String,
      qty: json['qty'] as int,
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      tips: (json['tips'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketCode': ticketCode,
      'itemName': itemName,
      'qty': qty,
      'price': price,
      'total': total,
      'tips': tips,
      'commission': commission,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Summary model for aggregated data
class ReportSummaryModel {
  final double totalSales;
  final double totalTips;
  final double totalCommission;

  ReportSummaryModel({
    required this.totalSales,
    required this.totalTips,
    required this.totalCommission,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalSales: (json['totalSales'] as num).toDouble(),
      totalTips: (json['totalTips'] as num).toDouble(),
      totalCommission: (json['totalCommission'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalTips': totalTips,
      'totalCommission': totalCommission,
    };
  }
}

/// Response wrapper with pagination and summary
class ReportTransactionsResponse {
  final List<ReportTransactionModel> data;
  final PaginationMeta meta;
  final PaginationLinks links;
  final ReportSummaryModel summary;

  ReportTransactionsResponse({
    required this.data,
    required this.meta,
    required this.links,
    required this.summary,
  });

  factory ReportTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>;

    return ReportTransactionsResponse(
      data: (dataMap['data'] as List<dynamic>)
          .map((item) => ReportTransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(dataMap['meta'] as Map<String, dynamic>),
      links: PaginationLinks.fromJson(dataMap['links'] as Map<String, dynamic>),
      summary: ReportSummaryModel.fromJson(dataMap['summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'data': data.map((item) => item.toJson()).toList(),
        'meta': meta.toJson(),
        'links': links.toJson(),
        'summary': summary.toJson(),
      },
    };
  }
}
