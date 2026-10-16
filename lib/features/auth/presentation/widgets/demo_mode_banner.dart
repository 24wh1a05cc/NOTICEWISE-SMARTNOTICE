import 'package:flutter/material.dart';

/// Non-dismissible amber banner shown on all authentication screens.
///
/// This widget is MANDATORY on every auth screen. It makes clear to users
/// that authentication is local/demo-only and no data is sent to any server.
///
/// Do not remove or hide this widget in demo mode.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF8E1), // amber[50]
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF57C00), // amber[700]
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠️ Demo Mode — local authentication only. '
              'No data is sent to any server.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6D4C41), // brownish
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
