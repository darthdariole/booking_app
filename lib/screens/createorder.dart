import 'package:booking_app/helpers/customerDatabase.dart';
import 'package:booking_app/helpers/folderStructure.dart';
import 'package:booking_app/helpers/ordersDBHelper.dart';
import 'package:booking_app/helpers/productDBHelper.dart';
import 'package:booking_app/models/ordermaster.dart';
import 'package:booking_app/models/product.dart';
import 'package:booking_app/screens/search.dart';
import 'package:booking_app/widgets/createOrderList.dart';
import 'package:booking_app/widgets/ordersList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';
import '../models/orderdetail.dart';
import '../widgets/salemanDetails.dart';

class CreateOrder extends StatefulWidget {
  final String longitude;
  final String latitude;
  final OrderListClass? orderListClass;

  CreateOrder({
    required this.longitude,
    required this.latitude,
    required this.orderListClass,
  });
  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  bool _viewMode = false;

  String? customerId;
  String? customerName;
  String? regionDescription;
  String? address;

  Product? _product;

  late List<OrderDetail> _bookingItemsList;

  FocusNode? _codeFocus;
  FocusNode? _descriptionFocus;
  FocusNode? _qtyFocus;
  TextEditingController _codeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _qtyController = TextEditingController();

  @override
  void initState() {
    if (widget.orderListClass != null &&
        widget.orderListClass!.complete == "0" &&
        widget.orderListClass!.sent == "0") {
      _editMode();
    } else if (widget.orderListClass != null) {
      setState(() {
        _viewMode = true;
      });
      _editMode();
    }
    _bookingItemsList = <OrderDetail>[];

    _product = Product();
    _codeFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _qtyFocus = FocusNode();
    super.initState();
    /*
    Code for preparing activity for update.
    1. Get order master detail from database, we need customer details and add 
       into header and save in variables.
    2. Get order detail from database, we need products detail and add into list.
    3. On save we save the orders completly fresh but with same order id. 
       This will eliminate complex code and [meri gand me harish].
    */
  }

