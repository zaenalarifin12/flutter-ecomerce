import 'dart:convert';

import 'package:ecom/model/categoryProductModel.dart';
import 'package:ecom/network/network.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChooseCategoryProduct extends StatefulWidget {
  @override
  _ChooseCategoryProductState createState() => _ChooseCategoryProductState();
}

class _ChooseCategoryProductState extends State<ChooseCategoryProduct> {
  var loading = false;

  List<CategoryProductModel> listCategory = [];
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

  @override
  void initState() { 
    super.initState();
    getProductWithCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Choose kategori product"),
          elevation: 1,
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: listCategory.length,
                itemBuilder: (context, i) {
                  final a = listCategory[i];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, a);
                    },
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(a.categoryName),
                          Container(
                            child: Divider(
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }));
  }
}
