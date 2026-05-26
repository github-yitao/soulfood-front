import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';

class OrderOverview {
  OrderOverview({
    required this.orderCount,
    required this.totalAmount,
    required this.topCategory,
    required this.days,
    required this.hasDemoOrders,
  });

  final int orderCount;
  final double totalAmount;
  final String topCategory;
  final List<OrderDayGroup> days;
  final bool hasDemoOrders;

  factory OrderOverview.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as List<dynamic>? ?? [];
    return OrderOverview(
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      topCategory: json['topCategory'] as String? ?? '—',
      hasDemoOrders: json['hasDemoOrders'] as bool? ?? false,
      days: daysJson
          .map((e) => OrderDayGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderDayGroup {
  OrderDayGroup({
    required this.dateLabel,
    required this.category,
    required this.items,
  });

  final String dateLabel;
  final String? category;
  final List<OrderItem> items;

  factory OrderDayGroup.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderDayGroup(
      dateLabel: json['dateLabel'] as String? ?? '',
      category: json['category'] as String?,
      items: itemsJson
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderItem {
  OrderItem({
    required this.id,
    required this.restaurantName,
    required this.amount,
    this.category,
    this.itemSummary,
    this.timeText,
    this.statusText,
    this.source,
  });

  final int id;
  final String restaurantName;
  final double amount;
  final String? category;
  final String? itemSummary;
  final String? timeText;
  final String? statusText;
  final String? source;

  bool get isDemo => source == 'demo';

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['id'] as num).toInt(),
      restaurantName: json['restaurantName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String?,
      itemSummary: json['itemSummary'] as String?,
      timeText: json['timeText'] as String?,
      statusText: json['statusText'] as String?,
      source: json['source'] as String?,
    );
  }
}

class OrderRepository {
  OrderRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<OrderOverview> loadOverview({String? category}) async {
    final data = await _api.getData<Map<String, dynamic>>(
      '/api/v1/orders/overview',
      query: category == null ? null : {'category': category},
      parser: (json) => json as Map<String, dynamic>,
    );
    return OrderOverview.fromJson(data);
  }

  Future<void> createManual({
    required String restaurantName,
    required double amount,
    String? category,
    String? itemSummary,
  }) async {
    await _api.postData<Map<String, dynamic>>(
      '/api/v1/orders',
      data: {
        'restaurantName': restaurantName,
        'amount': amount,
        if (category != null && category.isNotEmpty) 'category': category,
        if (itemSummary != null && itemSummary.isNotEmpty) 'itemSummary': itemSummary,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<void> createFromVote({
    required String winnerTitle,
    required double amount,
    String? roomCode,
  }) async {
    await _api.postData<Map<String, dynamic>>(
      '/api/v1/orders/from-vote',
      data: {
        'winnerTitle': winnerTitle,
        'amount': amount,
        if (roomCode != null && roomCode.isNotEmpty) 'roomCode': roomCode,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
