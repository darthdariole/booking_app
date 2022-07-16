import 'package:booking_app/bookingappdb.dart';
import 'package:sqflite/sqflite.dart';

import '../models/customer.dart';

class CustomerDatabase {
  /*
  Provide this method with the list of customers ripped from file.
  You will need to filter the columns needed from file.
  */
  static void deleteCustomers() async {
    Database db = await BookingAppDBHelper().database();
    var batch = db.batch();
    batch.delete(tableCustomer);
  }

  static void insertCustomers(List<Customer> customers) async {
    Database db = await BookingAppDBHelper().database();
    deleteCustomers();
    var trans = db.batch();

    customers.forEach((customer) {
      trans.rawInsert("INSERT INTO " +
          tableCustomer +
          "(" +
          CustomerFields.customerId +
          ", " +
          CustomerFields.customerName +
          ", " +
          CustomerFields.regionDescription +
          ", " +
          CustomerFields.address +
          ") " +
          "VALUES (" +
          customer.customerId.toString() +
          ", '" +
          customer.customerName! +
          "', '" +
          customer.regionDescription! +
          "', '" +
          customer.address! +
          "');");
    });
    try {
      await trans.commit(noResult: true, continueOnError: true);
    } catch (e) {
      print("Error in insert: " + e.toString());
    }
  }

  static void insertCustomer(Customer customer) async {
    Database db = await BookingAppDBHelper().database();
    db.insert(tableCustomer, customer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Customer?> getCustomerFromId(String customerId) async {
    Customer? customer;
    Database db = await BookingAppDBHelper().database();
    List<Map> customerMap = await db.rawQuery(
      "SELECT * FROM $tableCustomer WHERE ${CustomerFields.customerId} = $customerId",
    );
    customerMap.forEach((element) {
      customer = Customer(
        customerId: element['customerId'],
        address: element['address'],
        customerName: element['customerName'],
        regionDescription: element['regionDescription'],
      );
    });
    return customer;
  }

  static Future<List<Customer>> getFilterCustomer(String? customerName) async {
    Database db = await BookingAppDBHelper().database();
    List<Map<String, dynamic>> customerFilterMap = await db.rawQuery(
        "SELECT * FROM " +
            tableCustomer +
            " WHERE customerName LIKE '%$customerName%';");
    return List.generate(
        customerFilterMap.length,
        (index) => Customer(
              customerId: customerFilterMap[index]['customerId'],
              customerName: customerFilterMap[index]['customerName'],
              regionDescription: customerFilterMap[index]['regionDescription'],
              address: customerFilterMap[index]['address'],
            ));
  }
}
