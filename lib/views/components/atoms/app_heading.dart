import 'package:flutter/material.dart';

enum AppHeadingSize { h1, h2, h3, subtitle, caption }

class AppHeading extends StatelessWidget {
  final String text;
  final AppHeadingSize size;
  final Color? color;
  final bool isBold;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const AppHeading(
    this.text, {
    super.key,
    this.size = AppHeadingSize.h2,
    this.color,
    this.isBold = true,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    TextStyle baseStyle;
    
    switch (size) {
      case AppHeadingSize.h1:
        baseStyle = textTheme.displaySmall ?? const TextStyle(fontSize: 28);
        break;
      case AppHeadingSize.h2:
        baseStyle = textTheme.headlineMedium ?? const TextStyle(fontSize: 20);
        break;
      case AppHeadingSize.h3:
        baseStyle = textTheme.titleLarge ?? const TextStyle(fontSize: 16);
        break;
      case AppHeadingSize.subtitle:
        baseStyle = textTheme.bodyLarge ?? const TextStyle(fontSize: 14);
        break;
      case AppHeadingSize.caption:
        baseStyle = textTheme.labelSmall ?? const TextStyle(fontSize: 10);
        break;
    }

    final finalStyle = baseStyle.copyWith(
      color: color ?? baseStyle.color,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
      overflow: overflow ?? TextOverflow.ellipsis,
    ).merge(style);

    return Semantics(
      header: size == AppHeadingSize.h1 || size == AppHeadingSize.h2,
      label: text,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: finalStyle.overflow,
        style: finalStyle,
      ),
    );
  }
}
