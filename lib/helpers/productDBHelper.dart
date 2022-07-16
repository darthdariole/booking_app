import 'package:booking_app/bookingappdb.dart';
import 'package:booking_app/models/product.dart';
import 'package:sqflite/sqflite.dart';

class ProductsDatabaseHelper {
  static void deleteProducts() async {
    Database db = await BookingAppDBHelper().database();
    var batch = db.batch();
    batch.delete(tableProducts);
  }

  static void insertProducts(List<Product> products) async {
    Database db = await BookingAppDBHelper().database();
    var batch = db.batch();

    products.forEach((product) {
      batch.rawInsert("INSERT INTO " +
          tableProducts +
          "(" +
          ProductFields.code +
          ", " +
          ProductFields.description +
          ", " +
          ProductFields.tradePrice +
          ", " +
          ProductFields.companyId +
          ", " +
          ProductFields.companyName +
          ", " +
          ProductFields.groupName +
          ", " +
          ProductFields.retailPrice +
          ") " +
          "VALUES (" +
          product.code! +
          ", '${product.description}'" +
          ", " +
          product.tradePrice.toString() +
          ", '" +
          product.companyId! +
          "', '" +
          product.companyName! +
          "', '" +
          product.groupName! +
          "', " +
          product.retailPrice.toString() +
          ");");
    });
    try {
      await batch.commit(noResult: true, continueOnError: true);
    } catch (e) {
      print("Error in product insert: " + e.toString());
    }
  }

  static void insertProduct(Product product) async {
    Database db = await BookingAppDBHelper().database();
    db.insert(tableProducts, product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Product>> getFilterProducts(String? productName) async {
    Database db = await BookingAppDBHelper().database();
    List<Map<String, dynamic>> productFilterMap = await db.rawQuery(
        "SELECT * FROM " +
            tableProducts +
            " WHERE " +
            ProductFields.description +
            " LIKE '%$productName%'");
    return List.generate(
        productFilterMap.length,
        (index) => Product(
              code: productFilterMap[index][ProductFields.code],
              description: productFilterMap[index][ProductFields.description],
              companyId: productFilterMap[index][ProductFields.companyId],
              companyName: productFilterMap[index][ProductFields.companyName],
              groupName: productFilterMap[index][ProductFields.groupName],
              retailPrice: productFilterMap[index][ProductFields.retailPrice],
              tradePrice: productFilterMap[index][ProductFields.tradePrice],
            ));
  }

  static Future<Product?> getProductFromCode(String code) async {
    Database db = await BookingAppDBHelper().database();
    List<Map> productsList = await db.query(tableProducts,
        where: ProductFields.code + " = ?", whereArgs: [code], limit: 1);
    if (productsList.length > 0) {
      return Product(
        code: productsList[0][ProductFields.code],
        companyId: productsList[0][ProductFields.companyId],
        companyName: productsList[0][ProductFields.companyName],
        description: productsList[0][ProductFields.description],
        groupName: productsList[0][ProductFields.groupName],
        retailPrice: productsList[0][ProductFields.retailPrice],
        tradePrice: productsList[0][ProductFields.tradePrice],
      );
    }
    return null;
  }
}
