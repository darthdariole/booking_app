import 'package:booking_app/helpers/StorageUtil.dart';
import 'package:flutter/material.dart';

class SalemanDetails extends StatefulWidget {
  const SalemanDetails({Key? key}) : super(key: key);

  @override
  State<SalemanDetails> createState() => _SalemanDetailsState();
}

class _SalemanDetailsState extends State<SalemanDetails> {
  String? _salemanId;
  String? _salemanName;
  String? _unitName;
  String? _unitAddress;

  FocusNode? _salemanIdFocus;
  FocusNode? _salemanNameFocus;
  FocusNode? _unitNameFocus;
  FocusNode? _unitAddressFocus;

  @override
  void initState() {
    _salemanIdFocus = FocusNode();
    _salemanNameFocus = FocusNode();
    _unitNameFocus = FocusNode();
    _unitAddressFocus = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 30.0,
      ),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Basic Setup details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Information saved on Save button press..",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _salemanIdFocus,
                  decoration: InputDecoration(
                    hintText: "Saleman ID",
                  ),
                  onSubmitted: (value) {
                    _salemanNameFocus!.requestFocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _salemanId = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _salemanNameFocus,
                  decoration: InputDecoration(
                    hintText: "Saleman Name",
                  ),
                  onSubmitted: (value) {
                    _unitNameFocus!.requestFocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _salemanName = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _unitNameFocus,
                  onSubmitted: (value) {
                    _unitAddressFocus!.requestFocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _unitName = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Unit Name",
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _unitAddressFocus,
                  decoration: InputDecoration(
                    hintText: "Unit Address",
                  ),
                  onSubmitted: (value) {
                    _salemanIdFocus!.requestFocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _unitAddress = value;
                    });
                  },
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              bool saved = false;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Confirm Save"),
                      content: const Text(
                          "Are you sure you wish to save this information? Previos information will be replaced..."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (_salemanId != null &&
                                _salemanName != null &&
                                _unitName != null &&
                                _unitAddress != null) {
                              if (_salemanId!.isNotEmpty &&
                                  _salemanName!.isNotEmpty &&
                                  _unitAddress!.isNotEmpty &&
                                  _unitName!.isNotEmpty) {
                                StorageUtil.putString(
                                    "salemanId", _salemanId.toString());
                                StorageUtil.putString(
                                    "salemanName", _salemanName.toString());
                                StorageUtil.putString(
                                    "unitAddress", _unitAddress.toString());
                                StorageUtil.putString(
                                    "unitName", _unitName.toString());
                                saved = true;
                              } else {}
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text("Save"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  }).then((value) {
                if (saved) {
                  Navigator.pop(context);
                }
              });
            },
            child: new Text("Save"),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Delete Basic Information"),
                      content: const Text(
                          "Are you sure? This will delete all basic information."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            StorageUtil.clearPrefs();
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    );
                  });
            },
            child: new Text(
              "Reset",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
