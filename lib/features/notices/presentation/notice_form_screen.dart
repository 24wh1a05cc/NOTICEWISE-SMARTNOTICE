import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';

/// Screen for creating a new notice or editing an existing one.
///
/// Pass [noticeId] to enter edit mode; omit it for create mode.
class NoticeFormScreen extends ConsumerStatefulWidget {
  const NoticeFormScreen({super.key, this.noticeId});

  final String? noticeId;

  @override
  ConsumerState<NoticeFormScreen> createState() => _NoticeFormScreenState();
}

class _NoticeFormScreenState extends ConsumerState<NoticeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _categoryController = TextEditingController();
  final _authorController = TextEditingController();

  NoticePriority _priority = NoticePriority.normal;
  NoticeStatus _status = NoticeStatus.draft;
  bool _isPinned = false;
  DateTime? _remindAt;
  DateTime? _publishAt;
  DateTime? _expiresAt;
  bool _isLoading = false;
  Notice? _existing;

  bool get _isEdit => widget.noticeId != null;

  static const _categoryOptions = [
    'Academic',
    'Examinations',
    'Events',
    'General',
    'Placements',
    'Sports',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    final notice = await ref
        .read(noticeRepositoryProvider)
        .getById(widget.noticeId!);
    if (notice != null && mounted) {
      _existing = notice;
      _titleController.text = notice.title;
      _bodyController.text = notice.body;
      _categoryController.text = notice.category;
      _authorController.text = notice.authorName;
      _priority = notice.priority;
      _status = notice.status;
      _isPinned = notice.isPinned;
      _remindAt = notice.remindAt;
      _publishAt = notice.publishAt;
      _expiresAt = notice.expiresAt;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _categoryController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime({DateTime? initial}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now.add(const Duration(hours: 1)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          initial ?? now.add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final controller = ref.read(noticesControllerProvider.notifier);

      if (_isEdit && _existing != null) {
        final updated = _existing!.copyWith(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          category: _categoryController.text.trim(),
          authorName: _authorController.text.trim(),
          priority: _priority,
          status: _status,
          isPinned: _isPinned,
          remindAt: _remindAt,
          publishAt:
              _status == NoticeStatus.published ? (_publishAt ?? now) : _publishAt,
          expiresAt: _expiresAt,
          updatedAt: now,
        );
        await controller.updateNotice(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notice updated successfully')),
          );
          context.pop();
        }
      } else {
        final notice = Notice(
          id: _generateId(),
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          category: _categoryController.text.trim(),
          authorName: _authorController.text.trim(),
          priority: _priority,
          status: _status,
          isPinned: _isPinned,
          remindAt: _remindAt,
          publishAt:
              _status == NoticeStatus.published ? (_publishAt ?? now) : _publishAt,
          expiresAt: _expiresAt,
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(noticeRepositoryProvider).create(notice);
        await controller.refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _status == NoticeStatus.published
                    ? 'Notice published successfully'
                    : 'Notice saved as ${_status.label}',
              ),
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save notice: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Notice' : 'New Notice'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
        ],
      ),
      body: _isLoading && _isEdit && _existing == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Title ──────────────────────────────────────────────
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        hintText: 'Enter notice title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 120,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Title is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Author ─────────────────────────────────────────────
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Author / Department',
                        hintText: 'e.g. Academic Office, Prof. Smith',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 80,
                    ),
                    const SizedBox(height: 16),

                    // ── Body ───────────────────────────────────────────────
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Body',
                        hintText: 'Enter notice content…',
                        prefixIcon: Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 6,
                      maxLength: 2000,
                    ),
                    const SizedBox(height: 16),

                    // ── Category ───────────────────────────────────────────
                    Text('Category', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _categoryOptions.map((cat) {
                        final selected = _categoryController.text == cat;
                        return FilterChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _categoryController.text = cat);
                          },
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Priority ────────────────────────────────────────────
                    Text('Priority', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: NoticePriority.values.map((p) {
                        final selected = _priority == p;
                        return ChoiceChip(
                          label: Text(p.label),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _priority = p),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Status ──────────────────────────────────────────────
                    Text('Status', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: NoticeStatus.values.map((s) {
                        final selected = _status == s;
                        return ChoiceChip(
                          label: Text(s.label),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _status = s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Status hint
                    Text(
                      switch (_status) {
                        NoticeStatus.published =>
                          '✓ Visible to all users immediately',
                        NoticeStatus.draft =>
                          '⊘ Only visible to admins',
                        NoticeStatus.scheduled =>
                          '⏰ Will publish on the publish date',
                      },
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),

                    // ── Pin toggle ─────────────────────────────────────────
                    SwitchListTile(
                      value: _isPinned,
                      onChanged: (v) => setState(() => _isPinned = v),
                      title: const Text('Pin this notice'),
                      subtitle: const Text('Pinned notices appear at the top'),
                      secondary: const Icon(Icons.push_pin_outlined),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 24),

                    // ── Publish date ───────────────────────────────────────
                    _DateTile(
                      icon: Icons.publish_outlined,
                      label: 'Publish Date',
                      value: _publishAt,
                      onPick: () async {
                        final dt =
                            await _pickDateTime(initial: _publishAt);
                        if (dt != null) setState(() => _publishAt = dt);
                      },
                      onClear: () => setState(() => _publishAt = null),
                    ),
                    const SizedBox(height: 12),

                    // ── Expiry date ────────────────────────────────────────
                    _DateTile(
                      icon: Icons.event_busy_outlined,
                      label: 'Expiry Date',
                      value: _expiresAt,
                      onPick: () async {
                        final dt =
                            await _pickDateTime(initial: _expiresAt);
                        if (dt != null) setState(() => _expiresAt = dt);
                      },
                      onClear: () => setState(() => _expiresAt = null),
                    ),
                    const SizedBox(height: 12),

                    // ── Reminder ────────────────────────────────────────────
                    _DateTile(
                      icon: Icons.alarm_outlined,
                      label: 'Reminder',
                      value: _remindAt,
                      onPick: () async {
                        final dt =
                            await _pickDateTime(initial: _remindAt);
                        if (dt != null) setState(() => _remindAt = dt);
                      },
                      onClear: () => setState(() => _remindAt = null),
                    ),

                    const SizedBox(height: 32),

                    // ── Save / Publish buttons ─────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _status = NoticeStatus.draft);
                              _save();
                            },
                            child: const Text('Save as Draft'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              setState(() => _status = NoticeStatus.published);
                              _save();
                            },
                            icon: const Icon(Icons.publish),
                            label: const Text('Publish'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ignore: unused_element
  Widget _buildDateTile({
    required IconData icon,
    required String label,
    required DateTime? value,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value == null ? 'Not set' : _fmtDate(value)),
      trailing: value != null
          ? IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
              onPressed: onClear,
            )
          : Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      contentPadding: EdgeInsets.zero,
      onTap: onPick,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cs.outlineVariant),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final IconData icon;
  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value == null ? 'Not set — tap to set' : _fmtDate(value!),
        style: TextStyle(
          color: value == null ? cs.onSurfaceVariant : null,
        ),
      ),
      trailing: value != null
          ? IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
              onPressed: onClear,
            )
          : Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      contentPadding: EdgeInsets.zero,
      onTap: onPick,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cs.outlineVariant),
      ),
    );
  }
}
