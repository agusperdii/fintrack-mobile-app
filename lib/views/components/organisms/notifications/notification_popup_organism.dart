import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class NotificationPopupOrganism extends StatelessWidget {
  final NotificationData notification;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const NotificationPopupOrganism({
    super.key,
    required this.notification,
    required this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getNotificationStyle(notification.severity);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        decoration: BoxDecoration(
          color: SavaioTheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: style.color.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: SavaioTheme.onSurface.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: SavaioTheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: style.color.withValues(alpha: 0.22),
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: style.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: style.color.withValues(alpha: 0.32),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    style.icon,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 26),

            AppHeading(
              notification.title,
              size: AppHeadingSize.h2,
              color: SavaioTheme.onSurface,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              notification.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: SavaioTheme.onSurface.withValues(alpha: 0.68),
                height: 1.5,
                letterSpacing: -0.1,
              ),
            ),

            const SizedBox(height: 30),

            if (onAction != null)
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: actionLabel ?? 'LIHAT SEKARANG',
                  onTap: onAction!,
                ),
              ),

            if (onAction != null) const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: onAction != null ? 'NANTI SAJA' : 'MENGERTI',
                onTap: onDismiss,
                variant: AppButtonVariant.ghost,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _NotificationPopupStyle _getNotificationStyle(
    NotificationSeverity severity,
  ) {
    switch (severity) {
      case NotificationSeverity.warning:
        return const _NotificationPopupStyle(
          color: Color(0xFFFFC800),
          icon: Icons.bolt_rounded,
        );
      case NotificationSeverity.danger:
        return const _NotificationPopupStyle(
          color: Color(0xFFFF4B4B),
          icon: Icons.priority_high_rounded,
        );
      case NotificationSeverity.info:
        return const _NotificationPopupStyle(
          color: Color(0xFF58CC02),
          icon: Icons.check_rounded,
        );
    }
  }

  static void show(
    BuildContext context,
    NotificationData notification, {
    VoidCallback? onRead,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => NotificationPopupOrganism(
        notification: notification,
        onDismiss: () {
          onRead?.call();
          Navigator.pop(context);
        },
        onAction: onAction != null
            ? () {
                onAction();
                Navigator.pop(context);
              }
            : null,
        actionLabel: actionLabel,
      ),
    );
  }
}

class _NotificationPopupStyle {
  final Color color;
  final IconData icon;

  const _NotificationPopupStyle({
    required this.color,
    required this.icon,
  });
}