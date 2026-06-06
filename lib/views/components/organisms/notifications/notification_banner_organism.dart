import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';

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
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: widget.isFloating ? SavaioTheme.radiusL : 0,
        borderColor: !widget.notification.isRead
            ? color.withValues(alpha: 0.4)
            : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
        borderWidth: widget.isFloating ? 1.5 : 0,
        color: !widget.notification.isRead 
            ? color.withValues(alpha: 0.12) 
            : Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: effectiveColor,
                width: 6,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: effectiveColor, size: 24),
              ),
              const SizedBox(width: 16),
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
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (widget.isFloating)
                          GestureDetector(
                            onTap: widget.onDismiss,
                            child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                    AppHeading(
                      widget.notification.title,
                      size: AppHeadingSize.subtitle,
                      color: widget.notification.isRead ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurface,
                    ),
                    Text(
                      widget.notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.notification.isRead 
                            ? Theme.of(context).colorScheme.onSurfaceVariant 
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: widget.actions!.map((a) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: a,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (!widget.isFloating)
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
            ],
          ),
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
