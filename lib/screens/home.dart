//TODO:2. Search in orders feature.
import 'package:booking_app/helpers/StorageUtil.dart';
import 'package:booking_app/helpers/folderStructure.dart';
import 'package:booking_app/helpers/ordersDBHelper.dart';
import 'package:booking_app/models/ordermaster.dart';
import 'package:booking_app/screens/createorder.dart';
import 'package:booking_app/widgets/exportModal.dart';
import 'package:booking_app/widgets/navigationdrawer.dart';
import 'package:booking_app/widgets/ordersList.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../widgets/filterOrdersList.dart';

enum Sort { ASC, DESC }
enum SortBy { orderId, orderDate, customerId, orderTime, sent, complete }

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _sortOrder = "ASC";
  String _sortByString = OrderMasterFields.orderId;

  DateTime? toDate;
  DateTime? fromDate;

  FolderStructure folderStructure = FolderStructure();
  bool _searchMode = false;
  String _searchText = "";

  _requestPermission(ph.Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == ph.PermissionStatus.granted)
        return true;
      else
        return false;
    }
  }

  /*
  Run this method on screen load event, It will get current date and mark all orders
  as complete which are not in that date.
  */
  @override
  void initState() {
    OrdersDatabaseHelper.markOrdersComplete();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
        APPBAR
        This is top of the app known as the AppBar, This contains 2 text views to
        display the current date and saleman name. Company branding is optional 
        maybe I will add it later.
        */
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Text("Orders"),
            new Text(
              FolderStructure.getDate(DateTime.now().millisecondsSinceEpoch),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        initialData: [],
        future: OrdersDatabaseHelper.getOrdersList(_sortOrder, _sortByString,
            fromDate == null ? null : fromDate, toDate == null ? null : toDate),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (snapshot.data![index].complete == "0" &&
                            snapshot.data[index].sent == "0") {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: new Text("Edit order"),
                                  content: new Text(
                                      "Are you sure you want to edit this order?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          OrdersDatabaseHelper.deleteOrder(
                                              snapshot.data[index].orderId);
                                          setState(() {});
                                        },
                                        child: new Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        )),
                                    TextButton(
                                        onPressed: () async {
                                          var location = Location();
                                          var userLocation =
                                              await location.getLocation();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreateOrder(
                                                        orderListClass: snapshot
                                                            .data[index],
                                                        longitude: userLocation
                                                            .longitude
                                                            .toString(),
                                                        latitude: userLocation
                                                            .latitude
                                                            .toString(),
                                                      ))).then((value) {
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          });
                                        },
                                        child: new Text("Edit")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: new Text("Cancel")),
                                  ],
                                );
                              });
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text("View Order"),
                                    content: const Text(
                                        "Order has been marked as complete or sent and cannot be changed. You can view it only."),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            var location = Location();
                                            var userLocation =
                                                await location.getLocation();
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CreateOrder(
                                                          orderListClass:
                                                              snapshot
                                                                  .data[index],
                                                          longitude:
                                                              userLocation
                                                                  .longitude
                                                                  .toString(),
                                                          latitude: userLocation
                                                              .latitude
                                                              .toString(),
                                                        ))).then((value) {
                                              Navigator.of(context).pop();
                                              setState(() {});
                                            });
                                          },
                                          child: const Text(
                                            "View",
                                            style: TextStyle(
                                                color: Colors.blueGrey),
                                          )),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                    ],
                                  ));
                        }
                      },
                      child: OrdersList(
                        customerName: snapshot.data[index].customerName,
                        address: snapshot.data[index].address,
                        complete: snapshot.data[index].complete,
                        dateTime: snapshot.data[index].dateTime,
                        time: snapshot.data[index].time,
                        sent: snapshot.data[index].sent,
                        orderId: snapshot.data[index].orderId,
                        total: snapshot.data[index].total,
                      ),
                    );
                  })
              : Center(
                  child: Text(
                    "No orders found",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var location = Location();
          bool enabled = await location.serviceEnabled();
          print(enabled);
          print("The user wants to add an order.... Hurry!");
          if (!enabled) {
            //_requestPermission(ph.Permission.location);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: new Text(
                  "Please turn on Location services to create an order..."),
            ));
          } else if (!await FolderStructure.checkPermission(
              ph.Permission.location)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: new Text(
                  "Location permission not granted, Click ask button and press while using app to grant permission"),
              action: SnackBarAction(
                label: "Ask",
                onPressed: () {
                  _requestPermission(ph.Permission.location);
                },
              ),
            ));
          } else {
            var userLocation = await location.getLocation();
            print("longitude: " +
                userLocation.longitude.toString() +
                ", latitude: " +
                userLocation.latitude.toString());
            //OrdersDatabaseHelper.getOrdersList("ASC");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateOrder(
                          orderListClass: null,
                          longitude: userLocation.longitude.toString(),
                          latitude: userLocation.latitude.toString(),
                        ))).then((value) {
              /*MARK ORDERS COMPLETE IS NOT WORKING AS INTENDED, FUCK MY LIFE NVM I AM GOD*/
              OrdersDatabaseHelper.markOrdersComplete();
              setState(() {});
            });
          }
        },
        child: Icon(Icons.add),
        elevation: 2.0,
        tooltip: "Create Order",
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        elevation: 0,
        color: Colors.blueGrey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PopupMenuButton(
                tooltip: "Sort by",
                icon: Icon(Icons.sort),
                itemBuilder: (context) => <PopupMenuEntry<Sort>>[
                      PopupMenuItem(
                        child: Text("Ascending"),
                        value: Sort.ASC,
                        onTap: () {
                          setState(() {
                            _sortOrder = "ASC";
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: Text("Descending"),
                        value: Sort.DESC,
                        onTap: () {
                          setState(() {
                            _sortOrder = "DESC";
                          });
                        },
                      ),
                    ]),
            IconButton(
              tooltip: "Filter list of orders",
              icon: Icon(Icons.filter_alt),
              onPressed: () async {
                showModalBottomSheet(
                  isScrollControlled: false,
                  context: context,
                  builder: (context) {
                    return Container(
                      child: FilterOrdersList(),
                    );
                  },
                ).then(
                  (value) {
                    if (StorageUtil.getInt("fromDate") > 1 &&
                        StorageUtil.getInt("toDate") > 1) {
                      StorageUtil.getInstance();
                      setState(() {
                        fromDate = DateTime.fromMillisecondsSinceEpoch(
                            StorageUtil.getInt("fromDate"));
                        toDate = DateTime.fromMillisecondsSinceEpoch(
                            StorageUtil.getInt("toDate"));
                      });
                    } else
                      setState(() {
                        fromDate = null;
                        toDate = null;
                      });
                    return true;
                  },
                );
              },
            ),
            IconButton(
                tooltip: "Search current orders list",
                icon: Icon(Icons.search),
                onPressed: () => {
                      setState(() {
                        _searchMode = !_searchMode;
                      })
                    }),
            IconButton(
              tooltip: "Export and send orders",
              icon: Icon(Icons.send),
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: false,
                    context: context,
                    builder: (context) {
                      return Container(
                        child: ExportOrder(),
                      );
                    }).then((value) {
                  setState(() {});
                });
              },
            ),
          ],
        ),
      ),
      /*
        Delegate the navigation drawer in seperate component file to ease the code.
      */
      drawer: NavigationDrawer(),
    );
  }
}
