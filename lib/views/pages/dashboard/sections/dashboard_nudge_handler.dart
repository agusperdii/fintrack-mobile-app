import 'package:flutter/material.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/views/components/organisms/recommendation_bottom_sheet.dart';

class DashboardNudgeHandler extends StatefulWidget {
  final FinanceController controller;
  final Widget child;

  const DashboardNudgeHandler({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<DashboardNudgeHandler> createState() => _DashboardNudgeHandlerState();
}

class _DashboardNudgeHandlerState extends State<DashboardNudgeHandler> {
  bool _isNudgeShowing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onFinanceStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onFinanceStateChanged);
    super.dispose();
  }

  void _onFinanceStateChanged() {
    if (mounted) {
      _checkAndShowNudge();
    }
  }

  void _checkAndShowNudge() {
    if (_isNudgeShowing) return;

    final nudge = widget.controller.latestUnreadNudge;
    if (nudge != null && mounted) {
      _isNudgeShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        RecommendationBottomSheet.show(context, nudge, () {
          widget.controller.markNudgeAsRead(nudge.id);
          _isNudgeShowing = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
