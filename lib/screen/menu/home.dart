import 'dart:convert';

import 'package:ecom/model/categoryProductModel.dart';
import 'package:ecom/model/productModel.dart';
import 'package:ecom/network/network.dart';
import 'package:ecom/screen/product/addProduct.dart';
import 'package:ecom/screen/product/productDetail.dart';
import 'package:ecom/screen/product/searchProduct.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:device_info/device_info.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var loading = false;

  List<CategoryProductModel> listCategory = [];
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String DeviceID;

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      DeviceID = androidInfo.id;
    });
  }

  getProductWithCategory() async {
    setState(() {
      loading = true;
    });
    listCategory.clear();
    final response = await http.get(NetworkUrl.getProductCategory);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (Map i in data) {
          listCategory.add(CategoryProductModel.fromJson(i));
        }
        loading = false;
      });
    } else {
      loading = false;
    }
  }

  List<ProductModel> list = [];

  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getProduct);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
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

  // mengubah format angka ke format uang indonesia
  final price = NumberFormat("#,###0", "en_US");

  // for filter by category
  var filter = false;
  int index = 0;

  // method for pull refresh
  Future<void> onRefresh() async {
    getProduct();
    getProductWithCategory();
    filter = false;
  }

  addFavorite(ProductModel model) async {
    setState(() {
      loading = true;
    });
    final response = await http.post(NetworkUrl.addFavoriteWithoutLogin,
        body: {"deviceInfo": DeviceID, "idProduct": model.id});
    final data = jsonDecode(response.body);
    int value = data["value"];
    String message = data["message"];
    if (value == 1) {
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      loading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getProduct();
    getProductWithCategory();
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {})
          ],
          title: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchProduct()));
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              padding: EdgeInsets.all(4),
              child: TextField(
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Search your product ..",
                    fillColor: Colors.white,
                    filled: true,
                    enabled: false,
                    suffixIcon:
                        IconButton(icon: Icon(Icons.search), onPressed: () {}),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(style: BorderStyle.none)),
                  )),
            ),
          ),
        ),
        floatingActionButton: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddProduct()));
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.purpleAccent,
            ),
            child: Text(
              "Add Product",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    // kategori product
                    Container(
                      height: 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listCategory.length,
                        itemBuilder: (context, i) {
                          final a = listCategory[i];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                filter = true;
                                index = i;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.red),
                              child: Center(
                                child: Text(
                                  a.categoryName,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),
                    // Product
                    filter
                        ? listCategory[index].product.length == 0
                            ? Container(
                                child: Center(
                                  child: Text(
                                    "Mohon maaf product kategori ini kosong",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.all(8),
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount: listCategory[index].product.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8),
                                itemBuilder: (context, i) {
                                  final x = listCategory[index].product[i];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetail(x)),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1, color: Colors.grey[200]),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Expanded(
                                            child: Image.network(
                                              NetworkUrl.baseUrl +
                                                  "product/${x.cover}",
                                              fit: BoxFit.cover,
                                              height: 180.0,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            "${x.productName}",
                                            style: TextStyle(
                                                color: Colors.pinkAccent),
                                          ),
                                          Text(
                                              "Rp. ${price.format(x.sellingPrice)}"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                        : GridView.builder(
                            padding: EdgeInsets.all(8),
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: list.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8),
                            itemBuilder: (context, i) {
                              final x = list[i];
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
                                    border: Border.all(
                                        width: 1, color: Colors.grey[200]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Expanded(
                                        child: Stack(
                                          children: <Widget>[
                                            Image.network(
                                              NetworkUrl.baseUrl +
                                                  "product/${x.cover}",
                                              fit: BoxFit.cover,
                                              height: 180.0,
                                            ),
                                            Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    addFavorite(x);
                                                  },
                                                  child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              Colors.grey[200]),
                                                      child: Icon(Icons
                                                          .favorite_border)),
                                                ))
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "${x.productName}",
                                        style:
                                            TextStyle(color: Colors.pinkAccent),
                                      ),
                                      Text(
                                          "Rp. ${price.format(x.sellingPrice)}"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ));
  }
}
