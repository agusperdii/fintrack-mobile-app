import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/nudges/nudge_progress_line.dart';

class NudgeAlertContent extends StatelessWidget {
  final String title;
  final String message;
  final double progress;

  const NudgeAlertContent({
    super.key,
    required this.title,
    required this.message,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeading(
          title, 
          size: AppHeadingSize.h2,
          color: SavaioTheme.secondary,
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: SavaioTheme.onSurface,
              fontSize: 18,
              height: 1.5,
              fontFamily: 'Inter',
            ),
            children: _parseMessage(message),
          ),
        ),
        const SizedBox(height: 32),
        NudgeProgressLine(progress: progress),
      ],
    );
  }

  List<InlineSpan> _parseMessage(String msg) {
    // Basic logic to highlight percentage in red
    final List<InlineSpan> spans = [];
    final parts = msg.split(' ');
    
    for (var part in parts) {
      if (part.contains('%')) {
        spans.add(TextSpan(
          text: '$part ',
          style: const TextStyle(color: SavaioTheme.error, fontWeight: FontWeight.w900),
        ));
      } else {
        spans.add(TextSpan(text: '$part '));
      }
    }
    return spans;
  }
}
