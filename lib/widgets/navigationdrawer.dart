import 'dart:io';

import 'package:booking_app/helpers/StorageUtil.dart';
import 'package:booking_app/helpers/customerDatabase.dart';
import 'package:booking_app/helpers/folderStructure.dart';
import 'package:booking_app/helpers/ordersDBHelper.dart';
import 'package:booking_app/helpers/productDBHelper.dart';
import 'package:booking_app/models/product.dart';
import 'package:booking_app/screens/fileshistory.dart';
import 'package:booking_app/widgets/salemanDetails.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/customer.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  bool _proFileSuccess = false;
  bool _custFileSuccess = false;

  FolderStructure folderStructure = FolderStructure();
  final List<Customer> customers = <Customer>[];
  List<Product> products = <Product>[];
  String _unitName = "";
  String _unitAddress = "";
  String _salemanId = "SalemanID: ";
  String _salemanName = "Saleman Name: ";
  String _orderCount = "Today orders count: ";
  String _orderAmount = "Today orders amount: ";

  Future<bool> _checkPermissionAndDirectory() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 30) {
      if (!await FolderStructure.checkPermission(
          Permission.manageExternalStorage)) {
        print(FolderStructure.checkPermission(Permission.manageExternalStorage)
                .toString() +
            " Version " +
            androidInfo.version.sdkInt.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: new Text("Manage external storage permission not granted"),
          action: SnackBarAction(
            label: "Ask",
            onPressed: () {
              FolderStructure.requestPermission(
                  Permission.manageExternalStorage);
            },
          ),
        ));
        return false;
      }
    }
    if (!await FolderStructure.checkPermission(Permission.storage)) {
      print("Storage permission denied");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: new Text("Storage permission not granted"),
        action: SnackBarAction(
          label: "Ask",
          onPressed: () {
            FolderStructure.requestPermission(Permission.storage);
          },
        ),
      ));
      return false;
    }
    if (!await folderStructure.checkRootFolder()) {
      print("Root folder not present");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: new Text("App root folder not exist..."),
        action: SnackBarAction(
          label: "Create",
          onPressed: () {
            folderStructure.createRootFolder();
          },
        ),
      ));
      return false;
    }
    if (!await folderStructure.checkSubFolders()) {
      print("Sub folder not present");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: new Text("App sub-folder not exist..."),
        action: SnackBarAction(
          label: "Create",
          onPressed: () {
            folderStructure.createSubFolders();
          },
        ),
      ));
      return false;
    }
    return true;
  }

  Future<void> _readCustFile() async {
    await StorageUtil.getInstance();
    File? customerFile;

    String _filePath = "";

    if (StorageUtil.getString("customImportPath") != "") {
      _filePath = StorageUtil.getString("customImportPath");
    } else {
      _filePath = await FolderStructure.getImportFilePath() +
          "/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents";
    }
    List<FileSystemEntity> _listFiles = [];
    var dir = Directory(_filePath);
    await dir.list().forEach((element) {
      if (element.toString().contains("CUSTOMERSIMP")) {
        print("Cust files found: " + element.path);
        _listFiles.add(element);
      }
    });
    if (_listFiles.length >= 1) {
      _listFiles.forEach((element) {
        File file = File(element.path);
        if (customerFile == null) {
          customerFile = file;
        }
        if (file
                .lastModifiedSync()
                .compareTo(customerFile!.lastModifiedSync()) >
            0) {
          customerFile = file;
        }
      });
    }
    if (customerFile != null) {
      print("Cust files found (selected): " + customerFile!.path);
      await customerFile!
          .readAsLines()
          .then(
            (line) => line.forEach((string) {
              List<String> lineArray = string.split("~;");
              Customer? customer = Customer(
                  customerId: int.parse(lineArray.elementAt(0)),
                  customerName: lineArray.elementAt(1),
                  regionDescription: lineArray.elementAt(2),
                  address: lineArray.elementAt(3));
              customers.add(customer);
              /*OLD METHOD WHICH FREEZES THE DATABASE, NOT THE MOST ELEGANT SOLUTION
            CustomerDatabase.insertCustomer(customer);*/
            }),
          )
          .whenComplete(() => _custFileSuccess = true);
    }
  }

  Future<void> _readProductFile() async {
    await StorageUtil.getInstance();
    File? productFile;

    String _filePath = "";
    if (StorageUtil.getString("customImportPath") != "") {
      _filePath = StorageUtil.getString("customImportPath");
    } else {
      _filePath = await FolderStructure.getImportFilePath() +
          "/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents/";
    }
    List<FileSystemEntity> listFiles = [];
    Directory dir = Directory(_filePath);
    print(await dir.list().length);
    await dir.list().forEach((element) {
      if (element.toString().contains("PRODUCTSIMP")) {
        print("Product files found: " + element.path);
        listFiles.add(element);
      }
    });
    if (listFiles.length >= 1) {
      listFiles.forEach((element) {
        File file = File(element.path);
        if (productFile == null) {
          productFile = file;
        }
        if (file.lastModifiedSync().compareTo(productFile!.lastModifiedSync()) >
            0) {
          productFile = file;
        }
      });
    }
    int proCounter = 0;
    if (productFile != null) {
      print("Product files found (selected file): " + productFile!.path);
      await productFile!.readAsLines().then((line) {
        line.forEach(
          (string) {
            List<String> productsLineArray = string.split("~;");
            if (proCounter == 0) {
              //Code here to insert Unit name and Unit address into pref
              StorageUtil.putString(
                  "unitName", productsLineArray[0].toString());
              StorageUtil.putString(
                  "unitAddress", productsLineArray[1].toString());
            } else {
              Product? product = Product(
                  code: productsLineArray.elementAt(0),
                  description:
                      productsLineArray.elementAt(1).replaceAll("'", ""),
                  tradePrice: double.parse(productsLineArray.elementAt(2)),
                  companyId: productsLineArray.elementAt(3),
                  companyName: productsLineArray.elementAt(4),
                  groupName: productsLineArray.elementAt(5),
                  retailPrice: double.parse(productsLineArray.elementAt(6)));
              products.add(product);
            }
            proCounter++;
          },
        );
      }).whenComplete(() => _proFileSuccess = true);
    } else {
      print("No file found");
    }
  }

  Future<void> _getSalemanDetailFromPref() async {
    await StorageUtil.getInstance();
    setState(() {
      _salemanId += StorageUtil.getString("salemanId");
      _salemanName += StorageUtil.getString("salemanName");
    });
  }

  Future<void> _getUnitDetailFromPref() async {
    await StorageUtil.getInstance();
    setState(() {
      _unitName = StorageUtil.getString("unitName");
      _unitAddress = StorageUtil.getString("unitAddress");
    });
  }

  _getOrderCountFromDatabase() async {
    var _orderno = await OrdersDatabaseHelper.todayOrderCount();
    setState(() {
      _orderCount += _orderno;
    });
  }

  _getOrderAmountFromDatabase() async {
    var _orderamount = await OrdersDatabaseHelper.amountOfOrdersUnsent();
    setState(() {
      _orderAmount += _orderamount;
    });
  }

  @override
  void initState() {
    super.initState();
    _getSalemanDetailFromPref();
    _getUnitDetailFromPref();
    _getOrderAmountFromDatabase();
    _getOrderCountFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.blueGrey.shade200,
                        Colors.blueGrey.shade400,
                        Colors.blueGrey.shade600,
                        Colors.blueGrey.shade700,
                      ]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/invoice(1).png',
                          fit: BoxFit.scaleDown,
                          height: 50.0,
                          width: 50.0,
                        ),
                        SizedBox(
                          width: 200.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Order Taking App",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Developed by Daira Solutions (0320-0006697)",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.visible,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 24.0,
                      thickness: 5.0,
                    ),
                    new Text(_unitName),
                    new Text(_unitAddress),
                    new Text(_salemanId),
                    new Text(_salemanName),
                    Divider(
                      height: 15.0,
                      thickness: 1.0,
                    ),
                    new Text(_orderCount),
                    new Text(_orderAmount),
                  ],
                )),
          ),
          ListTile(
            title: new Text("Import Customer"),
            subtitle: new Text("Import customer data from device storage."),
            onTap: () async {
              /*
              1. Request Permission.
              2. Check Root folder.
              3. Check Sub Folders.
              4. Read file from Import folder.
              */
              if (await _checkPermissionAndDirectory()) {
                await _readCustFile().whenComplete(
                  () async {
                    CustomerDatabase.insertCustomers(customers);

                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: _custFileSuccess
                              ? const Text("Imported customers complete!")
                              : const Text("Error in Customer Import!"),
                          content: _custFileSuccess
                              ? const Text(
                                  "Imported customers completed without any errors.")
                              : const Text(
                                  "An un-expected error occured in importing customers file."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Ok"),
                            )
                          ],
                        );
                      },
                    );
                  },
                );
                print("Inserting customers in db...");
              } else {
                print("Problem in permission module ... Customer side");
              }
            },
          ),
          ListTile(
            title: new Text("Import Product"),
            subtitle: new Text("Import products data from device storage."),
            onTap: () async {
              if (await _checkPermissionAndDirectory()) {
                await _readProductFile().whenComplete(
                  () {
                    ProductsDatabaseHelper.insertProducts(products);
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: _proFileSuccess
                              ? const Text("Imported products complete!")
                              : const Text("Error in Products Import!"),
                          content: _proFileSuccess
                              ? const Text(
                                  "Imported products completed without any errors.")
                              : const Text(
                                  "An un-expected error occured in importing products file."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Ok"),
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              } else {
                print("Problem in permission module ... Product side");
              }
            },
          ),
          ListTile(
            title: const Text("Add/Edit Basic Information"),
            subtitle: const Text("Add or Edit Saleman & Unit Information."),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  builder: (context) {
                    return SalemanDetails();
                  });
            },
          ),
          ListTile(
            title: const Text("Use Custom path."),
            subtitle: const Text(
                "You can use custom path, where application will look for files to import."),
            onTap: () {
              String _pathText = "";
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: TextField(
                      maxLines: 2,
                      onChanged: (value) {
                        _pathText = value;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: const Text("Custom Path"),
                        hintText:
                            "Please exclude file name and / (slash) from path.",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (_pathText != "") {
                            StorageUtil.getInstance();
                            StorageUtil.putString(
                                "customImportPath", _pathText);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Save"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Files History'),
            subtitle: const Text('List of files generated by user'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FilesHistory()));
            },
          ),
        ],
      ),
    );
  }
}
