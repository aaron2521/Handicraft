import 'package:flutter/material.dart';
import 'package:handicraft/Widgets/color.dart';

Container circularProgress({Color color}) {
  return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      // padding: EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color == null ? pink : color),
      ));
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(pink),
    ),
  );
}
