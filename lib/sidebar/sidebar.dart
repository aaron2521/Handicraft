import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:handicraft/Widgets/color.dart';
import 'package:handicraft/Widgets/fonts.dart';
import 'package:handicraft/sidebar/menu_item.dart';
import 'package:handicraft/sidebar_navigation/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/login.dart';
import '../splashScreen.dart';

class Sidebar extends StatefulWidget {
  // final String name;
  // final String email;
  // final String url;
  //
  // Sidebar(this.name, this.email, this.url);
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar>
    with SingleTickerProviderStateMixin<Sidebar> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  AnimationController _animationController;
  StreamController<bool> isSidebarOpenedStreamController;
  Stream<bool> isSidebarOpenedStream;
  StreamSink<bool> isSidebarOpenedSink;
  // bool isSidebarOpened = false;
  // IconData sidebarIcon = FontAwesomeIcons.angleDoubleRight;
  // SharedPreferences sharedPreferences;
  final _animationDuration = const Duration(microseconds: 500);
  // String username;
  // String useremail;
  // String userurl;

  @override
  void initState() {
    super.initState();
    // void pref()async{
    //   sharedPreferences ??= await SharedPreferences.getInstance();
    // String name=await sharedPreferences.getString("name");
    // String email = await sharedPreferences.get("email");
    // String url =await sharedPreferences.get("url");
    // setState(() {
    //   username=name;
    //   username=email;
    //   username=url;
    // });
    // }
    // pref();

    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;
  }

  @override
  void dispose() {
    _animationController.dispose();
    isSidebarOpenedStreamController.close();
    isSidebarOpenedSink.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;
    if (isAnimationCompleted) {
      isSidebarOpenedSink.add(false);
      _animationController.reverse();
    } else {
      isSidebarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return StreamBuilder<bool>(
        initialData: false,
        stream: isSidebarOpenedStream,
        builder: (context, isSideBarOpenedAsync) {
          return AnimatedPositioned(
            duration: _animationDuration,
            top: 0,
            bottom: 0,
            left: isSideBarOpenedAsync.data ? 0 : -width,
            right: isSideBarOpenedAsync.data ? 0 : width - 30,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          // stops: [0.5, 0.7],
                          colors: [pink, pink, mehron],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        // color: pink,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(
                                App.sharedPreferences.getString("name"),
                                style: b_20mehron(),
                              ),
                              subtitle: Text(
                                App.sharedPreferences.getString("email"),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              leading: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: Image.network(
                                      App.sharedPreferences.getString("url")),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            height: 10,
                            thickness: 1,
                            color: Colors.white.withOpacity(0.5),
                            indent: 32,
                            endIndent: 32,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.home,
                                    color: cream,
                                  ),
                                  title: Text(
                                    "Home",
                                    style: b_16cream(),
                                  ),
                                  onTap: () {
                                    onIconPressed();
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigationEvents
                                            .HomePageClickedEvent);
                                  },
                                ),
                                ListTile(
                                  // contentPadding: EdgeInsets.all(0)
                                  leading: Icon(
                                    Icons.shopping_bag,
                                    color: cream,
                                  ),
                                  title: Text(
                                    "My Orders",
                                    style: b_16cream(),
                                  ),
                                  onTap: () {
                                    onIconPressed();
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigationEvents
                                            .MyOrdersClickedEvent);
                                  },
                                ),
                                // ListTile(
                                //   leading: Icon(
                                //     Icons.shopping_cart,
                                //     color: cream,
                                //   ),
                                //   title: Text(
                                //     "My Cart",
                                //     style: b_16cream(),
                                //   ),
                                //   onTap: () {
                                //     onIconPressed();
                                //     BlocProvider.of<NavigationBloc>(context)
                                //         .add(NavigationEvents
                                //             .MyCartClickedEvent);
                                //   },
                                // ),
                                // ListTile(
                                //   leading: Icon(
                                //     Icons.account_balance,
                                //     color: cream,
                                //   ),
                                //   title: Text(
                                //     "My Accounts",
                                //     style: b_16cream(),
                                //   ),
                                //   onTap: () {
                                //     onIconPressed();
                                //     BlocProvider.of<NavigationBloc>(context)
                                //         .add(NavigationEvents
                                //             .MyAccountsClickedEvent);
                                //   },
                                // ),
                                Divider(
                                  height: 20,
                                  thickness: 1,
                                  color: Colors.white.withOpacity(0.5),
                                  indent: 15,
                                  endIndent: 15,
                                ),
                                // ListTile(
                                //   leading: Icon(
                                //     Icons.settings,
                                //     color: cream,
                                //   ),
                                //   title: Text(
                                //     "Settings",
                                //     style: b_16cream(),
                                //   ),
                                //   onTap: () {},
                                // ),
                                ListTile(
                                  leading: Icon(
                                    Icons.exit_to_app,
                                    color: cream,
                                  ),
                                  title: Text(
                                    "Log out",
                                    style: b_16cream(),
                                  ),
                                  onTap: () async {
                                    await _googleSignIn
                                        .signOut()
                                        .whenComplete(() {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()),
                                          (route) => false);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      onIconPressed();
                    });
                  },
                  child: Align(
                    alignment: Alignment(0, -0.9),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30),
                            topRight: Radius.circular(30)),
                        color: pink,
                      ),
                      width: 30,
                      height: 55,
                      alignment: Alignment.centerLeft,
                      child: AnimatedIcon(
                        progress: _animationController.view,
                        icon: AnimatedIcons.menu_close,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   width: 20,
                // )
              ],
            ),
          );
        });
  }
}
