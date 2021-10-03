import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handicraft/Widgets/color.dart';
import 'package:handicraft/Widgets/fonts.dart';
import 'package:handicraft/Widgets/progress.dart';
import 'package:handicraft/customer_screen/customerhome.dart';
import 'package:handicraft/customer_screen/payment.dart';
import 'package:handicraft/sidebar/sidebar_layout.dart';
import 'package:handicraft/splashScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:string_validator/string_validator.dart';

class DeliveryPage extends StatefulWidget {
  String imageUrl, title, price, desc, itemID, seller;
  DeliveryPage(this.imageUrl, this.title, this.price, this.desc, this.itemID,
      this.seller);

  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final titleController1 = TextEditingController();
  final titleControllerName = TextEditingController();
  final phonenoC = TextEditingController();
  final titleController2 = TextEditingController();
  final titleController3 = TextEditingController();
  final titleController4 = TextEditingController();

  int selectedRadioTile = 0;

  // bool report;
  bool processing = false;
  final _formKey = GlobalKey<FormState>();
  QuerySnapshot data;
  bool pageLodaing = true;

  Future getUpi() async {
    data = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: widget.seller)
        .get();
    // print(data);
    print(data.docs[0]["upi"]);
  }

  @override
  Future<void> initState() {
    super.initState();
    getUpi().whenComplete(() {
      setState(() {
        pageLodaing = false;
      });
    });
    // getData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: bgcolor,
        title: Text("Shipping Address",
            style: GoogleFonts.koHo(
              color: mehron,
              fontWeight: FontWeight.bold,
            )),
        elevation: 0,
        leading: CloseButton(
          color: mehron,
        ),
      ),
      body: processing == true
          ? Center(child: circularProgress())
          : Container(
              height: size.height,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text("Payment Type"),
                            ),
                            RadioListTile(
                                subtitle: Text("Available"),
                                activeColor: Colors.black,
                                value: 0,
                                groupValue: selectedRadioTile,
                                onChanged: (val) {
                                  setState(() {
                                    selectedRadioTile = 0;
                                  });
                                },
                                title: Text("COD", style: b_14pink())),
                            if (Platform.isAndroid)
                              pageLodaing
                                  ? Center(child: circularProgress())
                                  : RadioListTile(
                                      subtitle:
                                          data.docs[0]["upi"].toString() != null
                                              ? Text("Available")
                                              : Text("Unavailable"),
                                      activeColor: Colors.black,
                                      value: 1,
                                      groupValue: selectedRadioTile,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedRadioTile = 1;
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Payment(
                                                        amt: 1,
                                                        upiId: data.docs[0]
                                                            ["upi"],
                                                        reciverName: App
                                                            .sharedPreferences
                                                            .getString("email"),
                                                      )));
                                        });
                                      },
                                      title: Text("UPI", style: b_14pink())),
                            Container(
                              child: Column(
                                children: [
                                  TextField1(
                                      icon: Icons.person,
                                      title: "Name",
                                      titleController: titleControllerName),
                                  TextField1(
                                      icon: Icons.phone,
                                      title: "Phone number",
                                      titleController: phonenoC),
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        onChanged: (value) async {
                                          void update(String value) async {
                                            try {
                                              var url = Uri.parse(
                                                  "https://api.postalpincode.in/pincode/$value");
                                              var result = await http.get(url);
                                              var data =
                                                  jsonDecode(result.body);
                                              print(data[0]["PostOffice"][0]
                                                  ["State"]);
                                              print(data[0]["PostOffice"][0]
                                                  ["District"]);
                                              var state = data[0]["PostOffice"]
                                                  [0]["State"];
                                              var city = data[0]["PostOffice"]
                                                  [0]["District"];
                                              if (state.toString().isNotEmpty &&
                                                  city.toString().isNotEmpty) {
                                                setState(() {
                                                  titleController1.text =
                                                      data[0]["PostOffice"][0]
                                                          ["State"];
                                                  titleController2.text =
                                                      data[0]["PostOffice"][0]
                                                          ["District"];
                                                });
                                              }
                                            } catch (e) {
                                              print(e);
                                            }
                                          }

                                          update(value);
                                        },
                                        textAlign: TextAlign.center,
                                        cursorColor: pink,
                                        decoration: InputDecoration(
                                            focusColor: pink,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                const Radius.circular(26.0),
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                const Radius.circular(26.0),
                                              ),
                                            ),
                                            filled: true,
                                            prefixIcon: Icon(Icons.pin_drop,
                                                color: mehron),
                                            // icon: Icon(icon,color: Colors.white,),
                                            hintStyle: TextStyle(color: mehron),
                                            hintText: "PinCode",
                                            fillColor: cream),
                                        validator: (title) => title.length ==
                                                    6 &&
                                                title.isNotEmpty &&
                                                isNumeric(title) &&
                                                titleController1
                                                    .text.isNotEmpty &&
                                                titleController2.text.isNotEmpty
                                            ? null
                                            : "Please check your PinCode",
                                        controller: titleController4,
                                      ),
                                    ),
                                  ),
                                  TextField1(
                                      icon: Icons.map,
                                      title: "State",
                                      titleController: titleController1),
                                  TextField1(
                                      icon: Icons.location_city,
                                      title: "City",
                                      titleController: titleController2),
                                  TextField1(
                                      icon: Icons.landscape,
                                      title: "Locality",
                                      titleController: titleController3),
                                ],
                              ),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: SizedBox(
                        height: 50,
                        width: size.width * 0.95,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            // padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: size.width * 0.36)),
                            backgroundColor: MaterialStateProperty.all(pink),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                // side: BorderSide(color: Colors.)
                              ),
                            ),
                          ),
                          onPressed: () {
                            final isValid = _formKey.currentState.validate();
                            if (isValid) {
                              buyNow();
                              // Navigator.push(context, MaterialPageRoute(
                              //     builder: (context) => OrderSuccessFull()));
                            }
                          },
                          child: Text(
                            "Confirm Order",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }

  void buyNow() async {
    setState(() {});

    int flag = 1;
    var data = await FirebaseFirestore.instance
        .collection("Items")
        .doc(widget.itemID)
        .get();
    if (data.data()['available'] == "stockout") {
      flag = 0;
    }
    if (flag == 1) {
      setState(() {
        processing = true;
      });
      saveAllDataToFirebase();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Order out of Stock"),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  saveAllDataToFirebase() async {
    // var data = await FirebaseFirestore.instance
    //     .collection("users")
    //     .where("phone", isEqualTo: App.sharedPreferences.get("email"))
    //     .get();
//         for (int i = 0; i < data.docs.length; i++){
// var
//         }
    await FirebaseFirestore.instance.collection("Orders").doc().set({
      "title": widget.title.trim(),
      "Payment": selectedRadioTile == 0 ? "COD" : "UPI",
      "name": titleControllerName.text.trim(),
      "time": DateTime.now(),
      "imageURL": widget.imageUrl,
      "itemId": widget.itemID.trim(),
      "phone": phonenoC.text.trim(),
      "price": widget.price.trim(),
      "seller": widget.seller.trim(),
      "customer": App.sharedPreferences.getString("email"),
      "pinCode": titleController4.text.trim(),
      "address": titleController3.text.trim() +
          ", " +
          titleController2.text.trim() +
          ", " +
          titleController1.text.trim(),
      "status": "Order Placed",
      "time": DateTime.now()
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Order Successful"),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        processing = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SidebarLayout()));
    });
  }
}

