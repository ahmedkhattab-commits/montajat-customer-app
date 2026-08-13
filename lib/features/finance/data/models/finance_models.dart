class FinanceSummaryModel {
  const FinanceSummaryModel({
    required this.creditLimit,
    required this.creditUsed,
    required this.creditAvailable,
    required this.currentBalance,
    required this.overdue,
    required this.currency,
    required this.aging,
  });

  final double creditLimit;
  final double creditUsed;
  final double creditAvailable;
  final double currentBalance;
  final double overdue;
  final String currency;
  final List<FinanceAgingBucket> aging;

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) {
    final credit = _map(json['credit']);
    final agingData = json['aging'];
    final buckets = agingData is List
        ? agingData
              .whereType<Map>()
              .map((e) => FinanceAgingBucket.fromJson(e.cast()))
              .toList()
        : _map(agingData).entries
              .where(
                (entry) =>
                    entry.value is num ||
                    double.tryParse('${entry.value}') != null,
              )
              .map(
                (entry) => FinanceAgingBucket(
                  label: entry.key,
                  amount: _number(entry.value),
                ),
              )
              .toList();
    return FinanceSummaryModel(
      creditLimit: _number(credit['limit'] ?? json['credit_limit']),
      creditUsed: _number(credit['used'] ?? json['credit_used']),
      creditAvailable: _number(credit['available'] ?? json['credit_available']),
      currentBalance: _number(
        json['current_balance'] ?? json['balance'] ?? credit['current_balance'],
      ),
      overdue: _number(
        json['overdue'] ?? json['overdue_balance'] ?? credit['overdue'],
      ),
      currency: _text(json['currency'] ?? credit['currency']) ?? 'SAR',
      aging: buckets,
    );
  }
}

class FinanceAgingBucket {
  const FinanceAgingBucket({required this.label, required this.amount});
  final String label;
  final double amount;

  factory FinanceAgingBucket.fromJson(Map<String, dynamic> json) =>
      FinanceAgingBucket(
        label: _text(json['label'] ?? json['bucket'] ?? json['name']) ?? '-',
        amount: _number(json['amount'] ?? json['balance'] ?? json['value']),
      );
}

class FinanceDocumentModel {
  const FinanceDocumentModel({
    required this.number,
    required this.amount,
    required this.currency,
    required this.status,
    this.date,
    this.dueDate,
    this.description,
  });

  final String number;
  final double amount;
  final String currency;
  final String status;
  final DateTime? date;
  final DateTime? dueDate;
  final String? description;

  factory FinanceDocumentModel.fromJson(
    Map<String, dynamic> json,
  ) => FinanceDocumentModel(
    number:
        _text(
          json['doc_num'] ?? json['doc_number'] ?? json['number'] ?? json['id'],
        ) ??
        '-',
    amount: _number(
      json['amount'] ?? json['total'] ?? json['balance'] ?? json['grand_total'],
    ),
    currency: _text(json['currency']) ?? 'SAR',
    status: _text(json['status'] ?? json['payment_status']) ?? '-',
    date: _date(json['date'] ?? json['doc_date'] ?? json['created_at']),
    dueDate: _date(json['due_date']),
    description: _text(json['description'] ?? json['remarks'] ?? json['memo']),
  );
}

class FinanceInvoiceDetailsModel {
  const FinanceInvoiceDetailsModel({
    required this.invoice,
    required this.taxRows,
    required this.lines,
  });
  final FinanceDocumentModel invoice;
  final List<FinanceValueRow> taxRows;
  final List<FinanceInvoiceLine> lines;

  factory FinanceInvoiceDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawTaxes = json['tax_breakdown'] ?? json['taxes'];
    final rawLines = json['lines'] ?? json['items'];
    return FinanceInvoiceDetailsModel(
      invoice: FinanceDocumentModel.fromJson(json),
      taxRows: rawTaxes is List
          ? rawTaxes
                .whereType<Map>()
                .map((e) => FinanceValueRow.fromJson(e.cast()))
                .toList()
          : _map(rawTaxes).entries
                .map(
                  (e) => FinanceValueRow(label: e.key, value: _number(e.value)),
                )
                .toList(),
      lines: rawLines is List
          ? rawLines
                .whereType<Map>()
                .map((e) => FinanceInvoiceLine.fromJson(e.cast()))
                .toList()
          : const [],
    );
  }
}

class FinanceValueRow {
  const FinanceValueRow({required this.label, required this.value});
  final String label;
  final double value;
  factory FinanceValueRow.fromJson(Map<String, dynamic> json) =>
      FinanceValueRow(
        label: _text(json['label'] ?? json['name'] ?? json['type']) ?? '-',
        value: _number(json['amount'] ?? json['value']),
      );
}

class FinanceInvoiceLine {
  const FinanceInvoiceLine({
    required this.name,
    required this.quantity,
    required this.total,
  });
  final String name;
  final double quantity;
  final double total;
  factory FinanceInvoiceLine.fromJson(Map<String, dynamic> json) =>
      FinanceInvoiceLine(
        name:
            _text(
              json['name'] ??
                  json['item_name'] ??
                  json['description'] ??
                  json['item_code'],
            ) ??
            '-',
        quantity: _number(json['quantity']),
        total: _number(json['total'] ?? json['line_total']),
      );
}

Map<String, dynamic> _map(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : const {};

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

double _number(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

DateTime? _date(Object? value) => DateTime.tryParse(_text(value) ?? '');
