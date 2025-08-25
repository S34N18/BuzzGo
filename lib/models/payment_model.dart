class PaymentModel {
  final String id;
  final String userId;
  final String eventId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String transactionId;
  final PaymentStatus status;
  final String? mpesaReceiptNumber;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.amount,
    this.currency = 'KES',
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    this.mpesaReceiptNumber,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      eventId: json['eventId'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'KES',
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      mpesaReceiptNumber: json['mpesaReceiptNumber'],
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status.toString().split('.').last,
      'mpesaReceiptNumber': mpesaReceiptNumber,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? transactionId,
    PaymentStatus? status,
    String? mpesaReceiptNumber,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      mpesaReceiptNumber: mpesaReceiptNumber ?? this.mpesaReceiptNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}