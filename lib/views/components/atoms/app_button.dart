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
    Color bgColor;
    Color textColor;
    
    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = SavaioTheme.primary;
        textColor = SavaioTheme.onPrimaryFixed;
        break;
      case AppButtonVariant.secondary:
        bgColor = SavaioTheme.surfaceContainerHighest;
        textColor = SavaioTheme.onSurface;
        break;
      case AppButtonVariant.error:
        bgColor = SavaioTheme.error;
        textColor = Colors.white;
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = SavaioTheme.primary;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: variant == AppButtonVariant.primary ? 8 : 0,
          shadowColor: variant == AppButtonVariant.primary ? bgColor.withValues(alpha: 0.3) : Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: small ? 8 : 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SavaioTheme.radiusFull)),
          side: variant == AppButtonVariant.ghost 
            ? const BorderSide(color: SavaioTheme.primary, width: 1.5)
            : BorderSide.none,
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: SavaioTheme.spacingS),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
