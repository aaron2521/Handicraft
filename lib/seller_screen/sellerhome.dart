import 'package:handicraft/Widgets/color.dart';
import 'package:handicraft/seller_screen/addselleritems.dart';
import 'package:handicraft/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animated_background/animated_background.dart';
import 'package:handicraft/seller_screen/sellerhomewidgets.dart';

class SellerHome extends StatefulWidget {
  @override
  _SellerHomeState createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> with TickerProviderStateMixin {
  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    final _pageController = PageController();
    return Scaffold(
      backgroundColor: cream,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: pink,
        color: pink,
        index: 0,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.edit,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.add,
            size: 20,
            color: Colors.white,
          ),
          IconButton(
              icon: Icon(
                Icons.power_settings_new,
                size: 20,
                color: Colors.white,
              ),
              onPressed: () {
                void logout() async {
                  await _googleSignIn.signOut().whenComplete(() {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false);
                  });
                }

                logout();
              })
        ],
        onTap: (index) {
          setState(() {
            _pageController.jumpToPage(index);
          });
        },
        letIndexChange: (index) => true,
      ),
      body: Center(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [OrdersArrived(), ItemModify(), AddItemsBySeller()],
          onPageChanged: (int index) {
            setState(() {
              _pageController.jumpToPage(index);
            });
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: pink,
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     Navigator.push(context,
      //         MaterialPageRoute(builder: (context) => AddItemsBySeller()));
      //   },
      // ),
    );
  }
}
