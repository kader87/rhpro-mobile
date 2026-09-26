enum InvoiceStatus { draft, issued, paid, cancelled }

extension InvoiceStatusJson on InvoiceStatus {
  static InvoiceStatus fromJson(String value) => InvoiceStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == value,
        orElse: () => InvoiceStatus.draft,
      );

  String get apiName => name.toUpperCase();

  String get label => switch (this) {
        InvoiceStatus.draft => 'Brouillon',
        InvoiceStatus.issued => 'Émise',
        InvoiceStatus.paid => 'Payée',
        InvoiceStatus.cancelled => 'Annulée',
      };
}

class InvoicableEntry {
  InvoicableEntry({required this.entryIds, required this.activityName, required this.amount, required this.note});

  factory InvoicableEntry.fromJson(Map<String, dynamic> json) => InvoicableEntry(
        entryIds: (json['entryIds'] as List<dynamic>).map((e) => e as String).toList(),
        activityName: json['activityName'] as String,
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] as String? ?? '',
      );

  final List<String> entryIds;
  final String activityName;
  final double amount;
  final String note;
}

class Invoice {
  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.status,
    required this.totalAmountExclTax,
    required this.totalAmountInclTax,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        status: InvoiceStatusJson.fromJson(json['status'] as String),
        totalAmountExclTax: (json['totalAmountExclTax'] as num).toDouble(),
        totalAmountInclTax: (json['totalAmountInclTax'] as num).toDouble(),
      );

  final String id;
  final String invoiceNumber;
  final InvoiceStatus status;
  final double totalAmountExclTax;
  final double totalAmountInclTax;
}

class EmployeeProfitability {
  EmployeeProfitability({
    required this.employeeName,
    required this.totalBilled,
    required this.totalCost,
    required this.grossProfit,
    required this.profitMargin,
  });

  factory EmployeeProfitability.fromJson(Map<String, dynamic> json) => EmployeeProfitability(
        employeeName: json['employeeName'] as String,
        totalBilled: (json['totalBilled'] as num).toDouble(),
        totalCost: (json['totalCost'] as num).toDouble(),
        grossProfit: (json['grossProfit'] as num).toDouble(),
        profitMargin: (json['profitMargin'] as num).toDouble(),
      );

  final String employeeName;
  final double totalBilled;
  final double totalCost;
  final double grossProfit;
  final double profitMargin;
}
