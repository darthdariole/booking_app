final String tableOrderDetail = "orderDetail";

class OrderDetailFields {
  static final String orderId = "orderId";
  static final String productCode = "productCode";
  static final String productName = "productName";
  static final String quantity = "quantity";
  static final String amount = "amount";
}

class OrderDetail {
  int? orderId;
  String? productCode;
  String? productName;
  String? quantity;
  double? amount;

  OrderDetail(
      {this.orderId,
      this.productCode,
      this.productName,
      this.quantity,
      this.amount});

  Map<String, dynamic> toMap() {
    return {
      OrderDetailFields.orderId: orderId,
      OrderDetailFields.productCode: productCode,
      OrderDetailFields.productName: productName,
      OrderDetailFields.quantity: quantity,
      OrderDetailFields.amount: amount,
    };
  }
}
