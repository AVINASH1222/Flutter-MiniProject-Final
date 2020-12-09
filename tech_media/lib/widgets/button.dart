import 'package:flutter/material.dart';
import 'package:nice_button/NiceButton.dart';

var firstColor = Color(0xff5b86e5), secondColor = Color(0xff36d1dc);

Widget button(String info) {
  return NiceButton(
    radius: 40,
    width: 150.0,
    text: info,
    gradientColors: [secondColor, firstColor],
    background: null,
    fontSize: 22,
    textColor: Colors.black,
    onPressed: () {},
  );
}
