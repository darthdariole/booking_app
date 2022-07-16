import 'dart:io';

import 'package:booking_app/helpers/folderStructure.dart';
import 'package:booking_app/helpers/ordersDBHelper.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/StorageUtil.dart';
import '../models/orderdetail.dart';
import '../models/ordermaster.dart';

class ExportOrder extends StatefulWidget {
  const ExportOrder({Key? key}) : super(key: key);

  @override
  State<ExportOrder> createState() => _ExportOrderState();
}

class _ExportOrderState extends State<ExportOrder> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _fromDateString = "";
  String _toDateString = "";

  String _folderPath = "";

  String _insertZeroes(String original) {
    if (original.length == 4) {
      return original;
    } else if (original.length == 3) {
      return "0" + original;
    } else if (original.length == 2) {
      return "00" + original;
    } else if (original.length == 1) {
      return "000" + original;
    } else {
      return "Invalid code";
    }
  }

  Future<String> _createFile(DateTime? fromDate, DateTime? toDate) async {
    StorageUtil.getInstance();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderMasterFileData = "[START SOMASTER]\n";
    String fileName;
    List<OrderMaster> ordersMasterList;
    if (fromDate != null && toDate != null) {
      fileName = "/" +
          prefs.getString("salemanName")! +
          "_" +
          "${FolderStructure.getDate(DateTime.now().millisecondsSinceEpoch)}" +
          "_" +
          "${FolderStructure.getTime24Hr(true)}" +
          "_" +
          "Dated" +
          ".txt";
      ordersMasterList =
          await OrdersDatabaseHelper.getOrderMasterDatedForExport(
              fromDate.millisecondsSinceEpoch.toString(),
              toDate.millisecondsSinceEpoch.toString());
    } else {
      fileName = "/" +
          StorageUtil.getString("salemanName") +
          "_" +
          "${FolderStructure.getDate(DateTime.now().millisecondsSinceEpoch)}" +
          "_" +
          "${FolderStructure.getTime24Hr(true)}" +
          "_" +
          "UnSent" +
          ".txt";
      ordersMasterList = await OrdersDatabaseHelper.getOrderMasterForExport();
    }
    if (ordersMasterList.isNotEmpty) {
      File ordersFile =
          new File(await FolderStructure.getExportFilePath() + fileName);
      ordersFile.create();
      int index = 0;
      String orderIdString = "(";
      for (int i = 0; i < ordersMasterList.length; i++) {
        if (i < ordersMasterList.length)
          orderIdString += ordersMasterList[i].orderId.toString();
        if (i != ordersMasterList.length - 1) {
          orderIdString += ",";
        } else {
          orderIdString += ")";
        }
      }
      print("ORDER IDS: " + orderIdString);
      List<OrderDetail> ordersDetailList =
          await OrdersDatabaseHelper.getOrderDetailForExport(orderIdString);
      print("Order detail count: " + ordersDetailList.length.toString());
      ordersMasterList.forEach((element) {
        index++;
        orderMasterFileData += index.toString() +
            "~;" +
            element.orderId.toString() +
            "~;" +
            FolderStructure.getDate(element.date!) +
            " " +
            element.time! +
            "~;" +
            _insertZeroes(element.customerId.toString()) +
            "~;" +
            element.total.toString() +
            "~;" +
            element.longitude! +
            "~;" +
            element.latitude! +
            "\n";
      });
      orderMasterFileData += "[END SOMASTER]\n";

      //Order Detail string writing starts here.
      String orderDetailFileData = "[START SODETAIL]\n";
      ordersDetailList.forEach((element) {
        orderDetailFileData += element.orderId.toString() +
            "~;" +
            _insertZeroes(element.productCode!) +
            "~;" +
            element.quantity! +
            "~;" +
            element.amount.toString() +
            "\n";
      });
      orderDetailFileData += "[END SODETAIL]";
      await ordersFile.writeAsString(orderMasterFileData + orderDetailFileData);
      //Set path of file for export.
      OrdersDatabaseHelper.markOrdersSent(orderIdString);
      return ordersFile.path;
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Severe Error"),
              content: const Text("No orders found."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
      return "";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: 30.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10.0,
          right: 10.0),
      child: ListView(
        children: [
          Column(
            children: [
              const Text(
                "Export orders",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool exported = false;
                  String path = "";
                  if (await OrdersDatabaseHelper.getUnsentOrderCount() > 0) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Export Unsent orders?"),
                          content: const Text(
                              "Are you sure you wish to export all Unsent orders?"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                exported = true;
                                path = await _createFile(null, null);
                                setState(() {
                                  _folderPath = path;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text("Export"),
                            ),
                            TextButton(
                              onPressed: () {
                                exported = false;
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        );
                      },
                    ).then((value) async {
                      print("Export path: " + path);
                      if (exported && path != "") {
                        await Share.shareFiles([path]);
                        Navigator.pop(context);
                      }
                    });
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Severe error"),
                          content:
                              const Text("No unsent orders found to export."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Dismiss"),
                            )
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  "Export Un-Sent only",
                ),
              ),
              const Text(
                "Export Dated",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _fromDate == null ? DateTime.now() : _fromDate!,
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2050),
                      );
                      if (picked != null) {
                        setState(() {
                          _fromDate = picked;
                          _fromDateString = ": " +
                              _fromDate!.day.toString() +
                              "/" +
                              _fromDate!.month.toString() +
                              "/" +
                              _fromDate!.year.toString();
                        });
                      }
                    },
                    child: Text("From Date " + _fromDateString),
                  ),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _toDate == null ? DateTime.now() : _toDate!,
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2050),
                      );
                      if (picked != null) {
                        setState(() {
                          _toDate =
                              picked.add(Duration(hours: picked.hour + 24));
                          _toDateString = ": " +
                              _toDate!.day.toString() +
                              "/" +
                              _toDate!.month.toString() +
                              "/" +
                              _toDate!.year.toString();
                        });
                      }
                    },
                    child: Text("To Date " + _toDateString),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  bool exported = false;
                  String _path = "";
                  if (_fromDate != null && _toDate != null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Export Dated?"),
                          content: Text(
                              "Are you sure you wish to export from " +
                                  _fromDateString +
                                  ", to " +
                                  _toDateString +
                                  "?"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                exported = true;
                                _path = await _createFile(_fromDate, _toDate);
                                Navigator.pop(context);
                              },
                              child: const Text("Export Dated"),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.grey),
                                ))
                          ],
                        );
                      },
                    ).then((value) async {
                      if (exported && _path != "") {
                        await Share.shareFiles([_path]);
                        Navigator.pop(context);
                      }
                    });
                    _createFile(_fromDate, _toDate);
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("No Date selected"),
                            content:
                                const Text("Please select date and try again."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Close"),
                              ),
                            ],
                          );
                        });
                  }
                },
                child: const Text("Export Dated"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
