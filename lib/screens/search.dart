import 'package:booking_app/helpers/customerDatabase.dart';
import 'package:booking_app/helpers/productDBHelper.dart';
import 'package:booking_app/widgets/customerListItem.dart';
import 'package:booking_app/widgets/productListItem.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final bool productSearch;
  final String searchTextFromCreateOrder;

  Search(
      {required this.productSearch, required this.searchTextFromCreateOrder});
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String? searchText;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    this.searchText = widget.searchTextFromCreateOrder;
    _searchController..text = searchText!;

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 50.0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          TextField(
            controller: _searchController,
            onChanged: (text) {
              print("Search text: " + searchText!);

              setState(() {
                searchText = text;
              });
            },
            autofocus: true,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              isDense: false,
              hintText: "Type to Search...",
            ),
          ),

          /*
          TextFormField(
            initialValue: ,
            decoration: InputDecoration(
              hintText: "Type to search...",
            ),
          ),
          */
        ]),
      ),
      body: FutureBuilder(
        initialData: [],
        future: widget.productSearch
            ? ProductsDatabaseHelper.getFilterProducts(searchText)
            : CustomerDatabase.getFilterCustomer(searchText),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                      onTap: () {
                        //print(snapshot.data[index].customerName);
                        Navigator.pop(context, snapshot.data[index]);
                      },
                      child: widget.productSearch
                          ? ProductListItem(
                              code: snapshot.data[index].code,
                              description: snapshot.data[index].description,
                              companyName: snapshot.data[index].companyName,
                              tradePrice:
                                  snapshot.data[index].tradePrice.toString(),
                            )
                          : CustomerListItem(
                              customerId:
                                  snapshot.data[index].customerId.toString(),
                              customerName: snapshot.data[index].customerName,
                              address: snapshot.data[index].address,
                              regionDescription:
                                  snapshot.data[index].regionDescription,
                            ),
                    );
                  }),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}

/*
TODO: Keep in mind 2 ways to filter list either via database (LIKE QUERY METHOD) or via list.where. 
ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: new Text(list[index].customerId.toString() +
                        " / " +
                        list[index].customerName),
                    subtitle: new Text(list[index].address),
                    isThreeLine: true,
                  );
                },
              )
*/