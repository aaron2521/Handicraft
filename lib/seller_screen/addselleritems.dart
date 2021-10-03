import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handicraft/Widgets/color.dart';
import 'package:handicraft/Widgets/progress.dart';
import 'package:handicraft/seller_screen/sellerhome.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:string_validator/string_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handicraft/splashScreen.dart';
import 'package:image_cropper/image_cropper.dart';

class AddItemsBySeller extends StatefulWidget {
  @override
  _AddItemsBySellerState createState() => _AddItemsBySellerState();
}

class _AddItemsBySellerState extends State<AddItemsBySeller> {
  File _imageFile;
  final _picker = ImagePicker();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ADD ITEM",
          style: GoogleFonts.koHo(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 38,
              color: Colors.white38),
        ),
      ),
      backgroundColor: cream,
      body: processing == true
          ? Center(child: circularProgress())
          : SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: bgcolor,
                              border: Border.all(color: mehron, width: 5)),
                          height: 200,
                          width: 200,
                          child: _imageFile == null
                              ? Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 50,
                                )
                              : Image.file(_imageFile),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                void addImage() async {
                                  final pickedFile = await _picker.getImage(
                                      source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    File cropped = await ImageCropper.cropImage(
                                      sourcePath: pickedFile.path,
                                      aspectRatio:
                                          CropAspectRatio(ratioX: 1, ratioY: 1),
                                      compressQuality: 100,
                                      maxWidth: 700,
                                      maxHeight: 700,
                                      compressFormat: ImageCompressFormat.jpg,
                                      androidUiSettings: AndroidUiSettings(
                                        toolbarColor: Colors.amber,
                                        toolbarTitle: "Adjust Image",
                                        statusBarColor: Colors.lightGreenAccent,
                                        backgroundColor: Colors.white,
                                        activeControlsWidgetColor: Colors.black,
                                        cropFrameColor: Colors.deepOrange,
                                        cropGridColor: Colors.purple,
                                      ),
                                    );
                                    setState(() {
                                      _imageFile = File(cropped.path);
                                    });
                                  }
                                }

                                addImage();
                              },
                              style: ElevatedButton.styleFrom(primary: mehron),
                              child: Text("Add Image"),
                            ),
                            _imageFile == null
                                ? Container()
                                : SizedBox(width: 20),
                            _imageFile == null
                                ? Container()
                                : ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _imageFile = null;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: mehron),
                                    child: Text("Remove"),
                                  ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          cursorColor: pink,
                          decoration: InputDecoration(
                              labelStyle: TextStyle(color: pink),
                              focusColor: pink,
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                              labelText: "Title",
                              prefixIcon: Icon(
                                FontAwesomeIcons.tags,
                                color: pink,
                              )),
                          controller: _title,
                          validator: (text) {
                            if (text.isNotEmpty)
                              return null;
                            else
                              return "Value can't be blank";
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          cursorColor: pink,
                          decoration: InputDecoration(
                              labelStyle: TextStyle(color: pink),
                              focusColor: pink,
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                              labelText: "Price",
                              prefixIcon: Icon(
                                FontAwesomeIcons.rupeeSign,
                                color: pink,
                              )),
                          controller: _price,
                          validator: (text) {
                            if ((isFloat(text.trim()) || isInt(text.trim())) &&
                                text.isNotEmpty)
                              return null;
                            else
                              return "Enter proper value";
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          cursorColor: pink,
                          decoration: InputDecoration(
                              labelStyle: TextStyle(color: pink),
                              focusColor: pink,
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                              labelText: "Description",
                              prefixIcon: Icon(
                                FontAwesomeIcons.book,
                                color: pink,
                              )),
                          controller: _desc,
                          validator: (text) {
                            if (text.isNotEmpty)
                              return null;
                            else
                              return "Can't be empty";
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () {
                              if (_imageFile == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Please add image"),
                                  duration: Duration(seconds: 2),
                                ));
                              } else {
                                if (_formKey.currentState.validate()) {
                                  uploadButton();
                                } else {
                                  print("Something wrong");
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(primary: mehron),
                            child: Text("Submit"))
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  uploadButton() async {
    setState(() {
      processing = true;
    });
    String imageURL = await uploadImageAndGetURL(_imageFile);
    saveAllDataToFirebase(imageURL);
  }

  Future<String> uploadImageAndGetURL(img) async {
    final Reference itemPicRef =
        FirebaseStorage.instance.ref().child("Seller Item Pics");
    String nameForPicture = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask =
        itemPicRef.child(nameForPicture + ".jpg").putFile(img);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveAllDataToFirebase(String imgURL) async {
    await FirebaseFirestore.instance.collection("Items").doc().set({
      "title": _title.text.trim(),
      "imageURL": imgURL,
      "price": _price.text.trim(),
      "desc": _desc.text.trim(),
      "seller": App.sharedPreferences.getString("email"),
      "available": "instock"
    }).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Item uploaded successfully"),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        processing = false;
        _imageFile = null;
        _title.clear();
        _price.clear();
        _desc.clear();
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SellerHome()));
    }).onError((error, stackTrace) => print(error));
  }
}
