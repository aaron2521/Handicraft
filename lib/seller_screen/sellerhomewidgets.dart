import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:handicraft/Widgets/color.dart';
import 'package:handicraft/Widgets/fonts.dart';
import 'package:handicraft/Widgets/progress.dart';
import 'package:handicraft/splashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:handicraft/customer_screen/customerCart.dart';
import 'package:handicraft/data/data.dart';
import 'package:handicraft/auth/login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:intl/intl.dart';

class OrdersArrived extends StatefulWidget {
  @override
  _OrdersArrivedState createState() => _OrdersArrivedState();
}

class _OrdersArrivedState extends State<OrdersArrived> {
  bool pageloading = true;
  List<SellerPanel> list = [];
  final df = new DateFormat('dd-MM-yyyy hh:mm a');

  Future<void> fetchOrders() async {
    list.clear();
    var data = await FirebaseFirestore.instance
        .collection("Orders")
        .where("seller", isEqualTo: App.sharedPreferences.getString("email"))
        .get();
    for (int i = 0; i < data.docs.length; i++) {
      var img = await FirebaseFirestore.instance
          .collection("Items")
          .doc(data.docs[i].data()['itemId'])
          .get();
      var imgUrl = img.data()['imageURL'];
      var cus = data.docs[i].data()["customer"];
      var userdata =
          await FirebaseFirestore.instance.collection("users").doc(cus).get();
      var phone = userdata.data()["phone"];

      SellerPanel item = SellerPanel(
          data.docs[i].data()['title'],
          imgUrl.toString(),
          data.docs[i].data()['pinCode'],
          data.docs[i].data()['price'],
          data.docs[i].data()['status'],
          data.docs[i].id,
          data.docs[i].data()['name'],
          phone,
          data.docs[i].data()['address'],
          data.docs[i].data()['time']);

      list.add(item);
    }
    setState(() {});
    print(list.length);
  }

