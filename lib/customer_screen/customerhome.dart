import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handicraft/Widgets/color.dart';
import 'package:handicraft/Widgets/fonts.dart';
import 'package:handicraft/Widgets/progress.dart';
import 'package:handicraft/customer_screen/customerCart.dart';
import 'package:handicraft/data/data.dart';
import 'package:handicraft/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:handicraft/customer_screen/myorderspage.dart';
import 'package:handicraft/sidebar_navigation/navigation_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handicraft/splashScreen.dart';

import 'orderpages.dart';

class CustomerHome extends StatefulWidget with NavigationStates {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  List<Data> dataList = [];
  GoogleSignIn _googleSignIn = GoogleSignIn();
  TextEditingController searchC = TextEditingController();

  List<String> cartList = [];
  List<String> searchlist = [];
  bool isSearchDone = false;
  QuerySnapshot snapshotData;

  Future searchData(String searchString) async {
    return FirebaseFirestore.instance
        .collection("Items")
        .where("title", isGreaterThanOrEqualTo: searchString)
        .get();
  }

  @override
  void initState() {
    super.initState();
    // fetchData();
    // getCart();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // print(snapshotData.docs[0].data()["title"]);
    Widget searchedContainer() {
      return ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: snapshotData.docs.length,
          itemBuilder: (BuildContext context, int index) {
            return searchProductss(
                snapshotData.docs[index]['imageURL'],
                snapshotData.docs[index]['title'],
                snapshotData.docs[index]['price'], () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => (OrdersPages(
                          snapshotData.docs[index]['imageURL'],
                          snapshotData.docs[index]['title'],
                          snapshotData.docs[index]['price'],
                          snapshotData.docs[index]['desc'],
                          snapshotData.docs[index].id,
                          snapshotData.docs[index]['seller'],
                          cartList))));
            });
          });
    }

    return Scaffold(
      backgroundColor: bgcolor,
      floatingActionButton: isSearchDone
          ? FloatingActionButton(
              backgroundColor: mehron,
              onPressed: () {
                setState(() {
                  FocusScope.of(context).requestFocus(FocusNode());
                  searchC.clear();
                  isSearchDone = false;
                });
              },
              child: Icon(
                Icons.search_off,
                color: cream,
              ),
            )
          : Container(),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              // height: size.height * 0.1,
              decoration: BoxDecoration(
                color: pink,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 5),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Welcome !..",
                      style: GoogleFonts.koHo(
                          color: mehron,
                          fontWeight: FontWeight.bold,
                          fontSize: 40)),
                  SizedBox(
                    width: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CustomerCart(
                                    cartCount: cartList,
                                  )));
                    },
                    child: Container(
                      margin: EdgeInsets.all(5),
                      height: 30,
                      width: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .where("email",
                                      isEqualTo: App.sharedPreferences
                                          .getString("email"))
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                                void getCart() async {
                                  if (streamSnapshot.hasData) {
                                    cartList = List.from(
                                        streamSnapshot.data.docs[0]['cart']);
                                  }
                                }

                                getCart();
                                return !streamSnapshot.hasData
                                    ? CircularProgressIndicator(color: white)
                                    : Text(
                                        cartList.length.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      );
                              },
                            ),
                            // cartLength==null?LinearProgressIndicator():Text(cartLength,style: TextStyle(color: Colors.white,fontSize: 20),),
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              // height: 24,
              child: Column(
                children: [
                  TextFormField(
                    style: TextStyle(color: pink),
                    cursorColor: pink,
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                            onTap: () {
                              print("search btn tap");
                              if (searchC.text.trim().isNotEmpty) {
                                searchData(searchC.text).then((value) {
                                  snapshotData = value;
                                  setState(() {
                                    isSearchDone = true;
                                    // print(snapshotData.docs[0]['title']);
                                  });
                                });
                              } else {
                                setState(() {
                                  isSearchDone = false;
                                });
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: mehron),
                              child: Icon(
                                Icons.search,
                                size: 30,
                                color: cream,
                              ),
                            )),
                        filled: true,
                        fillColor: cream,
                        hintStyle: TextStyle(color: pink),
                        focusColor: pink,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        hintText: "Search...",
                        prefixIcon: Icon(
                          FontAwesomeIcons.search,
                          color: pink,
                        )),
                    controller: searchC,
                  ),
                  // Text("Featured Products",
                  //     style: GoogleFonts.koHo(
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 20)),
                ],
              ),
            ),
            Expanded(
              child: isSearchDone
                  ? snapshotData.docs.length == 0
                      ? Center(
                          child: Text(
                            "No item found",
                            style: TextStyle(
                              color: mehron,
                              fontSize: 20,
                            ),
                          ),
                        )
                      : searchedContainer()
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("Items")
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        return !streamSnapshot.hasData
                            ? Center(child: circularProgress())
                            : ListView.builder(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: streamSnapshot.data.docs.length,
                                itemBuilder: (_, index) {
                                  return FeaturedProductss(
                                      streamSnapshot.data.docs[index]
                                          ['imageURL'],
                                      streamSnapshot.data.docs[index]['title'],
                                      streamSnapshot.data.docs[index]['price'],
                                      () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => (OrdersPages(
                                                streamSnapshot.data.docs[index]
                                                    ['imageURL'],
                                                streamSnapshot.data.docs[index]
                                                    ['title'],
                                                streamSnapshot.data.docs[index]
                                                    ['price'],
                                                streamSnapshot.data.docs[index]
                                                    ['desc'],
                                                streamSnapshot
                                                    .data.docs[index].id,
                                                streamSnapshot.data.docs[index]
                                                    ['seller'],
                                                cartList))));
                                  });
                                },
                              );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget searchProductss(
      String imageUrl, String title, String price, Function function) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: function,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          color: cream,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 5),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration:
                  BoxDecoration(border: Border.all(width: 3, color: mehron)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                        color: pink, value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size.width * 0.35,
                  // color: Colors.green,
                  child: Text(
                    title,
                    style: GoogleFonts.koHo(
                        color: mehron,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                // Spacer(),
                SizedBox(height: 20),
                Text("₹ " + price,
                    style: GoogleFonts.koHo(
                        color: mehron,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
            Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: pink, borderRadius: BorderRadius.circular(5)),

              // style: ElevatedButton.styleFrom(primary: pink),
              // onPressed: () {},
              child: Text(
                "Veiw",
                style: GoogleFonts.koHo(
                    color: mehron, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget FeaturedProductss(
      String imageUrl, String title, String price, Function function) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: function,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        // width: size.width * 0.7,
        // height: size.height*0.4,
        child: Column(
          children: [
            Container(
              decoration:
                  BoxDecoration(border: Border.all(width: 3, color: pink)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                        color: pink, value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: pink,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 5),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.6,
                    // color: cream,
                    child: Text(
                      title,
                      style: GoogleFonts.koHo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  Spacer(),
                  Text("₹ " + price,
                      style: GoogleFonts.koHo(
                          color: cream,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class FeaturedProducts extends StatelessWidget {
//   const FeaturedProducts({
//     Key key, this.image, this.title, this.price, this.onPress,
//   }) : super(key: key);
//
//   final String image,title, price;
//   final Function onPress;
//
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: onPress,
//       child: Container(
//         margin: EdgeInsets.all(20),
//         width: size.width*0.7,
//         // height: size.height*0.4,
//         child: Column(
//           children: [
//             Image.network(image),
//           Container(
//             padding: EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(10),
//                 bottomRight: Radius.circular(10),
//               ),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey,
//                   offset: Offset(0.0, 5),
//                   blurRadius: 6.0,
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Text("$title",
//                   style: TextStyle(
//                     color: Colors.black.withOpacity(0.5),fontSize: 18, fontWeight: FontWeight.bold
//                   ),
//                 ),
//                 Spacer(),
//                 Text("$price",
//                   style: TextStyle(
//                       color: Color(0xff44a7c4),fontSize: 18, fontWeight: FontWeight.bold
//                   ),
//                 ),
//               ],
//             ),
//           )
//           ],
//         ),
//       ),
//     );
//   }
// }
