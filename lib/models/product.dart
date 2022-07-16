final String tableProducts =
    "products"; // Specify the name of table. This will be the column name in DB.

class ProductFields {
  /*
  Specify the field names in table. This will be fields names in DB
  */
  static final String code = "code";
  static final String description = "description";
  static final String tradePrice = "tradePrice";
  static final String companyId = "companyId";
  static final String companyName = "companyName";
  static final String groupName = "groupName";
  static final String retailPrice = "retailPrice";
}

class Product {
  final String? code;
  final String? description;
  final double? tradePrice;
  final String? companyId;
  final String? companyName;
  final String? groupName;
  final double? retailPrice;

  Product(
      {this.code,
      this.description,
      this.tradePrice,
      this.companyId,
      this.companyName,
      this.groupName,
      this.retailPrice});

  Map<String, dynamic> toMap() {
    return {
      ProductFields.code: code,
      ProductFields.description: description,
      ProductFields.tradePrice: tradePrice,
      ProductFields.companyId: companyId,
      ProductFields.companyName: companyName,
      ProductFields.groupName: groupName,
      ProductFields.retailPrice: retailPrice
    };
  }
}
