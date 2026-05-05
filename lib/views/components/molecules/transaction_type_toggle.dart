import 'package:flutter/material.dart';

class TransactionTypeToggleOption {
  final String label;
  final String value;
  final IconData icon;
  final Color? activeColor;

  const TransactionTypeToggleOption({
    required this.label,
    required this.value,
    required this.icon,
    this.activeColor,
  });
}

class TransactionTypeToggle extends StatelessWidget {
  final String currentValue;
  final List<TransactionTypeToggleOption> options;
  final Function(String) onChanged;

  const TransactionTypeToggle({
    super.key,
    required this.currentValue,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: options.map((option) {
          final isActive = currentValue == option.value;
          return _buildToggleItem(
            context,
            label: option.label,
            icon: option.icon,
            isActive: isActive,
            activeColor: option.activeColor ?? colorScheme.primary,
            onTap: () => onChanged(option.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: 'Select $label',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
