import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'models/customer.dart';
import 'models/orderdetail.dart';
import 'models/ordermaster.dart';
import 'models/product.dart';

class BookingAppDBHelper {
  Future<Database> database() async {
    return openDatabase(join(await getDatabasesPath(), "bookingApp.db"),
        onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE $tableCustomer (customerId INTEGER PRIMARY KEY, customerName TEXT NOT NULL, regionDescription TEXT NOT NULL, address TEXT NOT NULL)");
      await db.execute("CREATE TABLE $tableProducts" +
          "(${ProductFields.code} TEXT PRIMARY KEY NOT NULL,${ProductFields.companyId} TEXT NOT NULL, ${ProductFields.companyName} TEXT NOT NULL, ${ProductFields.description} TEXT NOT NULL, ${ProductFields.groupName} TEXT NOT NULL, ${ProductFields.retailPrice} DOUBLE NOT NULL, ${ProductFields.tradePrice} DOUBLE NOT NULL)");
      await db.execute("CREATE TABLE $tableOrderMaster" +
          " (${OrderMasterFields.orderId} INTEGER PRIMARY KEY AUTOINCREMENT, ${OrderMasterFields.customerId} INTEGER NOT NULL, ${OrderMasterFields.date} INTEGER NOT NULL, ${OrderMasterFields.total} REAL NOT NULL, ${OrderMasterFields.longitude} TEXT NOT NULL, ${OrderMasterFields.latitude} TEXT NOT NULL, ${OrderMasterFields.complete} INTEGER NOT NULL, ${OrderMasterFields.sent} INTEGER NOT NULL, ${OrderMasterFields.bookerId} TEXT NOT NULL, ${OrderMasterFields.time} TEXT NOT NULL);");
      await db.execute("CREATE TABLE $tableOrderDetail " +
          "(${OrderDetailFields.orderId} INTEGER, ${OrderDetailFields.productCode} TEXT NOT NULL, ${OrderDetailFields.productName} TEXT NOT NULL, ${OrderDetailFields.quantity} TEXT NOT NULL, ${OrderDetailFields.amount} REAL NOT NULL);");
    }, version: 1);
  }

  Future<int> insertCustomer(Customer customer) async {
    Database db = await database();
    db.insert(tableCustomer, customer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return 1;
  }

  Future<List<Customer>> getCustomers() async {
    Database db = await database();
    List<Map<String, dynamic>> customerMap = await db.query(tableCustomer);
    return List.generate(customerMap.length, (index) {
      return Customer(
        customerId: customerMap[index]['customerId'],
        customerName: customerMap[index]['customerName'],
        regionDescription: customerMap[index]['regionDescription'],
        address: customerMap[index]['address'],
      );
    });
  }
}
