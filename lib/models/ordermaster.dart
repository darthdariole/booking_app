final String tableOrderMaster = "orderMaster";

class OrderMasterFields {
  static final String orderId = "orderId";
  static final String customerId = "customerId";
  static final String total = "total";
  static final String longitude = "longitude";
  static final String latitude = "latitude";
  static final String complete = "complete";
  static final String sent = "sent";
  static final String date = "orderDate";
  static final String time = "orderTime";
  static final String bookerId = "bookerId";
}

class OrderMaster {
  int? orderId;
  int? customerId;
  int? date;
  String? time;
  double? total;
  String? longitude;
  String? latitude;
  int?
      complete; // We have to use int type because bool not supported by sqflite.
  int? sent; // We have to use int type because bool not supported by sqflite.
  String? bookerId;

  OrderMaster(
      {this.orderId,
      this.total,
      this.longitude,
      this.latitude,
      this.customerId,
      this.complete,
      this.sent,
      this.date,
      this.time,
      this.bookerId});

  Map<String, dynamic> toMap() {
    return {
      OrderMasterFields.orderId: orderId,
      OrderMasterFields.customerId: customerId,
      OrderMasterFields.total: total,
      OrderMasterFields.longitude: longitude,
      OrderMasterFields.latitude: latitude,
      OrderMasterFields.complete: complete,
      OrderMasterFields.sent: sent,
      OrderMasterFields.bookerId: bookerId,
      OrderMasterFields.date: date,
      OrderMasterFields.time: time,
    };
  }
}
