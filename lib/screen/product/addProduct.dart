import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:ecom/model/categoryProductModel.dart';
import 'package:ecom/network/network.dart';
import 'package:ecom/screen/product/chooseCategory.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  File image;

  gallery() async {
    var _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = _image;
    });
  }

  TextEditingController namaController = TextEditingController();
  TextEditingController sellingController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  CategoryProductModel model;

  pilihCategory() async {
    model = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ChooseCategoryProduct()));

    setState(() {
      categoryController = TextEditingController(text: model.categoryName);
    });
  }

  save() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Processing"),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 4,
                  ),
                  Text("Loading")
                ],
              ),
            ),
          );
        });

    try {
      var stream = http.ByteStream(DelegatingStream.typed(image.openRead()));
      var length = await image.length();
      var url = Uri.parse(NetworkUrl.addProduct);
      var request = http.MultipartRequest("POST", url);
      var multiPartFile = http.MultipartFile("image", stream, length,
          filename: path.basename(image.path));

      request.fields["productName"] = namaController.text;
      request.fields["sellingPrice"] = sellingController.text;
      request.fields["description"] = descriptionController.text;
      request.fields["idCategory"] = model.id;
      request.files.add(multiPartFile);

      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        final data = jsonDecode(value);
        int valueGet = data["value"];
        // String message = data["message"];
        if (valueGet == 1) {
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            InkWell(
              onTap: (){
                pilihCategory();
              },
              child: TextField(
                enabled: false,
                controller: categoryController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Product Category"),
              ),
            ),
            TextField(
              controller: namaController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: "Product name"),
            ),
            TextField(
              controller: sellingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Selling price"),
            ),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: "Deskripsi"),
            ),
            SizedBox(
              height: 16,
            ),
            InkWell(
                onTap: gallery,
                child: (image == null)
                    ? Image.asset("././assets/images/placeholder.png",
                        fit: BoxFit.cover)
                    : Image.file(
                        image,
                        fit: BoxFit.cover,
                      )),
            SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: () {
                save();
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.purple,
                      Colors.red,
                    ],
                  ),
                ),
                child: Text(
                  "Add Product",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
