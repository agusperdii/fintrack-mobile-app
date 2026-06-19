import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';


class NotificationBannerOrganism extends StatefulWidget {
  final NotificationData notification;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final bool isFloating;
  final VoidCallback? onDismiss;

  const NotificationBannerOrganism({
    super.key,
    required this.notification,
    this.onTap,
    this.actions,
    this.isFloating = false,
    this.onDismiss,
  });

  @override
  State<NotificationBannerOrganism> createState() => _NotificationBannerOrganismState();

  static void show(BuildContext context, NotificationData notification, {VoidCallback? onRead}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => _FloatingBannerWrapper(
        notification: notification,
        onTap: () {
          onRead?.call();
          entry.remove();
        },
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _NotificationBannerOrganismState extends State<NotificationBannerOrganism> {
  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (widget.notification.severity) {
      case NotificationSeverity.warning:
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationSeverity.danger:
        color = Theme.of(context).colorScheme.error;
        icon = Icons.error_outline_rounded;
        break;
      case NotificationSeverity.info:
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.info_outline_rounded;
        break;
    }

    final effectiveColor = widget.notification.isRead ? color.withValues(alpha: 0.5) : color;

    return GestureDetector(
  onTap: widget.onTap,
  child: Container(
    margin: widget.isFloating
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh, // abu tua seperti notif WhatsApp
      borderRadius: BorderRadius.circular(widget.isFloating ? 14 : 12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: effectiveColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.notification.type.name.toUpperCase(),
                    style: TextStyle(
                      color: effectiveColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (widget.isFloating)
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AppHeading(
                widget.notification.title,
                size: AppHeadingSize.subtitle,
                color: widget.notification.isRead
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.white,
              ),
              const SizedBox(height: 2),
              Text(
                widget.notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.notification.isRead
                      ? Colors.white.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: widget.actions!
                      .map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: a,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        if (!widget.isFloating)
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.25),
          ),
      ],
    ),
  ),
);
  }
}

class _FloatingBannerWrapper extends StatefulWidget {
  final NotificationData notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _FloatingBannerWrapper({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_FloatingBannerWrapper> createState() => _FloatingBannerWrapperState();
}

class _FloatingBannerWrapperState extends State<_FloatingBannerWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: NotificationBannerOrganism(
              notification: widget.notification,
              isFloating: true,
              onTap: () async {
                await _dismiss();
                widget.onTap();
              },
              onDismiss: _dismiss,
            ),
          ),
        ),
      ),
    );
  }
}
