// app_button.dart
// Widget atom tombol utama aplikasi dengan beberapa varian tampilan
// (primary, secondary, error, ghost) serta dukungan state loading dan ikon.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, error, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final bool small;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    late final Color bgColor;
    late final Color textColor;
    late final Color borderColor;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        borderColor = Colors.transparent;
        break;
      case AppButtonVariant.secondary:
        bgColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        borderColor = Colors.transparent;
        break;
      case AppButtonVariant.error:
        bgColor = colorScheme.error;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = colorScheme.primary.withValues(alpha: 0.65);
        break;
    }

    final double buttonHeight = small ? 40 : 48;

    return SizedBox(
      width: width ?? double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.45),
          disabledForegroundColor: textColor.withValues(alpha: 0.55),
          elevation: variant == AppButtonVariant.primary ? 6 : 0,
          shadowColor: variant == AppButtonVariant.primary
              ? bgColor.withValues(alpha: 0.28)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          minimumSize: Size(double.infinity, buttonHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
          ),
          side: variant == AppButtonVariant.ghost
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
        child: isLoading
            ? SizedBox(
                height: small ? 18 : 22,
                width: small ? 18 : 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: small ? 18 : 20),
                    const SizedBox(width: SavaioTheme.spacingS),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        fontSize: small ? 14 : 15,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}