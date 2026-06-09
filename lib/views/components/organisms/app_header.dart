import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_avatar.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/core/utils/service_locator.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool centerTitle;
  final bool showBackButton;
  final bool showNotification;
  final String? avatarUrl;
  final Widget? leading;
  final double? leadingWidth;
  final VoidCallback? onNotificationTap;
  final bool transparent;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.centerTitle = true,
    this.showBackButton = false,
    this.showNotification = true,
    this.avatarUrl,
    this.leading,
    this.leadingWidth,
    this.onNotificationTap,
    this.transparent = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;
    
    if (leadingWidget == null) {
      if (showBackButton) {
        leadingWidget = Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SavaioTheme.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        );
      } else if (avatarUrl != null) {
        leadingWidget = Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: SavaioTheme.spacingXl),
            child: AppAvatar(
              imageUrl: avatarUrl!,
              size: 36,
              showBorder: true,
            ),
          ),
        );
      }
    }

    return AppBar(
      backgroundColor: transparent ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight + SavaioTheme.spacingM,
      centerTitle: centerTitle,
      titleSpacing: 0,
      leading: leadingWidget,
      leadingWidth: leadingWidth ?? (showBackButton ? null : ((avatarUrl != null || leading != null) ? 64 + SavaioTheme.spacingXl : null)),
      title: titleWidget ?? Padding(
        padding: const EdgeInsets.symmetric(horizontal: SavaioTheme.spacingXl),
        child: ShaderMask(
          shaderCallback: (bounds) => SavaioTheme.primaryGradient.createShader(bounds),
          child: AppHeading(
            title ?? 'Savaio',
            size: AppHeadingSize.h3,
            color: Colors.white,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        if (showNotification) ...[
          ListenableBuilder(
            listenable: sl.notificationController,
            builder: (context, _) {
              final unreadCount = sl.notificationController.unreadNotificationsCount;
              return Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.notifications_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                        onPressed: onNotificationTap,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: SavaioTheme.spacingXl),
        ] else if (showBackButton || avatarUrl != null || leading != null)
          const SizedBox(width: 48), // Balance the leading widget for centering
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + SavaioTheme.spacingM);
}
