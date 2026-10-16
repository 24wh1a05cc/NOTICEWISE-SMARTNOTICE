import 'package:flutter/material.dart';

/// Displays the two demo accounts and quick-login buttons on [LoginScreen].
///
/// Quick-login buttons call [onQuickLogin] with pre-filled credentials,
/// reducing tap count for evaluators and demos.
class DemoAccountsCard extends StatelessWidget {
  const DemoAccountsCard({
    super.key,
    required this.onQuickLogin,
  });

  /// Called with (email, password) when a quick-login button is tapped.
  final void Function(String email, String password) onQuickLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Demo Accounts',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AccountRow(
              role: 'Admin',
              email: 'admin@demo.com',
              password: 'admin123',
              icon: Icons.admin_panel_settings_outlined,
              color: colorScheme.primary,
              onTap: () => onQuickLogin('admin@demo.com', 'admin123'),
            ),
            const SizedBox(height: 8),
            _AccountRow(
              role: 'Viewer',
              email: 'user@demo.com',
              password: 'user123',
              icon: Icons.person_outline,
              color: colorScheme.secondary,
              onTap: () => onQuickLogin('user@demo.com', 'user123'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.role,
    required this.email,
    required this.password,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String role;
  final String email;
  final String password;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                password,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        FilledButton.tonal(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: const Size(0, 32),
          ),
          child: Text(
            'Login as $role',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
