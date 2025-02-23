import "package:flutter/material.dart";

const String backGroundColor = "DF8B93";
const String userPromptColor = "20183D";
const String appBarColor = "9C6692";
const String aiText = "120C11";

class PrimaryColor extends Color {
  PrimaryColor(final String hexColor) : super(_change(hexColor));
  static int _change(String hexColor) {
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }
}
