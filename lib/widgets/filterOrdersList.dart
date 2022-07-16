import 'package:booking_app/helpers/StorageUtil.dart';
import 'package:flutter/material.dart';

class FilterOrdersList extends StatefulWidget {
  const FilterOrdersList({Key? key}) : super(key: key);

  @override
  State<FilterOrdersList> createState() => _FilterOrdersListState();
}

class _FilterOrdersListState extends State<FilterOrdersList> {
  bool unsent = false;
  bool complete = false;
  String filterText = "";
  String _fromDateString = "";
  String _toDateString = "";
  DateTime? _fromDate;
  DateTime? _toDate;

  _getDateFromPrefs() async {
    await StorageUtil.getInstance();
    if (StorageUtil.getInt("fromDate") != 0 &&
        StorageUtil.getInt("toDate") != 0) {
      setState(() {
        _fromDate =
            DateTime.fromMillisecondsSinceEpoch(StorageUtil.getInt("fromDate"));
        _fromDateString = ": " +
            _fromDate!.day.toString() +
            "/" +
            _fromDate!.month.toString() +
            "/" +
            _fromDate!.year.toString();

        _toDate =
            DateTime.fromMillisecondsSinceEpoch(StorageUtil.getInt("toDate"));
        _toDateString = ": " +
            _toDate!.day.toString() +
            "/" +
            _toDate!.month.toString() +
            "/" +
            _toDate!.year.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getDateFromPrefs();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Filter Orders List",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          /*
          TIME FILTER HERE
          */
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate:
                          _fromDate == null ? DateTime.now() : _fromDate!,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2050));
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
                      initialDate: _toDate == null ? DateTime.now() : _toDate!,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2050));
                  if (picked != null) {
                    setState(() {
                      _toDate = picked.add(Duration(hours: picked.hour + 23));
                      _toDateString = ": " +
                          _toDate!.day.toString() +
                          "/" +
                          _toDate!.month.toString() +
                          "/" +
                          _toDate!.year.toString();
                    });
                  }
                },
                child: Text("To Date" + _toDateString),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  StorageUtil.getInstance();
                  if (_fromDate != null && _toDate != null) {
                    StorageUtil.putInt(
                        "fromDate", _fromDate!.millisecondsSinceEpoch);
                    StorageUtil.putInt(
                        "toDate", _toDate!.millisecondsSinceEpoch);
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Warning"),
                            content: Text("No date selected."),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Ok"))
                            ],
                          );
                        });
                  }

                  Navigator.pop(context, false);
                },
                child: const Text("Apply"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Reset Filter?"),
                              content: const Text(
                                  "Are you sure? This will delete the currently selected filter parameters."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    StorageUtil.getInstance();
                                    StorageUtil.removeKey("fromDate");
                                    StorageUtil.removeKey("toDate");
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Reset",
                                    style: TextStyle(color: Colors.red),
                                  ),
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
                        ).then((value) => Navigator.pop(context, true));
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.red),
                      ))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
