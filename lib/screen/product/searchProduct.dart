import 'dart:convert';

import 'package:ecom/model/productModel.dart';
import 'package:ecom/network/network.dart';
import 'package:ecom/screen/product/productDetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  var loading = false;
  List<ProductModel> list = [];
  List<ProductModel> listSearch = [];

  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getProduct);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (Map i in data) {
          list.add(ProductModel.fromJson(i));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  TextEditingController searchController = TextEditingController();

  onSearch(String text) async {
    listSearch.clear();
    if (text.isEmpty) {
      setState(() {});
    }
    list.forEach((a) {
      if (a.productName.toLowerCase().contains(text)) listSearch.add(a);
    });
    setState(() {});
  }

  // mengubah format angka ke format uang indonesia
  final price = NumberFormat("#,###0", "en_US");

  // for filter by category
  var filter = false;
  int index = 0;

  // method for pull refresh
  Future<void> onRefresh() async {
    getProduct();
    filter = false;
  }

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 50,
          alignment: Alignment.center,
          padding: EdgeInsets.all(4),
          child: TextField(
              controller: searchController,
              onChanged: onSearch,
              textAlign: TextAlign.left,
              autofocus: true,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search your product ..",
                fillColor: Colors.white,
                filled: true,
                suffixIcon:
                    IconButton(icon: Icon(Icons.search), onPressed: () {}),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(style: BorderStyle.none)),
              )),
        ),
      ),
      body: Container(
          child: loading
              ? Center(child: CircularProgressIndicator())
              : searchController.text.isNotEmpty || listSearch.length != 0
                  ? GridView.builder(
                      padding: EdgeInsets.all(8),
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: listSearch.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8),
                      itemBuilder: (context, i) {
                        final x = listSearch[i];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductDetail(x)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(width: 1, color: Colors.grey[200]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Image.network(
                                    NetworkUrl.baseUrl + "product/${x.cover}",
                                    fit: BoxFit.cover,
                                    height: 180.0,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "${x.productName}",
                                  style: TextStyle(color: Colors.pinkAccent),
                                ),
                                Text("Rp. ${price.format(x.sellingPrice)}"),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      child: Center(
                        child: Text("Please search yout item"),
                      ),
                    )),
    );
  }
}