class TextField1 extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController titleController;
  const TextField1({
    Key key,
    this.icon,
    this.title,
    this.titleController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        textAlign: TextAlign.center,
        cursorColor: pink,
        decoration: InputDecoration(
            focusColor: pink,
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(26.0),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(26.0),
              ),
            ),
            filled: true,
            prefixIcon: Icon(icon, color: mehron),
            // icon: Icon(icon,color: Colors.white,),
            hintStyle: TextStyle(color: mehron),
            hintText: title,
            fillColor: cream),
        validator: (title) =>
            title != null && title.isEmpty ? "This cannot be empty" : null,
        controller: titleController,
      ),
    );
  }
}

// class TextField12 extends StatefulWidget {
//
//   final IconData icon;
//   final String title;
//   final TextEditingController titleController;
//   final TextEditingController titleController1;
//   final TextEditingController titleController2;
//   const TextField12({
//     Key key, this.icon, this.title, this.titleController, this.titleController1, this.titleController2,
//   }) : super(key: key);
//
//   @override
//   _TextField12State createState() => _TextField12State();
// }
//
// class _TextField12State extends State<TextField12> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextFormField(
//         onChanged: (value) async{
//           void update(String value)  async{
//           var url=Uri.parse("https://api.postalpincode.in/pincode/$value");
//           var result=await http.get(url);
//           var data=jsonDecode(result.body);
//           print(data[0]["PostOffice"][0]["State"]);
//           setState(() {
//             widget.titleController1.text = data[0]["PostOffice"][0]["State"];
//           });
//           }
//           update(value);
//         },
//         textAlign: TextAlign.center,
//         decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: const BorderRadius.all(
//                 const Radius.circular(26.0),
//               ),
//             ),
//             filled: true,
//             prefixIcon: Icon(widget.icon,color: Color(0xff44a7c4),),
//             // icon: Icon(icon,color: Colors.white,),
//             hintStyle: TextStyle(color: Colors.grey[800]),
//             hintText: widget.title,
//             fillColor: Colors.white
//         ),
//         validator: (title) =>
//          title.length == 6 && title.isNotEmpty && isNumeric(title)? null : "This cannot be empty",
//         controller: widget.titleController,
//       ),
//     );
//   }
// }
