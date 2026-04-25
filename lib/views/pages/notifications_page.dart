import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../components/atoms/app_heading.dart';
import '../components/atoms/app_icon_container.dart';
import '../components/atoms/app_button.dart';
import '../components/atoms/app_progress_bar.dart';
import '../components/molecules/app_notification_card.dart';
import '../components/molecules/app_editorial_header.dart';
import '../components/organisms/app_header.dart';
import '../../models/data_sources/mock_notifications.dart';
import '../../models/entities/notification_data.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: const AppHeader(
        title: 'Notifikasi', 
        showBackButton: true,
        showNotification: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const AppEditorialHeader(
                      category: 'ACTIVITY HUB',
                      title: 'Notifikasi',
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const AppHeading(
                        'Tandai semua dibaca',
                        size: AppHeadingSize.subtitle,
                        color: KineticVaultTheme.primary,
                        isBold: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Notification Feed
                ...MockNotifications.notifications.map((data) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNotificationFromData(data),
                )),

                const SizedBox(height: 32),

                // Suggestion Section
                const AppHeading(
                  'Terlewatkan?',
                  size: AppHeadingSize.h3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: MockNotifications.suggestions.map((suggestion) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: suggestion == MockNotifications.suggestions.last ? 0 : 16.0,
                        ),
                        child: _buildSuggestionCardFromData(suggestion),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationFromData(NotificationData data) {
    Widget? contentWidget;
    
    if (data.contentSegments != null) {
      contentWidget = RichText(
        text: TextSpan(
          style: const TextStyle(
            color: KineticVaultTheme.onSurface,
            fontSize: 12,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
          children: data.contentSegments!.map((segment) {
            TextStyle? style;
            if (segment.isError) {
              style = const TextStyle(color: KineticVaultTheme.error);
            } else if (segment.isHighlighted) {
              style = const TextStyle(color: KineticVaultTheme.primary, fontWeight: FontWeight.bold);
            } else if (segment.isSuccess) {
              style = const TextStyle(color: KineticVaultTheme.tertiary, fontWeight: FontWeight.bold);
            }
            return TextSpan(text: segment.text, style: style);
          }).toList(),
        ),
      );
    } else if (data.plainContent != null) {
      contentWidget = AppHeading(
        data.plainContent!,
        size: AppHeadingSize.subtitle,
        isBold: false,
      );
    }

    Widget? footerWidget;
    if (data.type == NotificationType.streak && data.streakProgress != null) {
      footerWidget = Row(
        children: [
          Expanded(
            child: AppProgressBar(
              value: data.streakProgress!,
              color: KineticVaultTheme.secondary,
              height: 4,
            ),
          ),
          const SizedBox(width: 8),
          AppHeading(
            data.streakText ?? '',
            size: AppHeadingSize.caption,
            color: KineticVaultTheme.secondary,
            isBold: true,
          ),
        ],
      );
    } else if (data.type == NotificationType.success && data.recapTitle != null) {
      footerWidget = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const AppIconContainer(
                  icon: Icons.trending_down,
                  color: KineticVaultTheme.tertiary,
                  size: 28,
                  shape: AppIconShape.rounded,
                ),
                const SizedBox(width: 12),
                AppHeading(
                  data.recapTitle!,
                  size: AppHeadingSize.caption,
                  isBold: true,
                ),
              ],
            ),
            AppHeading(
              data.recapAmount ?? '',
              size: AppHeadingSize.subtitle,
              color: KineticVaultTheme.tertiary,
            ),
          ],
        ),
      );
    }

    List<Widget>? actionsList;
    if (data.hasActions) {
      actionsList = [
        AppButton(
          label: 'ABAIKAN',
          variant: AppButtonVariant.secondary,
          width: 100,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        AppButton(
          label: 'LIHAT BUDGET',
          variant: AppButtonVariant.error,
          width: 120,
          onTap: () {},
        ),
      ];
    }

    AppNotificationVariant variant = AppNotificationVariant.info;
    switch (data.type) {
      case NotificationType.warning:
        variant = AppNotificationVariant.warning;
        break;
      case NotificationType.info:
        variant = AppNotificationVariant.info;
        break;
      case NotificationType.streak:
        variant = AppNotificationVariant.streak;
        break;
      case NotificationType.success:
        variant = AppNotificationVariant.success;
        break;
    }

    return AppNotificationCard(
      category: data.category,
      time: data.time,
      variant: variant,
      content: contentWidget ?? const SizedBox(),
      actions: actionsList,
      footer: footerWidget,
    );
  }

  Widget _buildSuggestionCardFromData(SuggestionData data) {
    IconData iconData = Icons.help;
    Color color = KineticVaultTheme.primary;
    
    if (data.iconType == 'wallet') {
      iconData = Icons.account_balance_wallet;
      color = KineticVaultTheme.primary;
    } else if (data.iconType == 'vault') {
      iconData = Icons.savings;
      color = KineticVaultTheme.secondary;
    }
    
    return _buildSuggestionCard(
      icon: iconData,
      label: data.label,
      title: data.title,
      color: color,
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required String label,
    required String title,
    required Color color,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeading(
                  label.toUpperCase(),
                  size: AppHeadingSize.caption,
                  color: KineticVaultTheme.onSurface.withValues(alpha: 0.5),
                  isBold: true,
                ),
                const SizedBox(height: 4),
                AppHeading(
                  title,
                  size: AppHeadingSize.subtitle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
