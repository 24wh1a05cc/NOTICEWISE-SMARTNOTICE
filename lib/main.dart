import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noticewise/app/app.dart';
import 'package:noticewise/app/app_provider_observer.dart';
import 'package:noticewise/core/services/data_seeder.dart';
import 'package:noticewise/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialise local notifications ─────────────────────────────────────────
  await NotificationService.instance.init();

  // ── Seed sample notices on first launch ────────────────────────────────────
  await DataSeeder.instance.seedIfNeeded();

  // ── Launch the application ──────────────────────────────────────────────────
  runApp(
    ProviderScope(
      observers: [
        if (kDebugMode) AppProviderObserver(),
      ],
      child: const NoticeWiseApp(),
    ),
  );
}
