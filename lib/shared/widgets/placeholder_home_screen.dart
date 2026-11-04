import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/app/theme/theme_notifier.dart';
import 'package:noticewise/core/constants/app_strings.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';

/// Home screen shown after sign-in, with navigation to notices.
class PlaceholderHomeScreen extends ConsumerWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          Tooltip(
            message: isDark
                ? AppStrings.settingsThemeLight
                : AppStrings.settingsThemeDark,
            child: IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => ref.read(themeProvider.notifier).toggle(),
            ),
          ),
          Tooltip(
            message: AppStrings.authSignOut,
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appTagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // ── Notices shortcut ──────────────────────────────────────
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.notices),
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('View Notices'),
                ),
                const SizedBox(height: 24),
                if (user != null) _UserInfoCard(user: user),
                const SizedBox(height: 16),
                const _SetupStatusCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(user.role.label),
              avatar: Icon(
                user.role.isAdmin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.person_outline,
                size: 16,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupStatusCard extends StatelessWidget {
  const _SetupStatusCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Spec 2 — Authentication Complete',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _statusRow(context, 'Demo login / sign-up / sign-out', true),
            _statusRow(context, 'Session persistence (SharedPreferences)', true),
            _statusRow(context, 'Role-based routing (admin / viewer)', true),
            _statusRow(context, 'AuthRepository interface + MockImpl', true),
            _statusRow(context, 'Forgot-password demo flow', true),
            _statusRow(context, 'Demo mode banner on all auth screens', true),
            _statusRow(context, 'Local SQLite notices (CRUD)', true),
            _statusRow(context, 'Local notifications / reminders', true),
            const SizedBox(height: 12),
            Text(
              'Running fully offline — no Firebase or API keys required.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(BuildContext context, String label, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            done ? Icons.check : Icons.schedule,
            size: 16,
            color: done
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
