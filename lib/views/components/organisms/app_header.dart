import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_heading.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showNotification;
  final String? avatarUrl;
  final Widget? leading;
  final VoidCallback? onNotificationTap;
  final bool transparent;

  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showNotification = true,
    this.avatarUrl,
    this.leading,
    this.onNotificationTap,
    this.transparent = false,
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
            padding: const EdgeInsets.only(left: SavaioTheme.spacingL),
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
      backgroundColor: transparent ? Colors.transparent : SavaioTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight + SavaioTheme.spacingM,
      centerTitle: true,
      leading: leadingWidget,
      leadingWidth: showBackButton ? null : ((avatarUrl != null || leading != null) ? 64 + SavaioTheme.spacingL : null),
      title: ShaderMask(
        shaderCallback: (bounds) => SavaioTheme.primaryGradient.createShader(bounds),
        child: AppHeading(
          title ?? 'Savaio',
          size: AppHeadingSize.h3,
          color: Colors.white,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        if (showNotification) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SavaioTheme.surfaceContainerHigh.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: SavaioTheme.primary, size: 20),
              onPressed: onNotificationTap,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: SavaioTheme.spacingL),
        ] else if (showBackButton || avatarUrl != null || leading != null)
          const SizedBox(width: 48), // Balance the leading widget for centering
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + SavaioTheme.spacingM);
}
