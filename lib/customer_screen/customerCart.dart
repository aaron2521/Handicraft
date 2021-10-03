import 'dart:async';
import 'package:handicraft/Widgets/color.dart';
import 'package:handicraft/Widgets/fonts.dart';
import 'package:handicraft/Widgets/progress.dart';
import 'package:handicraft/customer_screen/confirmOrderViaCart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handicraft/splashScreen.dart';

class CustomerCart extends StatefulWidget {
  final List<String> cartCount;
  CustomerCart({this.cartCount});

  @override
  _CustomerCartState createState() => _CustomerCartState();
}

class _CustomerCartState extends State<CustomerCart> {
  bool pageloadin = true;
  List<CartCard> cartItems = [];
  Future<void> getCartItems() async {
    cartItems.clear();
    totalPrice = 0;
    for (int i = 0; i < widget.cartCount.length; i++) {
      var data = await FirebaseFirestore.instance
          .collection("Items")
          .doc(widget.cartCount[i])
          .get();
      CartCard cart = CartCard(
          title: data.data()['title'],
          price: data.data()['price'],
          itemID: data.id,
          available: data.data()['available'],
          imageURL: data.data()['imageURL']);
      cartItems.add(cart);
      totalPrice = totalPrice + double.parse(data.data()['price']);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCartItems().whenComplete(() {
      setState(() {
        pageloadin = false;
      });
    });
  }

  double totalPrice = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: Text("My Cart"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: mehron,
          onRefresh: getCartItems,
          child: pageloadin
              ? Center(child: circularProgress())
              : Center(
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: cartItems.length == 0
                              ? Container()
                              : Text(
                                  "Total Cart Value: ₹" + totalPrice.toString(),
                                  style: b_14pink(),
                                )),
                      Expanded(
                        child: Container(
                          child: cartItems.length == 0
                              ? Center(
                                  child: Text(
                                  "Cart Empty",
                                  style: b_14pink(),
                                ))
                              : ListView.builder(
                                  itemCount: cartItems.length,
                                  itemBuilder: (_, index) {
                                    return CartItems(
                                        context,
                                        cartItems[index].title,
                                        cartItems[index].price,
                                        cartItems[index].itemID,
                                        cartItems[index].available,
                                        cartItems[index].imageURL);
                                  }),
                        ),
                      ),
                      cartItems.length == 0
                          ? Container()
                          : ElevatedButton(
                              onPressed: () {
                                void checkOut() async {
                                  await getCartItems();
                                  setState(() {});
                                  int flag = 1;
                                  for (int i = 0; i < cartItems.length; i++) {
                                    var data = await FirebaseFirestore.instance
                                        .collection("Items")
                                        .doc(widget.cartCount[i])
                                        .get();
                                    if (data.data()['available'] ==
                                        "stockout") {
                                      flag = 0;
                                    }
                                  }
                                  if (flag == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Remove out of stock item")));
                                    print(flag);
                                  } else {
                                    print(flag);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ConfirmViaCart(
                                                  cartCount: widget.cartCount,
                                                )));
                                  }
                                }

                                checkOut();
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: pink,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 20)),
                              child: Text("Proceed to Buy")),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget CartItems(BuildContext context, String title, String price,
      String itemID, String available, String imageURL) {
    String avaiblity = available;
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      color: cream,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              // color: white,
              image: DecorationImage(image: NetworkImage(imageURL))),
        ),
        title: Text(title),
        subtitle: avaiblity != "instock"
            ? Text(
                "Not available",
                style: b_14red(),
              )
            : Text(
                "₹ " + price.toString(),
                style: b_14pink(),
              ),
        trailing: IconButton(
          onPressed: () {
            void remove() async {
              widget.cartCount.remove(itemID);
              // setState(() {
              cartItems.removeWhere((element) => element.itemID == itemID);
              setState(() {
                totalPrice =
                    double.parse(totalPrice.toString()) - double.parse(price);
              });
              // });
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(App.sharedPreferences.getString("email"))
                  .update({"cart": widget.cartCount}).then((value) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Removed from cart")));
              });
            }

            remove();
          },
          icon: Icon(Icons.delete),
          color: Colors.red,
        ),
      ),
    );
    // return Card(
    //   child: Container(
    //     color: mehron,
    //     child: Column(
    //       children: [
    //         Text(title),
    //         Text(price.toString()),
    //         avaiblity == "instock"
    //             ? SizedBox(
    //                 height: 0,
    //               )
    //             : Text("Not available"),
    //         ElevatedButton(
    // onPressed: () {
    //   void remove() async {
    //     widget.cartCount.remove(itemID);
    //     // setState(() {
    //     cartItems
    //         .removeWhere((element) => element.itemID == itemID);
    //     setState(() {
    //       totalPrice = double.parse(totalPrice.toString()) -
    //           double.parse(price);
    //     });
    //     // });
    //     await FirebaseFirestore.instance
    //         .collection("users")
    //         .doc(App.sharedPreferences.getString("email"))
    //         .update({"cart": widget.cartCount}).then((value) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text("Removed from cart")));
    //     });
    //   }

    //   remove();
    // },
    //             child: Text("Remove"))
    //       ],
    //     ),
    //   ),
    // );
  }
}

class CartCard {
  String title, price, itemID, available, imageURL;
  CartCard(
      {this.title, this.price, this.itemID, this.available, this.imageURL});
}
