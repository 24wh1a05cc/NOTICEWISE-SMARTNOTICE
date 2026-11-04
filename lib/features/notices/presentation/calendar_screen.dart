import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';
import 'package:table_calendar/table_calendar.dart';

/// Calendar screen — shows notice dates on a monthly calendar with agenda below.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Build a map of date → list of notices for that date.
  Map<DateTime, List<Notice>> _buildEvents(List<Notice> notices) {
    final map = <DateTime, List<Notice>>{};
    for (final n in notices) {
      // Use publish date if available, else created date
      final raw = n.publishAt ?? n.createdAt;
      final day = DateTime(raw.year, raw.month, raw.day);
      map.putIfAbsent(day, () => []).add(n);

      // Also mark expiry date
      if (n.expiresAt != null) {
        final expDay = DateTime(
            n.expiresAt!.year, n.expiresAt!.month, n.expiresAt!.day);
        map.putIfAbsent(expDay, () => []).add(n);
      }

      // Mark reminder date
      if (n.remindAt != null) {
        final remDay = DateTime(
            n.remindAt!.year, n.remindAt!.month, n.remindAt!.day);
        map.putIfAbsent(remDay, () => []).add(n);
      }
    }
    return map;
  }

  List<Notice> _eventsForDay(
      DateTime day, Map<DateTime, List<Notice>> events) {
    final key = DateTime(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  @override
  Widget build(BuildContext context, ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final noticesState = ref.watch(noticesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: 'Go to today',
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: noticesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (notices) {
          final published =
              notices.where((n) => n.status == NoticeStatus.published).toList();
          final events = _buildEvents(published);
          final selected = _selectedDay ?? _focusedDay;
          final dayNotices = _eventsForDay(selected, events);

          return Column(
            children: [
              // ── Table Calendar ──────────────────────────────────────────
              TableCalendar<Notice>(
                firstDay:
                    DateTime.now().subtract(const Duration(days: 180)),
                lastDay:
                    DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _format,
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, day),
                eventLoader: (day) => _eventsForDay(day, events),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) =>
                    setState(() => _format = format),
                onPageChanged: (focusedDay) =>
                    setState(() => _focusedDay = focusedDay),
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle:
                      TextStyle(color: cs.onPrimaryContainer),
                  selectedDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle:
                      TextStyle(color: cs.onPrimary),
                  outsideDaysVisible: false,
                  markersMaxCount: 3,
                ),
                headerStyle: HeaderStyle(
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: cs.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  formatButtonTextStyle:
                      TextStyle(color: cs.onSurface, fontSize: 12),
                  titleCentered: true,
                ),
              ),

              const Divider(height: 1),

              // ── Day heading ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(
                      _formatHeading(selected),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (dayNotices.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${dayNotices.length}',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Agenda list ─────────────────────────────────────────────
              Expanded(
                child: dayNotices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_available_outlined,
                                size: 48,
                                color: cs.onSurfaceVariant
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(
                              'No notices on this day',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: dayNotices.length,
                        itemBuilder: (context, i) =>
                            _AgendaItem(notice: dayNotices[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatHeading(DateTime day) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[day.weekday - 1]}, ${day.day} ${months[day.month - 1]}';
  }
}

class _AgendaItem extends StatelessWidget {
  const _AgendaItem({required this.notice});

  final Notice notice;

  Color _priorityColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (notice.priority) {
      NoticePriority.urgent => cs.error,
      NoticePriority.high => Colors.orange.shade700,
      NoticePriority.normal => cs.primary,
      NoticePriority.low => cs.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final priorityColor = _priorityColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(AppRoutes.noticeDetail(notice.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Priority indicator strip
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (notice.category.isNotEmpty)
                          Text(
                            notice.category,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          notice.priority.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notice.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notice.authorName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        notice.authorName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
