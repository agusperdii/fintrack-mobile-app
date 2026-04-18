import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

enum AppHeadingSize { h1, h2, h3, subtitle, caption }

class AppHeading extends StatelessWidget {
  final String text;
  final AppHeadingSize size;
  final Color? color;
  final bool isBold;

  const AppHeading(this.text, {
    super.key,
    this.size = AppHeadingSize.h2,
    this.color,
    this.isBold = true,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;
    FontWeight fontWeight = isBold ? FontWeight.w800 : FontWeight.w500;
    double? letterSpacing;

    switch (size) {
      case AppHeadingSize.h1: fontSize = 32; break;
      case AppHeadingSize.h2: fontSize = 24; break;
      case AppHeadingSize.h3: fontSize = 18; break;
      case AppHeadingSize.subtitle: 
        fontSize = 12; 
        letterSpacing = 1.5;
        fontWeight = FontWeight.bold;
        break;
      case AppHeadingSize.caption: fontSize = 10; break;
    }

    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? KineticVaultTheme.onSurface,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
