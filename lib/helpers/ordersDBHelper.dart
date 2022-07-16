import 'package:booking_app/bookingappdb.dart';
import 'package:booking_app/models/customer.dart';
import 'package:booking_app/widgets/ordersList.dart';
import 'package:sqflite/sqflite.dart';

import '../models/orderdetail.dart';
import '../models/ordermaster.dart';

class OrdersDatabaseHelper {
  static void markOrdersSent(String orderIds) async {
    Database db = await BookingAppDBHelper().database();
    db.rawUpdate(
        "UPDATE $tableOrderMaster SET ${OrderMasterFields.sent} = 1, ${OrderMasterFields.complete} = 1 WHERE ${OrderMasterFields.orderId} IN " +
            orderIds);
  }

  static void insertNewOrder(
      OrderMaster orderMaster, List<OrderDetail> orderDetailList) async {
    Database db = await BookingAppDBHelper().database();
    int orderId = await db.insert(tableOrderMaster, orderMaster.toMap());
    orderDetailList.forEach((element) {
      db.rawInsert(
          "INSERT INTO $tableOrderDetail (${OrderDetailFields.orderId}, ${OrderDetailFields.productCode}, ${OrderDetailFields.productName}, ${OrderDetailFields.quantity}, ${OrderDetailFields.amount}) VALUES ($orderId, '${element.productCode}', '${element.productName}', '${element.quantity}', ${element.amount});");
    });
  }

  static void deleteOrder(String? orderId) async {
    Database db = await BookingAppDBHelper().database();
    await db.delete(tableOrderMaster,
        where: "${OrderMasterFields.orderId} = ?", whereArgs: [orderId]);
    await db.delete(tableOrderDetail,
        where: "${OrderDetailFields.orderId} = ?", whereArgs: [orderId]);
  }

  static void deleteOrderDetailRow(String orderId, String? productCode) async {
    Database db = await BookingAppDBHelper().database();
    await db.delete(tableOrderDetail,
        where:
            "${OrderDetailFields.orderId} = ? AND ${OrderDetailFields.productCode} = ?",
        whereArgs: [orderId, productCode]);
  }

  static void updateOrder(
      OrderMaster orderMaster, List<OrderDetail> orderDetailList) async {
    Database db = await BookingAppDBHelper().database();
    await db.update(tableOrderMaster, orderMaster.toMap(),
        where: '${OrderMasterFields.orderId} = ?',
        whereArgs: [orderMaster.orderId]);

    orderDetailList.forEach((element) async {
      print("Order detail ki length jo update hone aaye: " +
          orderDetailList.length.toString());
      List<Map> orderDetailSubList = await db.rawQuery(
          "SELECT * FROM $tableOrderDetail WHERE ${OrderDetailFields.orderId} = ${element.orderId} AND ${OrderDetailFields.productCode} = ${element.productCode};");
      if (orderDetailSubList.length > 0) {
        await db.rawUpdate(
            "UPDATE $tableOrderDetail SET ${OrderDetailFields.orderId} = ${orderMaster.orderId}, ${OrderDetailFields.productCode} = '${element.productCode}', ${OrderDetailFields.productName} = '${element.productName}', ${OrderDetailFields.quantity} = '${element.quantity}', ${OrderDetailFields.amount} = ${element.amount} WHERE ${OrderDetailFields.orderId} = ${orderMaster.orderId} AND ${OrderDetailFields.productCode} = ${element.productCode};");
      } else {
        db.rawInsert(
            "INSERT INTO $tableOrderDetail (${OrderDetailFields.orderId}, ${OrderDetailFields.productCode}, ${OrderDetailFields.productName}, ${OrderDetailFields.quantity}, ${OrderDetailFields.amount}) VALUES (${orderMaster.orderId}, '${element.productCode}', '${element.productName}', '${element.quantity}', ${element.amount});");
      }
    });
  }

