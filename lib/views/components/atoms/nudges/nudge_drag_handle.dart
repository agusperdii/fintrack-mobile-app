import 'package:flutter/material.dart';

class NudgeDragHandle extends StatelessWidget {
  final Color? color;

  const NudgeDragHandle({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Semantics(
      label: 'Drag handle',
      child: Container(
        width: 48,
        height: 6,
        decoration: BoxDecoration(
          color: color ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }
}
