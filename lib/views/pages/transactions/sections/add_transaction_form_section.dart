import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AddTransactionFormSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const AddTransactionFormSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedDate,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTitleSection(context),
        const SizedBox(height: 16),
        _buildDateTimeSection(context),
        const SizedBox(height: 32),
        _buildNotesSection(context),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildBentoContainer(
      context,
      icon: Icons.title_rounded,
      iconColor: colorScheme.primary,
      title: 'Judul Transaksi',
      child: TextField(
        controller: titleController,
        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Misal: Makan Siang di Kantin',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          border: InputBorder.none,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildBentoContainer(
      context,
      icon: Icons.calendar_today,
      iconColor: colorScheme.secondary,
      title: 'Waktu & Tanggal',
      child: Column(
        children: [
          _buildBentoValueItem(
            context,
            label: DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
            icon: Icons.calendar_today,
            onTap: onPickDate,
          ),
          const SizedBox(height: 8),
          _buildBentoValueItem(
            context,
            label: '${DateFormat('HH:mm').format(selectedDate)} WIB',
            icon: Icons.schedule,
            onTap: onPickTime,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildBentoContainer(
      context,
      icon: Icons.description,
      iconColor: colorScheme.tertiary,
      title: 'Catatan Tambahan',
      child: TextField(
        controller: descriptionController,
        maxLines: 3,
        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Makan siang bareng temen...',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          border: InputBorder.none,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          filled: true,
          contentPadding: const EdgeInsets.all(12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoContainer(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              AppHeading(
                title,
                size: AppHeadingSize.subtitle,
                isBold: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBentoValueItem(BuildContext context, {required String label, required IconData icon, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: onTap != null ? Border.all(color: colorScheme.primary.withValues(alpha: 0.2)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 14),
          ],
        ),
      ),
    );
  }
}
