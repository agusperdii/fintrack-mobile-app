import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, error, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    
    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = KineticVaultTheme.primary;
        textColor = KineticVaultTheme.onPrimaryFixed;
        break;
      case AppButtonVariant.secondary:
        bgColor = KineticVaultTheme.surfaceContainerHighest;
        textColor = KineticVaultTheme.onSurface;
        break;
      case AppButtonVariant.error:
        bgColor = KineticVaultTheme.error;
        textColor = Colors.white;
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = KineticVaultTheme.primary;
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
          padding: const EdgeInsets.symmetric(vertical: KineticVaultTheme.spacingL),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KineticVaultTheme.radiusFull)),
          side: variant == AppButtonVariant.ghost 
            ? const BorderSide(color: KineticVaultTheme.primary, width: 1.5)
            : BorderSide.none,
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: KineticVaultTheme.spacingS),
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