  @override
  void initState() {
    super.initState();
    // fetchOrders().whenComplete(() {
    //   setState(() {
    //     pageloading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cream,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "ORDERS",
            style: GoogleFonts.koHo(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 38,
                color: Colors.white38),
          ),
        ),
        body: RefreshIndicator(
          color: mehron,
          onRefresh: fetchOrders,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Orders")
                        .where("seller",
                            isEqualTo: App.sharedPreferences.getString("email"))
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      return !streamSnapshot.hasData
                          ? Center(child: circularProgress())
                          : ListView.builder(
                              itemCount: streamSnapshot.data.docs.length,
                              itemBuilder: (_, index) {
                                return SellerUI(
                                  streamSnapshot.data.docs[index]['title'],
                                  streamSnapshot.data.docs[index]['imageURL'],
                                  streamSnapshot.data.docs[index]['pinCode'],
                                  streamSnapshot.data.docs[index]['price'],
                                  streamSnapshot.data.docs[index]['status'],
                                  streamSnapshot.data.docs[index].id,
                                  streamSnapshot.data.docs[index]['name'],
                                  streamSnapshot.data.docs[index]['phone'],
                                  streamSnapshot.data.docs[index]['address'],
                                  streamSnapshot.data.docs[index]['time'],
                                  streamSnapshot.data.docs[index]['Payment'],
                                  // list[index].title,
                                  // streamSnapshot
                                  // list[index].imageurl,
                                  // list[index].pincode,
                                  // list[index].price,
                                  // list[index].status,
                                  // list[index].id,
                                  // list[index].name,
                                  // list[index].phone,
                                  // list[index].address,
                                  // list[index].date,
                                );
                              },
                            );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget SellerUI(
      String title,
      String imageurl,
      String pincode,
      String price,
      String status,
      String id,
      String name,
      String phone,
      String address,
      Timestamp date,
      String payment) {
    Size size = MediaQuery.of(context).size;
    print(price);
    print(pincode);
    print(status);

    return Container(
      // color: Colors.black,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: mehron,
          border: Border.all(color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0.0, 5.0),
            ),
          ]),
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "Order id :" + id,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.koHo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      width: size.width * .5,
                      height: size.width * .5,
                      child: Image.network(
                        imageurl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // SizedBox(
                    //   width: 10,
                    // ),
                    Column(
                      children: [
                        if (status == "Order Cancelled")
                          Text(
                            status,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.koHo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        if (status == "Order Shipped")
                          Text(
                            status,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.koHo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        if (status == "Order Placed")
                          Text(
                            "New Order",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.koHo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow,
                            ),
                          ),
                        if (status == "Order Cancelled by Seller")
                          Text(
                            "Order cancelled by us",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.koHo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        Container(
                          width: size.width * 0.5 - 30,
                          // color: Colors.green,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.koHo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.rupeeSign,
                                color: Colors.teal, size: 18),
                            Text(
                              price,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.koHo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Text(
                        //   title,
                        //   textAlign: TextAlign.center,
                        //   style: GoogleFonts.koHo(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
                ExpandChild(
                    child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.koHo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      phone,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.koHo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      address,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.koHo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      pincode,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.koHo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      df.format(date.toDate()),
                      // date.toString(),
                      // date.toDate().day.toString() +
                      //     "/" +
                      //     date.toDate().month.toString() +
                      //     "/" +
                      //     date.toDate().year.toString() +
                      //     '    ' +
                      //     date.toDate().toLocal().hour.toString() +
                      //     ':' +
                      //     date.toDate().minute.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.koHo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Payment Type: " + payment,
                      style: b_16cream(),
                    ),
                    (status == "Order Cancelled" ||
                            status == "Order Shipped" ||
                            status == "Order Cancelled by Seller")
                        ? Container()
                        : Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    void shipped() {
                                      FirebaseFirestore.instance
                                          .collection('Orders')
                                          .doc(id)
                                          .update({
                                        "status": "Order Shipped"
                                      }).whenComplete(() {
                                        setState(() {
                                          // fetchOrders();
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Order shipped"),
                                          duration: Duration(seconds: 2),
                                        ));
                                      });
                                    }

                                    shipped();
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.black54),
                                  child: Text("Order Shipped")),
                              ElevatedButton(
                                  onPressed: () {
                                    void cancelled() {
                                      FirebaseFirestore.instance
                                          .collection('Orders')
                                          .doc(id)
                                          .update({
                                        "status": "Order Cancelled by Seller"
                                      }).whenComplete(() {
                                        setState(() {
                                          // fetchOrders();
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Order cancelled"),
                                          duration: Duration(seconds: 2),
                                        ));
                                      });
                                    }

                                    cancelled();
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black54,
                                  ),
                                  child: Text("Cancel Order")),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          )
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SellerPanel {
  String title, imageurl, pincode, price, status, id, name, phone, address;
  Timestamp date;
  SellerPanel(this.title, this.imageurl, this.pincode, this.price, this.status,
      this.id, this.name, this.phone, this.address, this.date);
}

class ItemModify extends StatefulWidget {
  const ItemModify({Key key}) : super(key: key);

  @override
  _ItemModifyState createState() => _ItemModifyState();
}

class _ItemModifyState extends State<ItemModify> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: cream,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: cream,
            child: Column(
              children: [
                ClipPath(
                  clipper: OvalBottomBorderClipper(),
                  child: Container(
                      color: pink,
                      height: 50,
                      width: size.width,
                      child: Center(
                        child: Text(
                          "Edit",
                          style: GoogleFonts.pattaya(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Items")
                        .where("seller",
                            isEqualTo: App.sharedPreferences.getString("email"))
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      return !streamSnapshot.hasData
                          ? Center(child: circularProgress())
                          : ListView.builder(
                              itemCount: streamSnapshot.data.docs.length,
                              itemBuilder: (_, index) {
                                return MyUI(
                                    streamSnapshot.data.docs[index]['title'],
                                    streamSnapshot.data.docs[index]['price'],
                                    streamSnapshot.data.docs[index]['imageURL'],
                                    streamSnapshot.data.docs[index].id,
                                    streamSnapshot.data.docs[index]
                                        ['available']);
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget MyUI(
      String title, String price, String url, String id, String status) {
    Size size = MediaQuery.of(context).size;
    final _price = TextEditingController();
    String desc = price;
    return Container(
      // color: Colors.black,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: mehron,
          border: Border.all(color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0.0, 5.0),
            ),
          ]),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            width: size.width * .7,
            height: size.width * .6,
            child: Image.network(
              url,
              fit: BoxFit.fill,
            ),
          ),
          // CachedNetworkImage(
          //   imageUrl: url,
          //   imageBuilder: (context, imageProvider) => Container(
          //     height: size.height * 0.3,
          //     width: size.width,
          //     decoration: BoxDecoration(
          //       image: DecorationImage(
          //         image: imageProvider,
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          //   placeholder: (context, url) => CircularProgressIndicator(),
          //   errorWidget: (context, url, error) => Icon(Icons.error),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Item:',
                  style: GoogleFonts.koHo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(5.0)),
                Container(
                  // alignment: Alig,
                  width: size.width * 0.7,
                  child: Text(
                    title,
                    style: GoogleFonts.koHo(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    // textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Price:",
                  style: GoogleFonts.koHo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(5.0)),
                Icon(
                  FontAwesomeIcons.rupeeSign,
                  size: 20.0,
                  color: Colors.white,
                ),
                Text(
                  price,
                  style: GoogleFonts.koHo(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: TextStyle(color: pink),
              cursorColor: pink,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: cream,
                  hintStyle: TextStyle(color: pink),
                  focusColor: pink,
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                  hintText: "Updated Price",
                  prefixIcon: Icon(
                    FontAwesomeIcons.rupeeSign,
                    color: pink,
                  )),
              controller: _price,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.black12),
                onPressed: () {
                  if (_price.text.trim().isNotEmpty) {
                    void update() async {
                      await FirebaseFirestore.instance
                          .collection("Items")
                          .doc(id)
                          .update({"price": _price.text.trim()}).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Price Updated")));
                      });
                    }

                    update();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("Can not update empty price for " + title)));
                  }
                },
                child: Text('Update'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: status == "instock" ? Colors.green : Colors.red),
                onPressed: () {
                  void markStockOut() async {
                    await FirebaseFirestore.instance
                        .collection("Items")
                        .doc(id)
                        .update({"available": "stockout"});
                  }

                  void markStockin() async {
                    await FirebaseFirestore.instance
                        .collection("Items")
                        .doc(id)
                        .update({"available": "instock"});
                  }

                  status == "instock" ? markStockOut() : markStockin();
                },
                child: Text(status == "instock"
                    ? "Mark out of stock"
                    : "Mark stock available"),
              ),
              IconButton(
                onPressed: () {
                  print("deleted btn tap for " + title);
                  void delete() async {
                    await FirebaseFirestore.instance
                        .collection("Items")
                        .doc(id)
                        .delete();
                  }

                  delete();
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      // child: Column(
      //   children: [
      //     Container(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: <Widget>[
      //           Padding(
      //             padding: EdgeInsets.all(5),
      //             child: Text(
      //               "Order id :" + id,
      //               textAlign: TextAlign.center,
      //               style: GoogleFonts.koHo(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.bold,
      //                 color: Colors.white,
      //               ),
      //             ),
      //           ),
      //           Row(
      //             children: [
      //               Container(
      //                 padding: EdgeInsets.all(10),
      //                 width: size.width * .5,
      //                 height: size.width * .5,
      //                 child: Image.network(
      //                   imageurl,
      //                   fit: BoxFit.cover,
      //                 ),
      //               ),
      //               SizedBox(
      //                 width: 20,
      //               ),
      //               Column(
      //                 children: [
      //                   Text(
      //                     title,
      //                     textAlign: TextAlign.center,
      //                     style: GoogleFonts.koHo(
      //                       fontSize: 20,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                   Row(
      //                     children: [
      //                       Icon(FontAwesomeIcons.rupeeSign,
      //                           color: Colors.teal, size: 18),
      //                       Text(
      //                         price,
      //                         textAlign: TextAlign.center,
      //                         style: GoogleFonts.koHo(
      //                           fontSize: 20,
      //                           fontWeight: FontWeight.bold,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                   Text(
      //                     title,
      //                     textAlign: TextAlign.center,
      //                     style: GoogleFonts.koHo(
      //                       fontSize: 20,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           ),
      //           ExpandChild(
      //               child: Column(
      //                 children: [
      //                   Text(
      //                     name,
      //                     textAlign: TextAlign.center,
      //                     style: GoogleFonts.koHo(
      //                       fontSize: 20,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                   Text(
      //                     phone,
      //                     textAlign: TextAlign.center,
      //                     style: GoogleFonts.koHo(
      //                       fontSize: 20,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                   Text(
      //                     address,
      //                     textAlign: TextAlign.center,
      //                     style: GoogleFonts.koHo(
      //                       fontSize: 20,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                   Text(
      //                     pincode,
      //                     textAlign: TextAlign.center,
      //                     style: GoogleFonts.koHo(
      //                       fontSize: 20,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                   Text(
      //                     date.toDate().day.toString() +
      //                         "/" +
      //                         date.toDate().month.toString() +
      //                         "/" +
      //                         date.toDate().year.toString() +
      //                         '    ' +
      //                         date.toDate().toLocal().hour.toString() +
      //                         ':' +
      //                         date.toDate().minute.toString(),
      //                     textAlign: TextAlign.center,
      //                     style: GoogleFonts.koHo(
      //                       fontSize: 20,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                   Row(
      //                     children: [
      //                       ElevatedButton(
      //                           onPressed: () {
      //                             void shipped() {
      //                               FirebaseFirestore.instance
      //                                   .collection('Orders')
      //                                   .doc(id)
      //                                   .update({"status": "Order Shipped"});
      //                             }
      //
      //                             shipped();
      //                           },
      //                           style: ElevatedButton.styleFrom(
      //                               primary: Colors.black54),
      //                           child: Text("Order Shipped")),
      //                       ElevatedButton(
      //                           onPressed: () {
      //                             void cancelled() {
      //                               FirebaseFirestore.instance
      //                                   .collection('Orders')
      //                                   .doc(id)
      //                                   .update({
      //                                 "status": "Order Cancelled by Seller"
      //                               });
      //                             }
      //
      //                             cancelled();
      //                           },
      //                           style: ElevatedButton.styleFrom(
      //                             primary: Colors.black54,
      //                           ),
      //                           child: Text("Cancel Order")),
      //                     ],
      //                     crossAxisAlignment: CrossAxisAlignment.center,
      //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                   )
      //                 ],
      //               ))
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
    // return Card(
    //   margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 3.4, right: 3.4),
    //   child: Padding(
    //     padding: const EdgeInsets.all(5.0),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         color: Color(0xff282C31),
    //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
    //       ),
    //       child: Column(
    //         children: [
    //           CachedNetworkImage(
    //             imageUrl: url,
    //             imageBuilder: (context, imageProvider) => Container(
    //               height: size.height * 0.3,
    //               width: size.width,
    //               decoration: BoxDecoration(
    //                 image: DecorationImage(
    //                   image: imageProvider,
    //                   fit: BoxFit.cover,
    //                 ),
    //               ),
    //             ),
    //             placeholder: (context, url) => CircularProgressIndicator(),
    //             errorWidget: (context, url, error) => Icon(Icons.error),
    //           ),
    //           Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 'Item:',
    //                 style: GoogleFonts.koHo(
    //                   fontSize: 25,
    //                   fontWeight: FontWeight.bold,
    //                   color: Colors.cyan,
    //                 ),
    //               ),
    //               Padding(padding: EdgeInsets.all(5.0)),
    //               Text(
    //                 title,
    //                 style: GoogleFonts.koHo(
    //                   fontSize: 25,
    //                   color: Colors.cyan,
    //                 ),
    //               ),
    //             ],
    //           ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               Text(
    //                 "Price:",
    //                 style: GoogleFonts.koHo(
    //                   fontSize: 25,
    //                   fontWeight: FontWeight.bold,
    //                   color: Colors.cyan,
    //                 ),
    //               ),
    //               Padding(padding: EdgeInsets.all(5.0)),
    //               Icon(
    //                 FontAwesomeIcons.rupeeSign,
    //                 size: 21.0,
    //                 color: Colors.cyan,
    //               ),
    //               Text(
    //                 price,
    //                 style: GoogleFonts.koHo(
    //                   fontSize: 25,
    //                   color: Colors.cyan,
    //                 ),
    //               ),
    //             ],
    //           ),
    //           TextFormField(
    //             decoration: InputDecoration(hintText: "Updated Price"),
    //             controller: _price,
    //           ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               ElevatedButton(
    //                 style: ElevatedButton.styleFrom(primary: Colors.black12),
    //                 onPressed: () {
    //                   void update() async {
    //                     await FirebaseFirestore.instance
    //                         .collection("Items")
    //                         .doc(id)
    //                         .update({"price": _price.text.trim()}).then(
    //                             (value) {
    //                       ScaffoldMessenger.of(context).showSnackBar(
    //                           SnackBar(content: Text("Price Updated")));
    //                     });
    //                   }
    //
    //                   update();
    //                 },
    //                 child: Text('Update'),
    //               ),
    //               ElevatedButton(
    //                   style: ElevatedButton.styleFrom(primary: Colors.black12),
    //                   onPressed: () {
    //                     void markStockOut() async {
    //                       await FirebaseFirestore.instance
    //                           .collection("Items")
    //                           .doc(id)
    //                           .update({"available": "stockout"});
    //                     }
    //
    //                     void markStockin() async {
    //                       await FirebaseFirestore.instance
    //                           .collection("Items")
    //                           .doc(id)
    //                           .update({"available": "instock"});
    //                     }
    //
    //                     status == "instock" ? markStockOut() : markStockin();
    //                   },
    //                   child: Text(status == "instock"
    //                       ? "Mark out of stock"
    //                       : "Mark stock available")),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
