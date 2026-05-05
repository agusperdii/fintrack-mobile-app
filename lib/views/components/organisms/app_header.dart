import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_avatar.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showNotification;
  final int unreadCount;
  final String? avatarUrl;
  final Widget? leading;
  final double? leadingWidth;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;
  final bool transparent;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showNotification = true,
    this.unreadCount = 0,
    this.avatarUrl,
    this.leading,
    this.leadingWidth,
    this.onNotificationTap,
    this.onBackTap,
    this.transparent = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget? leadingWidget = leading;
    
    if (leadingWidget == null) {
      if (showBackButton) {
        leadingWidget = Center(
          child: Semantics(
            button: true,
            label: 'Back',
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.primary, size: 20),
              onPressed: onBackTap,
            ),
          ),
        );
      } else if (avatarUrl != null) {
        leadingWidget = Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: AppAvatar(
              imageUrl: avatarUrl!,
              size: 36,
              showBorder: true,
            ),
          ),
        );
      }
    }

    final primaryGradient = LinearGradient(
      colors: [colorScheme.primary, colorScheme.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AppBar(
      backgroundColor: transparent ? Colors.transparent : colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight + 12,
      centerTitle: true,
      leading: leadingWidget,
      leadingWidth: leadingWidth ?? (showBackButton ? null : ((avatarUrl != null || leading != null) ? 64 + 16 : null)),
      title: ShaderMask(
        shaderCallback: (bounds) => primaryGradient.createShader(bounds),
        child: AppHeading(
          title ?? 'Savaio',
          size: AppHeadingSize.h3,
          color: Colors.white,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        if (showNotification) ...[
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Semantics(
                  button: true,
                  label: 'Notifications',
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.notifications_none_rounded, color: colorScheme.primary, size: 20),
                      onPressed: onNotificationTap,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.surface, width: 2),
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
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ] else if (showBackButton || avatarUrl != null || leading != null)
          const SizedBox(width: 48), // Balance the leading widget for centering
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}
