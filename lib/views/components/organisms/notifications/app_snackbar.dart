import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';

enum AppSnackBarType { success, error, info, warning }

class AppSnackBar extends StatelessWidget {
  final String message;
  final AppSnackBarType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;
  final bool minimal;

  const AppSnackBar({
    super.key,
    required this.message,
    this.type = AppSnackBarType.info,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
    this.minimal = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (type) {
      case AppSnackBarType.success:
        color = Theme.of(context).colorScheme.tertiary;
        icon = Icons.check_circle_rounded;
        break;
      case AppSnackBarType.error:
        color = Theme.of(context).colorScheme.error;
        icon = Icons.error_rounded;
        break;
      case AppSnackBarType.warning:
        color = Colors.orange;
        icon = Icons.warning_rounded;
        break;
      case AppSnackBarType.info:
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.info_rounded;
        break;
    }

    return Center(
      child: Container(
        margin: minimal 
            ? const EdgeInsets.fromLTRB(16, 12, 16, 0)
            : const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: GlassCard(
          padding: minimal 
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: minimal ? 100 : 20,
          borderColor: minimal ? Colors.transparent : color.withValues(alpha: 0.4),
          borderWidth: minimal ? 0 : 1.5,
          color: minimal 
              ? color.withValues(alpha: 1.0) 
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: minimal ? Colors.black.withValues(alpha: 0.1) : color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: minimal ? Colors.black : color, size: 16),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: minimal ? Colors.black : Theme.of(context).colorScheme.onSurface,
                    fontSize: minimal ? 12 : 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!minimal && actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    onAction!();
                    onDismiss();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: color.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    actionLabel!.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
              if (!minimal) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(Icons.close_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, 
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
    bool minimal = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => _SnackBarWrapper(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () => entry.remove(),
        duration: duration,
        minimal: minimal,
      ),
    );

    overlay.insert(entry);
  }
}

class _SnackBarWrapper extends StatefulWidget {
  final String message;
  final AppSnackBarType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;
  final Duration duration;
  final bool minimal;

  const _SnackBarWrapper({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
    required this.duration,
    this.minimal = false,
  });

  @override
  State<_SnackBarWrapper> createState() => _SnackBarWrapperState();
}

class _SnackBarWrapperState extends State<_SnackBarWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // MENGOPTIMALKAN DURASI (Snappy & Responsive)
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.minimal ? 120 : 180),
      reverseDuration: Duration(milliseconds: widget.minimal ? 100 : 140),
      vsync: this,
    );

    // MENGOPTIMALKAN KURVA ANIMASI
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5), // Jarak slide dikurangi agar tidak terlalu jauh melompat
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.minimal ? Curves.easeOutCubic : Curves.easeOutBack, // Menghasilkan sedikit hentakan premium tanpa membal lama
      reverseCurve: Curves.easeInCubic, // Keluar dengan mulus dan cepat
    ));

    _controller.forward().then((_) {
      if (mounted) {
        _timer = Timer(widget.duration, () {
          if (mounted) _dismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_controller.status == AnimationStatus.reverse || 
        _controller.status == AnimationStatus.dismissed) {
      return;
    }
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: AppSnackBar(
            message: widget.message,
            type: widget.type,
            actionLabel: widget.actionLabel,
            onAction: widget.onAction,
            onDismiss: _dismiss,
            minimal: widget.minimal,
          ),
        ),
      ),
    );
  }
}