  @override
  void dispose() {
    _codeFocus!.dispose();
    _descriptionFocus!.dispose();
    _qtyFocus!.dispose();

    _codeController.dispose();
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  _editMode() async {
    print("Edit mode..." + widget.orderListClass!.orderId!);
    Customer? customer = await CustomerDatabase.getCustomerFromId(
        widget.orderListClass!.customerId.toString());
    List<OrderDetail> orderDetail =
        await OrdersDatabaseHelper.getOrderDetailForExport(
            "(" + widget.orderListClass!.orderId! + ")");
    setState(() {
      customerId = customer!.customerId.toString();
      customerName = customer.customerName;
      regionDescription = customer.regionDescription;
      address = customer.address;
      _bookingItemsList = orderDetail;
    });
  }

  bool _checkInputs() {
    if (_codeController.text.length == 0) {
      return false;
    }
    if (_nameController.text.length == 0) {
      return false;
    }
    if (_qtyController.text.length == 0) {
      return false;
    }
    return true;
  }

  bool _checkItemAlreadyAdded(OrderDetail orderDetail) {
    bool itemExists = false;
    _bookingItemsList.forEach((element) {
      if (element.productCode == orderDetail.productCode) {
        print(_bookingItemsList.indexOf(element));
        itemExists = true;
      }
    });
    return itemExists;
  }

  OrderDetail _createOrderDetailObject() {
    OrderDetail orderDetail;
    if (widget.orderListClass == null) {
      orderDetail = OrderDetail(
        productCode: _codeController.text,
        productName: _nameController.text,
        quantity: _qtyController.text,
        amount: double.parse(_qtyController.text) * _product!.tradePrice!,
        orderId: 0,
      );
    } else {
      orderDetail = OrderDetail(
        productCode: _codeController.text,
        productName: _nameController.text,
        quantity: _qtyController.text,
        amount: double.parse(_qtyController.text) * _product!.tradePrice!,
        orderId: int.parse(widget.orderListClass!.orderId!),
      );
    }

    return orderDetail;
  }

  void _addIntoList(OrderDetail orderDetail) {
    if (_checkItemAlreadyAdded(orderDetail)) {
      print("Product repeat...");
      setState(() {
        _bookingItemsList.forEach((element) {
          if (element.productCode == orderDetail.productCode) {
            element.quantity = orderDetail.quantity;
            element.amount = orderDetail.amount!.roundToDouble();
          }
        });
        _codeController.clear();
        _nameController.clear();
        _qtyController.clear();
      });
      _calculateAmount();
    } else {
      setState(() {
        _bookingItemsList.add(orderDetail);
        _codeController.clear();
        _nameController.clear();
        _qtyController.clear();
      });
      _calculateAmount();
    }
  }

  double _calculateAmount() {
    if (_bookingItemsList.length == 0)
      return 0.0;
    else {
      double amount = 0.0;
      _bookingItemsList.forEach((element) {
        amount = amount + element.amount!;
      });
      return amount.roundToDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75.0,
          title: InkWell(
            onTap: () async {
              if (_viewMode == false) {
                print("Please make a customer out of me!!!");
                Customer? customer = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(
                        productSearch: false,
                        searchTextFromCreateOrder: "",
                      ),
                    ));
                if (customer != null) {
                  //print("CustomerId returned = " + customer.customerName);
                  setState(() {
                    customerId = customer.customerId.toString();
                    customerName = customer.customerName;
                    address = customer.address;
                    regionDescription = customer.regionDescription;
                  });
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text(
                        "Cannot change customer because order is complete...")));
              }
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(
                          customerName == null
                              ? "(Customer Name)"
                              : customerName!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        new Text(
                          address == null ? "(Address)" : address!,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        new Text(
                          regionDescription == null
                              ? "(Region Description)"
                              : regionDescription!,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    disabledColor: Colors.grey,
                    onPressed: _viewMode
                        ? null
                        : () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            if (customerId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: new Text(
                                          "Please select a customer...")));
                            } else if (_bookingItemsList.length == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: new Text(
                                          "No items added to order...")));
                            } else if (!prefs.containsKey("salemanId")) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: new Text(
                                    "Saleman detail not updated, Kindly add saleman detail first."),
                                action: SnackBarAction(
                                  label: "Add Details",
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return Container(
                                            child: SalemanDetails(),
                                          );
                                        });
                                  },
                                ),
                              ));
                            } else if (widget.orderListClass == null) {
                              OrderMaster orderMaster = OrderMaster(
                                bookerId: prefs.getString("salemanId"),
                                complete: 0,
                                sent: 0,
                                customerId: int.parse(customerId!),
                                date: DateTime.now().millisecondsSinceEpoch,
                                time: FolderStructure.getTime24Hr(false),
                                latitude: widget.latitude.toString(),
                                longitude: widget.longitude.toString(),
                                total: _calculateAmount(),
                              );
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Save order!"),
                                    content: const Text(
                                        "Are you sure you want to save order?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          OrdersDatabaseHelper.insertNewOrder(
                                              orderMaster, _bookingItemsList);
                                          Navigator.pop(context);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "Save",
                                          style: TextStyle(),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              //Update order here
                              OrderMaster orderMaster = OrderMaster(
                                orderId:
                                    int.parse(widget.orderListClass!.orderId!),
                                bookerId: prefs.getString("salemanId"),
                                complete: 0,
                                sent: 0,
                                customerId: int.parse(customerId!),
                                date: DateTime.now().millisecondsSinceEpoch,
                                time: FolderStructure.getTime24Hr(false),
                                latitude: widget.latitude.toString(),
                                longitude: widget.longitude.toString(),
                                total: _calculateAmount(),
                              );
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Update order!"),
                                    content: const Text(
                                        "Are you sure you want to update order?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          OrdersDatabaseHelper.updateOrder(
                                              orderMaster, _bookingItemsList);
                                          Navigator.pop(context);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "Update",
                                          style: TextStyle(),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                    icon: Icon(Icons.save),
                  ),
                ],
              ),
            ),
          ),
        ),
        /*
        This is the body of the activity.
        */
        body: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Spacer(),
                  Text(
                    "Est. Bill Amount = " + _calculateAmount().toString(),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: _bookingItemsList.length > 0
                      ? ListView.builder(
                          itemCount: _bookingItemsList.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                                key: Key(_bookingItemsList[index].productCode!),
                                background: Container(
                                  color: Colors.blue,
                                  alignment: Alignment.centerLeft,
                                  child: Align(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Icon(Icons.edit),
                                    ),
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  child: Align(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Icon(Icons.delete_forever),
                                    ),
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  bool dismiss = false;
                                  if (direction ==
                                          DismissDirection.startToEnd &&
                                      _viewMode == false) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("EDIT RECORD"),
                                            content: const Text(
                                                "Are you sure? This action cannot be reversed."),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    _codeController.text =
                                                        _bookingItemsList[index]
                                                            .productCode!;
                                                    _nameController.text =
                                                        _bookingItemsList[index]
                                                            .productName!;
                                                    _qtyController.text =
                                                        _bookingItemsList[index]
                                                            .quantity!;
                                                    if (widget.orderListClass ==
                                                        null) {
                                                      setState(() {
                                                        _bookingItemsList
                                                            .removeAt(index);
                                                      });
                                                    } else {
                                                      Product? product =
                                                          await ProductsDatabaseHelper
                                                              .getProductFromCode(
                                                                  _codeController
                                                                      .text);
                                                      setState(() {
                                                        _product = product;
                                                        _bookingItemsList
                                                            .removeAt(index);
                                                      });
                                                    }
                                                    dismiss = true;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Edit")),
                                              TextButton(
                                                  onPressed: () {
                                                    dismiss = false;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel")),
                                            ],
                                          );
                                        });
                                  } else if (direction ==
                                          DismissDirection.endToStart &&
                                      _viewMode == false) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("DELETE RECORD"),
                                            content: const Text(
                                                "Are you sure? This action cannot be reversed."),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    dismiss = true;
                                                    if (widget.orderListClass !=
                                                        null) {
                                                      OrdersDatabaseHelper
                                                          .deleteOrderDetailRow(
                                                              _bookingItemsList[
                                                                      index]
                                                                  .orderId
                                                                  .toString(),
                                                              _bookingItemsList[
                                                                      index]
                                                                  .productCode);
                                                    }
                                                    setState(() {
                                                      _bookingItemsList
                                                          .removeAt(index);
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Delete")),
                                              TextButton(
                                                  onPressed: () {
                                                    dismiss = false;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel")),
                                            ],
                                          );
                                        });
                                  }
                                  return dismiss;
                                },
                                child: CreateOrderList(
                                  amount: _bookingItemsList[index]
                                      .amount
                                      .toString(),
                                  code: _bookingItemsList[index].productCode,
                                  description:
                                      _bookingItemsList[index].productName,
                                  quantity: _bookingItemsList[index].quantity,
                                ));
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No items found, follow following steps to add items into order",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "1. Type Product Code into code field.",
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.grey),
                              ),
                              Text(
                                "2. If code not known, type name into name field.",
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.grey),
                              ),
                              Text(
                                "3. Enter quantity in Qty field.",
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.grey),
                              ),
                              Text(
                                "4. Press button to add.",
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      enabled: !_viewMode,
                      focusNode: _codeFocus,
                      //Keyboard type ki option mojood the par samsung devices masla karte hai.
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      onSubmitted: (value) async {
                        Product? product =
                            await ProductsDatabaseHelper.getProductFromCode(
                                value);
                        if (product != null && value.length > 0) {
                          print(product.description);
                          setState(() {
                            _nameController.text = product.description!;
                            _codeController.text = product.code!;
                            _product = product;
                          });
                          _qtyFocus!.requestFocus();
                        } else {
                          _descriptionFocus!.requestFocus();
                          setState(() {
                            _codeController.clear();
                            _nameController.clear();
                          });
                        }
                      },
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: "Code",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 7,
                    child: TextField(
                      enabled: !_viewMode,
                      focusNode: _descriptionFocus,
                      controller: _nameController,
                      onChanged: (value) async {
                        Product? product = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Search(
                                      productSearch: true,
                                      searchTextFromCreateOrder: value,
                                    )));
                        if (product != null) {
                          setState(() {
                            _product = product;
                            _codeController.text = product.code!;
                            _nameController.text = product.description!;
                          });
                          _qtyFocus!.requestFocus();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      enabled: !_viewMode,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      focusNode: _qtyFocus,
                      controller: _qtyController,
                      decoration: InputDecoration(
                        hintText: "Qty",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_checkInputs()) {
                        _addIntoList(_createOrderDetailObject());
                        _codeFocus!.requestFocus();
                      }
                    },
                    child: Icon(Icons.add),
                    style: TextButton.styleFrom(
                      minimumSize: Size(45.0, 45.0),
                      backgroundColor: Colors.orangeAccent,
                      primary: Colors.white,
                      elevation: 2.0,
                      shape: CircleBorder(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
