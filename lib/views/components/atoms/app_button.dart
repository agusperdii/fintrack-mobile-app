import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, error, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final bool small;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final String? semanticLabel;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.small = false,
    this.padding,
    this.labelStyle,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color bgColor;
    Color textColor;
    double elevation = 0;
    BorderSide borderSide = BorderSide.none;
    
    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        elevation = 4;
        break;
      case AppButtonVariant.secondary:
        bgColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        break;
      case AppButtonVariant.error:
        bgColor = colorScheme.error;
        textColor = colorScheme.onError;
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderSide = BorderSide(color: colorScheme.primary, width: 1.5);
        break;
    }

    final effectivePadding = padding ?? EdgeInsets.symmetric(
      vertical: small ? 8 : 14,
      horizontal: 16,
    );

    return Semantics(
      button: true,
      enabled: onTap != null && !isLoading,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: width ?? double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
            disabledForegroundColor: textColor.withValues(alpha: 0.5),
            elevation: elevation,
            shadowColor: variant == AppButtonVariant.primary ? bgColor.withValues(alpha: 0.3) : Colors.transparent,
            padding: effectivePadding,
            shape: const StadiumBorder(),
            side: borderSide,
          ),
          child: isLoading
              ? SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(
                    strokeWidth: 2, 
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: small ? 16 : 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label.toUpperCase(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: textColor,
                        ).merge(labelStyle),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
