// notifications_page.dart
// Halaman daftar notifikasi pengguna, menampilkan filter baca/belum dibaca
// serta aksi tandai dibaca dan hapus notifikasi melalui NotificationController.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/notification_controller.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/organisms/notifications/notification_banner_organism.dart';
import 'package:savaio/views/components/organisms/notifications/notification_popup_organism.dart';
import 'package:savaio/views/components/organisms/notifications/notification_toast_organism.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/organisms/notifications/app_snackbar.dart';
import 'package:savaio/core/theme/app_theme.dart';

import 'package:savaio/models/notification_data.dart' as model;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Indeks filter aktif: 0 = Semua, 1 = Belum Dibaca
  int _activeFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationController>();
    
    final filteredNotifications = _activeFilterIndex == 0
        ? controller.notifications
        : controller.notifications.where((n) => !n.isRead).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeader(
        title: 'Notifikasi',
        showBackButton: true,
        showNotification: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAll(),
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppHeading('Notifikasi Anda', size: AppHeadingSize.h2),
                  if (controller.unreadNotificationsCount > 0)
                    TextButton.icon(
                      onPressed: () {
                        for (var n in controller.notifications) {
                          if (!n.isRead) controller.markAsRead(n.id);
                        }
                      },
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text(
                        'Baca semua',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24), 
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Semua',
                    isActive: _activeFilterIndex == 0,
                    count: controller.notifications.length,
                    onTap: () => setState(() => _activeFilterIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Belum Dibaca',
                    isActive: _activeFilterIndex == 1,
                    count: controller.unreadNotificationsCount,
                    onTap: () => setState(() => _activeFilterIndex = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _buildContent(controller, filteredNotifications),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(NotificationController controller, List<model.NotificationData> list) {
    if (controller.isLoading && list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.error != null && list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat data info terbaru',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => controller.fetchAll(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                AppHeading(
                  'Belum ada notifikasi di sini',
                  size: AppHeadingSize.subtitle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24), 
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final notif = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12), 
          child: _buildSwipeableNotificationItem(controller, notif),
        );
      },
    );
  }

  Widget _buildSwipeableNotificationItem(NotificationController controller, model.NotificationData notif) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (direction) {
        controller.deleteNotification(notif.id);

        AppSnackBar.show(
          context,
          'Notifikasi berhasil dihapus',
          type: AppSnackBarType.success,
          minimal: true,
        );
      },
      child: _buildNotificationCard(controller, notif),
    );
  }

  Widget _buildNotificationCard(NotificationController controller, model.NotificationData notif) {
    List<Widget> actions = [];
    
    if (!notif.isRead) {
      actions.add(
        GestureDetector(
          onTap: () => controller.markAsRead(notif.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SavaioTheme.radiusS),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Baca',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    void onTap() {
      if (!notif.isRead) {
        controller.markAsRead(notif.id);
      }
      if (notif.presentation == model.NotificationPresentation.popup) {
        NotificationPopupOrganism.show(context, notif, onRead: () => controller.markAsRead(notif.id));
      } else if (notif.presentation == model.NotificationPresentation.toast) {
        NotificationToastOrganism.show(context, notif);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: notif.isRead 
            ? Colors.transparent 
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: NotificationBannerOrganism(
        notification: notif,
        onTap: onTap,
        actions: actions,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required int count,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.onPrimary.withValues(alpha: 0.2) : colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive ? colorScheme.onPrimary : colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}