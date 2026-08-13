class InsightsModel {
  const InsightsModel({
    required this.from,
    required this.to,
    required this.summary,
    required this.topItems,
    required this.topBrands,
    required this.topCategories,
    required this.monthly,
    required this.returns,
  });

  final DateTime from;
  final DateTime to;
  final InsightsSummary summary;
  final List<InsightTopItem> topItems;
  final List<InsightGroup> topBrands;
  final List<InsightGroup> topCategories;
  final List<InsightGroup> monthly;
  final InsightReturns returns;

  factory InsightsModel.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true) {
      throw const FormatException('Unsuccessful insights response');
    }
    final data = _map(json['data'], 'data');
    final period = _map(data['period'], 'data.period');
    return InsightsModel(
      from: _date(period['from'], 'period.from'),
      to: _date(period['to'], 'period.to'),
      summary: InsightsSummary.fromJson(_map(data['summary'], 'summary')),
      topItems: _list(data['top_items'], 'top_items')
          .map((value) => InsightTopItem.fromJson(_map(value, 'top_items[]')))
          .toList(growable: false),
      topBrands: _groups(data['top_brands'], 'top_brands'),
      topCategories: _groups(data['top_categories'], 'top_categories'),
      monthly: _groups(data['monthly'], 'monthly'),
      returns: InsightReturns.fromJson(_map(data['returns'], 'returns')),
    );
  }
}

class InsightsSummary {
  const InsightsSummary({
    required this.totalSpend,
    required this.invoiceCount,
    required this.averageInvoice,
    required this.totalQuantity,
    required this.distinctItems,
    required this.outstanding,
    required this.returnedValue,
    required this.returnCount,
    required this.returnRate,
    required this.currency,
  });

  final num totalSpend;
  final int invoiceCount;
  final num averageInvoice;
  final num totalQuantity;
  final int distinctItems;
  final num outstanding;
  final num returnedValue;
  final int returnCount;
  final num returnRate;
  final String currency;

  factory InsightsSummary.fromJson(Map<String, dynamic> json) =>
      InsightsSummary(
        totalSpend: _num(json['total_spend'], 'summary.total_spend'),
        invoiceCount: _int(json['invoice_count'], 'summary.invoice_count'),
        averageInvoice: _num(
          json['average_invoice'],
          'summary.average_invoice',
        ),
        totalQuantity: _num(json['total_quantity'], 'summary.total_quantity'),
        distinctItems: _int(json['distinct_items'], 'summary.distinct_items'),
        outstanding: _num(json['outstanding'], 'summary.outstanding'),
        returnedValue: _num(json['returned_value'], 'summary.returned_value'),
        returnCount: _int(json['return_count'], 'summary.return_count'),
        returnRate: _num(json['return_rate_pct'], 'summary.return_rate_pct'),
        currency: _string(json['currency'], 'summary.currency'),
      );
}

class InsightTopItem {
  const InsightTopItem({
    required this.rank,
    required this.itemCode,
    required this.name,
    required this.revenue,
    required this.quantity,
    required this.purchaseCount,
    required this.lastPurchase,
    required this.averageUnitPrice,
    required this.share,
  });

  final int rank;
  final String itemCode;
  final String name;
  final num revenue;
  final num quantity;
  final int purchaseCount;
  final DateTime lastPurchase;
  final num averageUnitPrice;
  final num share;

  factory InsightTopItem.fromJson(Map<String, dynamic> json) => InsightTopItem(
    rank: _int(json['rank'], 'top_item.rank'),
    itemCode: _string(json['item_code'], 'top_item.item_code'),
    name: _string(json['name'], 'top_item.name'),
    revenue: _num(json['revenue'], 'top_item.revenue'),
    quantity: _num(json['quantity'], 'top_item.quantity'),
    purchaseCount: _int(json['purchase_count'], 'top_item.purchase_count'),
    lastPurchase: _date(json['last_purchase'], 'top_item.last_purchase'),
    averageUnitPrice: _num(json['avg_unit_price'], 'top_item.avg_unit_price'),
    share: _num(json['share_pct'], 'top_item.share_pct'),
  );
}

class InsightGroup {
  const InsightGroup({
    required this.key,
    required this.revenue,
    required this.quantity,
    required this.invoiceCount,
    required this.itemCount,
    required this.share,
  });

  final String key;
  final num revenue;
  final num quantity;
  final int invoiceCount;
  final int itemCount;
  final num share;

  factory InsightGroup.fromJson(Map<String, dynamic> json) => InsightGroup(
    key: _string(json['key'], 'group.key'),
    revenue: _num(json['revenue'], 'group.revenue'),
    quantity: _num(json['quantity'], 'group.quantity'),
    invoiceCount: _int(json['invoice_count'], 'group.invoice_count'),
    itemCount: _int(json['item_count'], 'group.item_count'),
    share: _num(json['share_pct'], 'group.share_pct'),
  );
}

class InsightReturns {
  const InsightReturns({
    required this.invoicedAmount,
    required this.returnedAmount,
    required this.ratio,
    required this.invoiceCount,
    required this.creditNoteCount,
  });

  final num invoicedAmount;
  final num returnedAmount;
  final num ratio;
  final int invoiceCount;
  final int creditNoteCount;

  factory InsightReturns.fromJson(Map<String, dynamic> json) => InsightReturns(
    invoicedAmount: _num(json['invoiced_amount'], 'returns.invoiced_amount'),
    returnedAmount: _num(json['returned_amount'], 'returns.returned_amount'),
    ratio: _num(json['returns_ratio_pct'], 'returns.returns_ratio_pct'),
    invoiceCount: _int(json['invoice_count'], 'returns.invoice_count'),
    creditNoteCount: _int(
      json['credit_note_count'],
      'returns.credit_note_count',
    ),
  );
}

List<InsightGroup> _groups(Object? value, String field) => _list(value, field)
    .map((item) => InsightGroup.fromJson(_map(item, '$field[]')))
    .toList(growable: false);

Map<String, dynamic> _map(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$field must be an object');
}

List<Object?> _list(Object? value, String field) {
  if (value is List) return value.cast<Object?>();
  throw FormatException('$field must be an array');
}

String _string(Object? value, String field) {
  if (value is String && value.isNotEmpty) return value;
  if (value is num) return value.toString();
  throw FormatException('$field must be a non-empty string');
}

num _num(Object? value, String field) {
  if (value is num) return value;
  throw FormatException('$field must be a number');
}

int _int(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer');
}

DateTime _date(Object? value, String field) {
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('$field must be a date');
}
