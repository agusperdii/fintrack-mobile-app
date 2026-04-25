import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

enum AppHeadingSize { h1, h2, h3, subtitle, caption }

class AppHeading extends StatelessWidget {
  final String text;
  final AppHeadingSize size;
  final Color? color;
  final bool isBold;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppHeading(this.text, {
    super.key,
    this.size = AppHeadingSize.h2,
    this.color,
    this.isBold = true,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;
    FontWeight fontWeight = isBold ? FontWeight.w800 : FontWeight.w500;
    double? letterSpacing;

    switch (size) {
      case AppHeadingSize.h1: fontSize = 32; break;
      case AppHeadingSize.h2: fontSize = 24; break;
      case AppHeadingSize.h3: fontSize = 20; break;
      case AppHeadingSize.subtitle: 
        fontSize = 14; 
        letterSpacing = 0.5;
        fontWeight = isBold ? FontWeight.w700 : FontWeight.w500;
        break;
      case AppHeadingSize.caption: 
        fontSize = 12; 
        fontWeight = isBold ? FontWeight.w700 : FontWeight.w400;
        break;
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? KineticVaultTheme.onSurface,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
