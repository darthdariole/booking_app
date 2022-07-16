import 'package:flutter/material.dart';

class CustomerListItem extends StatelessWidget {
  String? customerId;
  String? customerName;
  String? regionDescription;
  String? address;

  CustomerListItem(
      {this.customerId,
      this.customerName,
      this.regionDescription,
      this.address});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 5.0,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
      ),
      child: Row(children: [
        Padding(
          padding: EdgeInsets.only(right: 5.0),
          child: Column(
            children: [
              Text(
                customerId!,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ),
        Flexible(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Text(
              customerName!,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            new Text(
              regionDescription!,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            new Text(
              address!,
            ),
          ],
        )),
      ]),
    );
  }
}

/*
return Container(
      height: 150.0,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  customerId,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                    fontSize: 24.0,
                  ),
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  customerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Text(regionDescription),
              Text(address),
            ],
          ),
        ],
      ),
    );
*/