  static Future<List<dynamic>> getOrdersList(String sortOrder, String sortBy,
      DateTime? fromDate, DateTime? toDate) async {
    Database db = await BookingAppDBHelper().database();
    List<Map<String, dynamic>> ordersListMap = [];
    if (fromDate == null && toDate == null) {
      ordersListMap = await db.rawQuery(
          "SELECT $tableCustomer.${CustomerFields.customerId}, ${CustomerFields.customerName}, ${CustomerFields.address}, $tableOrderMaster.${OrderMasterFields.complete}, $tableOrderMaster.${OrderMasterFields.sent}, $tableOrderMaster.${OrderMasterFields.date}, $tableOrderMaster.${OrderMasterFields.time}, $tableOrderMaster.${OrderMasterFields.total}, $tableOrderMaster.${OrderMasterFields.orderId} FROM $tableCustomer INNER JOIN $tableOrderMaster ON $tableCustomer.${CustomerFields.customerId} = $tableOrderMaster.${OrderMasterFields.customerId} WHERE $tableOrderMaster.${OrderMasterFields.sent} = 0 ORDER BY $tableOrderMaster.$sortBy $sortOrder;");
    } else {
      ordersListMap = await db.rawQuery(
          "SELECT $tableCustomer.${CustomerFields.customerId}, ${CustomerFields.customerName}, ${CustomerFields.address}, $tableOrderMaster.${OrderMasterFields.complete}, $tableOrderMaster.${OrderMasterFields.sent}, $tableOrderMaster.${OrderMasterFields.date}, $tableOrderMaster.${OrderMasterFields.time}, $tableOrderMaster.${OrderMasterFields.total}, $tableOrderMaster.${OrderMasterFields.orderId} FROM $tableCustomer INNER JOIN $tableOrderMaster ON $tableCustomer.${CustomerFields.customerId} = $tableOrderMaster.${OrderMasterFields.customerId} WHERE $tableOrderMaster.${OrderMasterFields.date} BETWEEN ${fromDate == null ? "Null Date" : fromDate.millisecondsSinceEpoch} AND ${toDate == null ? "Null Date" : toDate.millisecondsSinceEpoch} ORDER BY $tableOrderMaster.$sortBy $sortOrder;");
      print(ordersListMap.length);
    }

    return List.generate(
        ordersListMap.length,
        (index) => OrderListClass(
            customerId: ordersListMap[index][CustomerFields.customerId],
            customerName: ordersListMap[index][CustomerFields.customerName],
            address: ordersListMap[index][CustomerFields.address],
            complete:
                ordersListMap[index][OrderMasterFields.complete].toString(),
            dateTime: ordersListMap[index][OrderMasterFields.date],
            time: ordersListMap[index][OrderMasterFields.time],
            sent: ordersListMap[index][OrderMasterFields.sent].toString(),
            orderId: ordersListMap[index][OrderMasterFields.orderId].toString(),
            total: ordersListMap[index][OrderMasterFields.total].toString()));
  }

  /*
  This method will export the unsent data for creating file.
  */
  static Future<List<OrderMaster>> getOrderMasterForExport() async {
    Database db = await BookingAppDBHelper().database();
    List<Map<String, dynamic>> orderMasterMap = await db.rawQuery(
        "SELECT * FROM $tableOrderMaster WHERE ${OrderMasterFields.sent} == 0");
    return List.generate(
        orderMasterMap.length,
        (index) => OrderMaster(
            bookerId: orderMasterMap[index][OrderMasterFields.bookerId],
            complete: orderMasterMap[index][OrderMasterFields.complete],
            customerId: orderMasterMap[index][OrderMasterFields.customerId],
            date: orderMasterMap[index][OrderMasterFields.date],
            latitude: orderMasterMap[index][OrderMasterFields.latitude],
            longitude: orderMasterMap[index][OrderMasterFields.longitude],
            orderId: orderMasterMap[index][OrderMasterFields.orderId],
            sent: orderMasterMap[index][OrderMasterFields.sent],
            time: orderMasterMap[index][OrderMasterFields.time],
            total: orderMasterMap[index][OrderMasterFields.total]));
  }

