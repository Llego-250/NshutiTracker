import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/task.dart';
import '../providers/providers.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the live task list so edits made here (or anywhere else) show up at once.
    final task = ref.watch(tasksProvider).value?.where((t) => t.id == this.task.id).firstOrNull ??
        this.task;
    final priorityColor = task.priority == 'High'
        ? accentPink
        : task.priority == 'Medium'
            ? Colors.orange
            : task.priority == 'Low'
                ? Colors.green
                : textSecondary;

    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(children: [
        CustomScrollView(slivers: [
          // ── Hero image
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: bgDark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _confirmDelete(context, ref, task),
                child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: task.imageUrl != null
                  ? Image.network(task.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentPurple.withOpacity(0.6),
                            accentBlue.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: Colors.white38, size: 64),
                      ),
                    ),
            ),
          ),

          // ── Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: priorityColor.withOpacity(0.4)),
                  ),
                  child: Text(task.priority,
                      style: TextStyle(color: priorityColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),

                // Title
                Text(task.title,
                    style: const TextStyle(
                        color: textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Description
                if (task.description.isNotEmpty)
                  Text(task.description,
                      style: const TextStyle(color: textSecondary, fontSize: 14, height: 1.5)),

                const SizedBox(height: 20),

                // Date + Time row
                Row(children: [
                  Expanded(child: _infoBox(
                    'Start Date',
                    DateFormat('MMM d, hh:mm a').format(task.createdAt),
                    Icons.access_time,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _infoBox(
                    'Time',
                    task.time.isNotEmpty ? task.time : '--:--',
                    Icons.access_time,
                  )),
                ]),

                if (task.location != null) ...[
                  const SizedBox(height: 12),
                  _infoBox('Location', task.location!, Icons.location_on_outlined),
                ],

                if (task.meetingLink != null) ...[
                  const SizedBox(height: 12),
                  _infoBox('Meeting Link', task.meetingLink!, Icons.link),
                ],

                // Subtasks
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('Task Checklist',
                      style: TextStyle(
                          color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...task.subtasks.map((s) => _subtaskTile(s, ref)),
                ],

                // Tag
                const SizedBox(height: 20),
                Row(children: [
                  const Icon(Icons.label_outline, color: textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(task.tag,
                      style: const TextStyle(color: textSecondary, fontSize: 13)),
                  const Spacer(),
                  if (task.repeat != 'None')
                    Row(children: [
                      const Icon(Icons.repeat, color: textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(task.repeat,
                          style: const TextStyle(color: textSecondary, fontSize: 13)),
                    ]),
                ]),
              ]),
            ),
          ),
        ]),

        // ── Bottom Edit button
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgDark.withOpacity(0), bgDark],
              ),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor: bgDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: bgCard,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (_) => EditTaskSheet(task: task),
              ),
              child: const Text('Edit Task',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: bgCard,
        title: const Text('Delete task?', style: TextStyle(color: textPrimary)),
        content: Text(
          '"${task.title}" will be removed permanently.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider).value;
              if (user == null) return;
              await ref.read(taskServiceProvider).deleteTask(user.uid, task.id);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx); // close dialog
              if (context.mounted)
                Navigator.pop(context); // leave detail screen
            },
            child: const Text('Delete', style: TextStyle(color: accentPink)),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(icon, color: textSecondary, size: 14),
            const SizedBox(width: 5),
            Expanded(
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ]),
        ]),
      );

  Widget _subtaskTile(SubTask s, WidgetRef ref) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: s.done
              ? accentPurple.withOpacity(0.12)
              : accentBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: s.done
                ? accentPurple.withOpacity(0.3)
                : accentBlue.withOpacity(0.15),
          ),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.title,
                style: TextStyle(
                  color: s.done ? textSecondary : textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: s.done ? TextDecoration.lineThrough : null,
                )),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.access_time, color: textSecondary, size: 12),
              const SizedBox(width: 4),
              Text(task.time.isNotEmpty ? task.time : '--',
                  style: const TextStyle(color: textSecondary, fontSize: 11)),
            ]),
          ])),
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s.done ? accentPurple : Colors.transparent,
              border: s.done ? null : Border.all(color: textSecondary.withOpacity(0.4)),
            ),
            child: s.done
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ]),
      );
}

// ── Edit task sheet ───────────────────────────────────────────────────────────
class EditTaskSheet extends ConsumerStatefulWidget {
  final Task task;
  const EditTaskSheet({super.key, required this.task});
  @override
  ConsumerState<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<EditTaskSheet> {
  static const _categories = ['PERSONAL', 'WORK', 'HEALTH'];
  static const _priorities = ['High', 'Medium', 'Low', 'None'];

  late final _titleCtrl = TextEditingController(text: widget.task.title);
  late final _descCtrl = TextEditingController(text: widget.task.description);
  late final _locationCtrl = TextEditingController(
    text: widget.task.location ?? '',
  );
  late String _tag = _categories.contains(widget.task.tag)
      ? widget.task.tag
      : 'PERSONAL';
  late String _priority = _priorities.contains(widget.task.priority)
      ? widget.task.priority
      : 'None';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title cannot be empty.');
      return;
    }
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final location = _locationCtrl.text.trim();
      await ref.read(taskServiceProvider).updateTask(user.uid, widget.task.id, {
        'title': title,
        'description': _descCtrl.text.trim(),
        'location': location.isEmpty ? null : location,
        'tag': _tag,
        'priority': _priority,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Task',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _field(_titleCtrl, 'Title'),
            const SizedBox(height: 10),
            _field(_descCtrl, 'Description', maxLines: 3),
            const SizedBox(height: 10),
            _field(_locationCtrl, 'Location (optional)'),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            _chips(_categories, _tag, (v) => setState(() => _tag = v)),
            const SizedBox(height: 12),
            const Text(
              'Priority',
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            _chips(
              _priorities,
              _priority,
              (v) => setState(() => _priority = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: accentPink, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: textSecondary),
          filled: true,
          fillColor: bgCard2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _chips(
    List<String> options,
    String selected,
    ValueChanged<String> onSelect,
  ) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: options
        .map(
          (o) => ChoiceChip(
            label: Text(o),
            selected: o == selected,
            onSelected: (_) => onSelect(o),
            selectedColor: accentPurple,
            backgroundColor: bgCard2,
            labelStyle: TextStyle(
              color: o == selected ? Colors.white : textSecondary,
              fontSize: 12,
            ),
            showCheckmark: false,
          ),
        )
        .toList(),
  );
}
