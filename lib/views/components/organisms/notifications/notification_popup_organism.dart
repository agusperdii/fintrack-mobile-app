// notification_popup_organism.dart
// Dialog popup notifikasi bergaya modal dengan ikon besar, judul, pesan,
// dan tombol aksi/dismiss sesuai severity notifikasi.

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
    final style = _getNotificationStyle(context, notification.severity);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 390),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: BoxDecoration(
              color: SavaioTheme.surfaceOf(context).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: style.color.withValues(alpha: 0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 18),

                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.color.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: style.color.withValues(alpha: 0.28),
                        blurRadius: 26,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Icon(
                    style.icon,
                    size: 52,
                    color: style.color,
                  ),
                ),

                const SizedBox(height: 32),

                AppHeading(
                  notification.title,
                  size: AppHeadingSize.h2,
                  color: SavaioTheme.onSurfaceOf(context),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  notification.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: SavaioTheme.onSurfaceOf(context).withValues(alpha: 0.68),
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),

                const SizedBox(height: 32),

                if (onAction != null)
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: actionLabel ?? 'Lihat Sekarang',
                      onTap: onAction!,
                    ),
                  ),

                if (onAction != null) const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: onAction != null ? 'Nanti Saja' : 'Mengerti',
                    onTap: onDismiss,
                    variant: AppButtonVariant.ghost,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 18,
            right: 18,
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SavaioTheme.onSurfaceOf(context).withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: SavaioTheme.onSurfaceOf(context).withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static _NotificationPopupStyle _getNotificationStyle(
    BuildContext context,
    NotificationSeverity severity,
  ) {
    switch (severity) {
      case NotificationSeverity.warning:
        return _NotificationPopupStyle(
          color: SavaioTheme.warningOf(context),
          icon: Icons.warning_rounded,
        );
      case NotificationSeverity.danger:
        return _NotificationPopupStyle(
          color: SavaioTheme.errorOf(context),
          icon: Icons.priority_high_rounded,
        );
      case NotificationSeverity.info:
        return _NotificationPopupStyle(
          color: SavaioTheme.successOf(context),
          icon: Icons.check_circle_rounded,
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
                Navigator.pop(context);
                onAction();
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