  /*
  This method will export the dated data for creating file.
  */
  static Future<List<OrderMaster>> getOrderMasterDatedForExport(
      String fromMillisecond, String toMillisecond) async {
    Database db = await BookingAppDBHelper().database();
    List<Map<String, dynamic>> orderMasterMap = await db.rawQuery(
        "SELECT * FROM $tableOrderMaster WHERE ${OrderMasterFields.date} BETWEEN $fromMillisecond AND $toMillisecond");
    return List.generate(
        orderMasterMap.length,
        (index) => OrderMaster(
            bookerId: orderMasterMap[index][OrderMasterFields.bookerId],
            complete: orderMasterMap[index][OrderMasterFields.complete],
            customerId: orderMasterMap[index][OrderMasterFields.customerId],
            date: orderMasterMap[index][OrderMasterFields.date],
            latitude: orderMasterMap[index][OrderMasterFields.latitude],
            longitude: orderMasterMap[index][OrderMasterFields.longitude],
            orderId: orderMasterMap[index][OrderMasterFields.orderId],
            sent: orderMasterMap[index][OrderMasterFields.sent],
            time: orderMasterMap[index][OrderMasterFields.time],
            total: orderMasterMap[index][OrderMasterFields.total]));
  }

  static Future<List<OrderDetail>> getOrderDetailForExport(
      String orderIds) async {
    Database db = await BookingAppDBHelper().database();
    List<Map<String, dynamic>> ordersDetailMap = await db.rawQuery("SELECT *" +
        " FROM " +
        tableOrderDetail +
        " WHERE " +
        OrderDetailFields.orderId +
        " IN " +
        orderIds +
        " ORDER BY $tableOrderDetail.${OrderDetailFields.orderId} ASC;");
    print("Map length: " + ordersDetailMap.length.toString());
    return List.generate(
        ordersDetailMap.length,
        (index) => OrderDetail(
            orderId: ordersDetailMap[index][OrderDetailFields.orderId],
            productCode: ordersDetailMap[index][OrderDetailFields.productCode],
            productName: ordersDetailMap[index][OrderDetailFields.productName],
            quantity: ordersDetailMap[index][OrderDetailFields.quantity],
            amount: ordersDetailMap[index][OrderDetailFields.amount]));
  }

  static void markOrdersComplete() async {
    DateTime now = DateTime.now();
    DateTime todayDateMorning = DateTime(now.year, now.month, now.day);
    Database db = await BookingAppDBHelper().database();

    await db.rawUpdate(
        "UPDATE $tableOrderMaster SET complete = ? WHERE ${OrderMasterFields.date} < ${todayDateMorning.millisecondsSinceEpoch};",
        [1]);
  }

  static Future<String> todayOrderCount() async {
    Database db = await BookingAppDBHelper().database();
    DateTime? _today = DateTime.now();
    DateTime? _fromDate = DateTime(_today.year, _today.month, _today.day);
    DateTime? _toDate = _fromDate.add(Duration(hours: _fromDate.hour + 24));
    print(_fromDate.millisecondsSinceEpoch.toString());
    print(_toDate.millisecondsSinceEpoch.toString());
    List<Map<String, dynamic>> ordersMap = await db.rawQuery(
        "SELECT * FROM $tableOrderMaster WHERE ${OrderMasterFields.date} BETWEEN ${_fromDate.millisecondsSinceEpoch} AND ${_toDate.millisecondsSinceEpoch}");
    return Future.value(ordersMap.length.toString());
  }

  static Future<String> amountOfOrdersUnsent() async {
    double sum = 0.0;
    DateTime? _today = DateTime.now();
    DateTime? _fromDate = DateTime(_today.year, _today.month, _today.day);
    DateTime? _toDate = _fromDate.add(Duration(hours: _fromDate.hour + 24));
    Database db = await BookingAppDBHelper().database();
    List<Map<String, dynamic>> ordersMap = await db.rawQuery(
        "SELECT * FROM $tableOrderMaster WHERE ${OrderMasterFields.date} BETWEEN ${_fromDate.millisecondsSinceEpoch} AND ${_toDate.millisecondsSinceEpoch}");
    for (int i = 0; i < ordersMap.length; i++) {
      print(ordersMap[i][OrderMasterFields.total]);
      sum = sum + ordersMap[i][OrderMasterFields.total];
    }
    return sum.round().toString();
  }

  static Future<int> getUnsentOrderCount() async {
    Database db = await BookingAppDBHelper().database();
    List<Map<String, dynamic>> ordersMap = await db.rawQuery(
        "SELECT * FROM $tableOrderMaster WHERE ${OrderMasterFields.sent} == 0");
    return Future.value(ordersMap.length);
  }
}
