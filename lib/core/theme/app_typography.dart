import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme(Color color) {
    return GoogleFonts.urbanistTextTheme().apply(
      bodyColor: color,
      displayColor: color,
    );
  }
}
