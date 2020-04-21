import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:ecom/model/productModel.dart';
import 'package:ecom/network/network.dart';
import 'package:ecom/screen/product/productDetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  var loading = false;
  var cekData = false;

  List<ProductModel> list = [];

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceID;

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      deviceID = androidInfo.id;
      getProduct();
    });
  }

  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response =
        await http.get(NetworkUrl.getFavoriteWithoutLogin(deviceID));
    if (response.statusCode == 200) {
      if (response.contentLength == 2) {
        setState(() {
          loading = false;
          cekData = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          for (Map i in data) {
            list.add(ProductModel.fromJson(i));
          }
          loading = false;
          cekData = true;
        });
      }
    } else {
      setState(() {
        loading = false;
        cekData = false;
      });
    }
  }

  addFavorite(ProductModel model) async {
    setState(() {
      loading = true;
    });
    final response = await http.post(NetworkUrl.addFavoriteWithoutLogin,
        body: {"deviceInfo": deviceID, "idProduct": model.id});
    final data = jsonDecode(response.body);
    int value = data["value"];
    String message = data["message"];
    if (value == 1) {
      getProduct();
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

// mengubah format angka ke format uang indonesia
  final price = NumberFormat("#,###0", "en_US");

  // method for pull refreshf
  Future<void> onRefresh() async {
    getDeviceInfo();
  }

  @override
  void initState() { 
    super.initState();
      getDeviceInfo(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("favorit"),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
              child: ListView(
                children: <Widget>[
                  loading
                        ? Center(
                    child: CircularProgressIndicator(),
                  )
                        : cekData
                    ? 
                    GridView.builder(
                        padding: EdgeInsets.all(8),
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: list.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                border: Border.all(width: 1, color: Colors.grey[200]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Expanded(
                                    child: Stack(
                                      children: <Widget>[
                                        Image.network(
                                          NetworkUrl.baseUrl + "product/${x.cover}",
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
                                                      shape: BoxShape.circle,
                                                      color: Colors.grey[200]),
                                                  child: Icon(Icons.favorite_border)),
                                            ))
                                      ],
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
                      ): Container(
                        child: Center(
                          child: Text(
                            "Mohon maaf product favorit anda kosong",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                ],
              ),
      )
    );
  }
}
