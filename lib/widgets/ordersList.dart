import 'package:booking_app/helpers/folderStructure.dart';
import 'package:flutter/material.dart';

class OrderListClass {
  int? customerId;
  String? customerName;
  String? address;
  String? complete;
  String? sent;
  int? dateTime;
  String? orderId;
  String? total;
  String? time;
  OrderListClass(
      {this.customerId,
      this.customerName,
      this.address,
      this.complete,
      this.sent,
      this.dateTime,
      this.orderId,
      this.total,
      this.time});
}

class OrdersList extends StatelessWidget {
  String? customerName;
  String? address;
  String? complete;
  String? sent;
  int? dateTime;
  String? orderId;
  String? total;
  String? time;
  OrdersList(
      {required this.customerName,
      required this.address,
      required this.complete,
      required this.sent,
      required this.dateTime,
      required this.total,
      required this.orderId,
      required this.time});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text(
                  customerName!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                  overflow: TextOverflow.visible,
                ),
                new Text(
                  address!,
                  style: TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    new Text(FolderStructure.getDate(dateTime!) + "  " + time!),
                    Spacer(),
                    new Text(
                      "Total=" + total!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  complete == "1"
                      ? Text(
                          "Complete",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        )
                      : Text(
                          "Incomplete",
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                  sent == "1"
                      ? Text(
                          "Sent",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        )
                      : Text(
                          "Unsent",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
