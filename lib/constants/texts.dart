import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dimensions.dart';

class CustomTextStyles {
  TextStyle titleStyle(BuildContext context) {
    return GoogleFonts.prompt(
      fontSize: Dimensions().mediaQueryWidth(context) * 0.115,
      fontWeight: FontWeight.bold,
      height: 1.1,
      letterSpacing: 1.1,
    );
  }

} 