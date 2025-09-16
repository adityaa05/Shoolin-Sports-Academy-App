import 'package:flutter/cupertino.dart';

class Dimensions {
  double mediaQueryHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double mediaQueryWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
} 