final String tableCustomer =
    "customers"; // Specify the name of table. This will be the column name in DB.

class CustomerFields {
  /*
  Specify the field names in table. This will be fields names in DB
  */
  static final String customerId = 'customerId';
  static final String customerName = 'customerName';
  static final String regionDescription = 'regionDescription';
  static final String address = 'address';
}

class Customer {
  final int? customerId;
  final String? customerName;
  final String? regionDescription; // This will containe id and name combined.
  final String? address;

  Customer(
      {this.customerId,
      this.customerName,
      this.regionDescription,
      this.address});

  Map<String, dynamic> toMap() {
    return {
      CustomerFields.customerId: customerId,
      CustomerFields.customerName: customerName,
      CustomerFields.regionDescription: regionDescription,
      CustomerFields.address: address
    };
  }
}
