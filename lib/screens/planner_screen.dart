import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../providers/providers.dart';
import '../models/task.dart';
import 'vision_board_screen.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});
  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  int _tab = 0;

  void _showAddTask() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    String tag = 'PERSONAL';

    showModalBottomSheet(
      context: context,
      backgroundColor: bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Task',
                  style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _input(titleCtrl, 'Title'),
              const SizedBox(height: 10),
              _input(descCtrl, 'Description'),
              const SizedBox(height: 10),
              _input(timeCtrl, 'Time (e.g. 08:00 AM)'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: tag,
                dropdownColor: bgCard2,
                style: const TextStyle(color: textPrimary),
                decoration: _inputDeco('Category'),
                items: ['PERSONAL', "PARTNER'S", 'CONNECTION GOAL']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setModal(() => tag = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: accentPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    final user = ref.read(currentUserProvider).value;
                    if (user == null || titleCtrl.text.trim().isEmpty) return;
                    final task = Task(
                      id: const Uuid().v4(),
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      tag: tag,
                      time: timeCtrl.text.trim(),
                      done: false,
                      createdBy: user.uid,
                      addedByName: user.name,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(taskServiceProvider).addTask(user.uid, user.partnerId, task);
                    if (mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Add Task', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Planner',
                      style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('STRENGTHENING CONNECTIONS TODAY',
                      style: TextStyle(color: textSecondary, fontSize: 10, letterSpacing: 1.5)),
                  const SizedBox(height: 20),
                  Row(children: [
                    _tabBtn('Daily', 0),
                    const SizedBox(width: 8),
                    _tabBtn('Weekly', 1),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const VisionBoardScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(10)),
                        child: const Row(children: [
                          Icon(Icons.copy, color: textSecondary, size: 16),
                          SizedBox(width: 6),
                          Text('VISION\nBOARD',
                              style: TextStyle(color: textPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
                error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: accentPink))),
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks yet.\nTap + to add your first task!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textSecondary, fontSize: 14)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _taskCard(tasks[i], user?.uid ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentPurple,
        onPressed: _showAddTask,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _tabBtn(String label, int idx) => GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: _tab == idx ? accentPurple : bgCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  color: _tab == idx ? Colors.white : textSecondary,
                  fontWeight: FontWeight.w600)),
        ),
      );

  Widget _taskCard(Task task, String myUid) {
    final color = task.tag == 'CONNECTION GOAL'
        ? accentPink
        : task.tag == "PARTNER'S"
            ? accentPurple
            : Colors.green;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: accentPink.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: accentPink),
      ),
      onDismissed: (_) async {
        final user = ref.read(currentUserProvider).value;
        if (user == null) return;
        await ref.read(taskServiceProvider).deleteTask(user.uid, user.partnerId, task.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(task.tag,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            Text(task.done ? 'DONE' : task.time,
                style: TextStyle(
                    color: task.done ? Colors.green : textSecondary,
                    fontSize: 12,
                    fontWeight: task.done ? FontWeight.bold : FontWeight.normal)),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () async {
                final user = ref.read(currentUserProvider).value;
                if (user == null) return;
                await ref.read(taskServiceProvider)
                    .toggleTask(user.uid, user.partnerId, task.id, !task.done);
              },
              child: Container(
                width: 22, height: 22,
                margin: const EdgeInsets.only(top: 2, right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.done ? Colors.green : Colors.transparent,
                  border: task.done ? null : Border.all(color: color),
                ),
                child: task.done ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
              ),
            ),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title,
                  style: TextStyle(
                    color: task.done ? textSecondary : textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: task.done ? TextDecoration.lineThrough : null,
                  )),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(task.description, style: const TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ])),
          ]),
          if (task.addedByName != null && task.createdBy != myUid) ...[
            const SizedBox(height: 10),
            Row(children: [
              const CircleAvatar(radius: 10, backgroundColor: accentPink),
              const SizedBox(width: 6),
              Text('${task.addedByName!.toUpperCase()} ADDED THIS',
                  style: const TextStyle(color: accentPurple, fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        style: const TextStyle(color: textPrimary),
        decoration: _inputDeco(hint),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textSecondary),
        filled: true,
        fillColor: bgCard2,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      );
}
