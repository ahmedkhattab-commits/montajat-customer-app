class SuccessResponseModel {
  final bool? status;
  final int? orderId;
  // final int? returnOrderId;
  // final int? id;
  final String? message;

  const SuccessResponseModel({
    required this.status,
    required this.orderId,
    // required this.returnOrderId,
    // required this.id,
    required this.message,
  });

  factory SuccessResponseModel.fromJson(Map<String, dynamic> json) =>
      SuccessResponseModel(
        status: json["status"],
        // id: json["id"],
        orderId: json["order_id"],
        // returnOrderId: (json["return_order"]?['id']),
        message: json["message"],
      );
}
