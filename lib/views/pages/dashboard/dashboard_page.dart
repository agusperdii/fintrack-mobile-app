import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/others.dart';
import 'package:savaio/controllers/finance_controller.dart';
import 'package:savaio/views/pages/dashboard/sections/dashboard_app_bar.dart';
import 'package:savaio/views/pages/dashboard/sections/dashboard_body.dart';
import 'package:savaio/views/pages/dashboard/sections/dashboard_nudge_handler.dart';

class DashboardPage extends StatelessWidget {
  final FinanceController? controller;

  const DashboardPage({
    super.key,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final financeController = controller ?? 
        (context.read<FinanceController?>() ?? sl.financeController);

    return ListenableBuilder(
      listenable: financeController,
      builder: (context, _) {
        // Only show full screen loader if we have NO data at all
        if (financeController.isLoading && financeController.dashboardData == null) {
          return const Scaffold(
            backgroundColor: SavaioTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: SavaioTheme.primary),
            ),
          );
        }

        return DashboardNudgeHandler(
          controller: financeController,
          child: Scaffold(
            backgroundColor: SavaioTheme.background,
            appBar: DashboardAppBar(controller: financeController),
            body: DashboardBody(controller: financeController),
          ),
        );
      },
    );
  }
}
