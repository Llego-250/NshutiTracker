import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
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
  int _tab = 0; // 0=Daily 1=Weekly 2=Calendar
  DateTime _selectedDate = DateTime.now();
  DateTime _calendarMonth = DateTime.now();
  bool _showCalendar = false;

  // ── Add task sheet ──────────────────────────────────────────────────────────
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                    createdAt: _selectedDate,
                  );
                  await ref.read(taskServiceProvider).addTask(user.uid, user.partnerId, task);
                  if (mounted) Navigator.pop(ctx);
                },
                child: const Text('Add Task', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
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
        child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Header ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Daily Planner',
                    style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                const Text('STRENGTHENING CONNECTIONS TODAY',
                    style: TextStyle(color: textSecondary, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                Row(children: [
                  _tabBtn('Daily', 0),
                  const SizedBox(width: 8),
                  _tabBtn('Weekly', 1),
                  const SizedBox(width: 8),
                  _tabBtn('Calendar', 2),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VisionBoardScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(10)),
                      child: const Row(children: [
                        Icon(Icons.copy, color: textSecondary, size: 14),
                        SizedBox(width: 4),
                        Text('VISION\nBOARD',
                            style: TextStyle(color: textPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ]),
              ]),
            ),

            // ── Weekly strip (shown when tab == 1) ────────────────────────────
            if (_tab == 1) ...[
              const SizedBox(height: 12),
              _WeekStrip(
                selectedDate: _selectedDate,
                onDateSelected: (d) => setState(() => _selectedDate = d),
              ),
            ],

            // ── Task list ──────────────────────────────────────────────────────
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
                error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: accentPink))),
                data: (allTasks) {
                  final tasks = _filterTasks(allTasks);
                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.event_note, color: textSecondary, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No tasks for ${DateFormat('MMM d').format(_selectedDate)}.\nTap + to add one!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: textSecondary, fontSize: 14),
                        ),
                      ]),
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
          ]),

          // ── Floating Calendar overlay (tab == 2) ───────────────────────────
          if (_tab == 2)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _LiquidGlassCalendar(
                    selectedDate: _selectedDate,
                    month: _calendarMonth,
                    onDateSelected: (d) => setState(() {
                      _selectedDate = d;
                      _tab = 0;
                    }),
                    onMonthChanged: (m) => setState(() => _calendarMonth = m),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      DateFormat('EEEE, MMMM d').format(_selectedDate),
                      style: const TextStyle(color: accentPurple, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
            ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentPurple,
        onPressed: _showAddTask,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

// Filter tasks by selected date
List<Task> _filterTasks(List<Task> tasks) {
  return tasks.where((t) {
    final d = t.createdAt;
    return d.year == _selectedDate.year &&
        d.month == _selectedDate.month &&
        d.day == _selectedDate.day;
  }).toList();
}

Widget _tabBtn(String label, int idx) {
  return GestureDetector(
    onTap: () => setState(() => _tab = idx),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _tab == idx ? accentPurple : bgCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: _tab == idx ? Colors.white : textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13)),
    ),
  );
}

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

// ── Liquid Glass Calendar ─────────────────────────────────────────────────────
class _LiquidGlassCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime month;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _LiquidGlassCalendar({
    required this.selectedDate,
    required this.month,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final years = List.generate(11, (i) => DateTime.now().year - 5 + i);
    final days = _buildDays();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: accentBlue.withOpacity(0.10),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(children: [
        // Month / Year navigation
        Row(children: [
          // Prev
          GestureDetector(
            onTap: () => onMonthChanged(DateTime(month.year, month.month - 1)),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.chevron_left, color: textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // Month dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: month.month,
                  isDense: true,
                  dropdownColor: bgCard,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                  items: List.generate(12, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(months[i]),
                  )),
                  onChanged: (v) => onMonthChanged(DateTime(month.year, v!)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Year dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: month.year,
                isDense: true,
                dropdownColor: bgCard,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                onChanged: (v) => onMonthChanged(DateTime(v!, month.month)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Next
          GestureDetector(
            onTap: () => onMonthChanged(DateTime(month.year, month.month + 1)),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.chevron_right, color: textPrimary, size: 20),
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // Day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
              .map((d) => SizedBox(
                    width: 36,
                    child: Text(d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Day grid
        ...List.generate((days.length / 7).ceil(), (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (col) {
                final idx = row * 7 + col;
                if (idx >= days.length) return const SizedBox(width: 36);
                final day = days[idx];
                return _DayCell(
                  day: day,
                  currentMonth: month,
                  selectedDate: selectedDate,
                  onTap: day != null ? () => onDateSelected(day) : null,
                );
              }),
            ),
          );
        }),
      ]),
        ),
      ),
    );
  }

  List<DateTime?> _buildDays() {
    final first = DateTime(month.year, month.month, 1);
    final startOffset = first.weekday % 7; // Sunday = 0
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final total = ((startOffset + daysInMonth) / 7).ceil() * 7;

    return List.generate(total, (i) {
      if (i < startOffset) {
        // Previous month days (greyed)
        return DateTime(month.year, month.month, 1 - (startOffset - i));
      } else if (i < startOffset + daysInMonth) {
        return DateTime(month.year, month.month, i - startOffset + 1);
      } else {
        // Next month days (greyed)
        return DateTime(nextMonth.year, nextMonth.month, i - startOffset - daysInMonth + 1);
      }
    });
  }
}

class _DayCell extends StatelessWidget {
  final DateTime? day;
  final DateTime currentMonth;
  final DateTime selectedDate;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.currentMonth,
    required this.selectedDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox(width: 36, height: 36);

    final isCurrentMonth = day!.month == currentMonth.month;
    final isSelected = day!.year == selectedDate.year &&
        day!.month == selectedDate.month &&
        day!.day == selectedDate.day;
    final isToday = DateUtils.isSameDay(day, DateTime.now());

    Color bgColor = Colors.transparent;
    Color textColor = isCurrentMonth ? textPrimary : textSecondary.withOpacity(0.4);
    FontWeight fontWeight = FontWeight.normal;

    if (isSelected) {
      bgColor = accentBlue;
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    } else if (isToday) {
      bgColor = Colors.white.withOpacity(0.15);
      textColor = accentBlue;
      fontWeight = FontWeight.bold;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected
              ? Border.all(color: accentBlue.withOpacity(0.5), width: 1.5)
              : null,
          boxShadow: isSelected
              ? [BoxShadow(color: accentBlue.withOpacity(0.4), blurRadius: 8)]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day!.day}',
          style: TextStyle(color: textColor, fontWeight: fontWeight, fontSize: 13),
        ),
      ),
    );
  }
}

// ── Week strip ────────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _WeekStrip({required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    // Build 7 days centered on selectedDate
    final start = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final dayNames = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          final isSelected = DateUtils.isSameDay(d, selectedDate);
          final isToday = DateUtils.isSameDay(d, DateTime.now());
          return GestureDetector(
            onTap: () => onDateSelected(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accentBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                    ? Border.all(color: accentBlue.withOpacity(0.5))
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: accentBlue.withOpacity(0.4), blurRadius: 8)]
                    : null,
              ),
              child: Column(children: [
                Text(dayNames[d.weekday % 7],
                    style: TextStyle(
                        color: isSelected ? Colors.white : textSecondary,
                        fontSize: 11)),
                const SizedBox(height: 4),
                Text('${d.day}',
                    style: TextStyle(
                        color: isSelected ? Colors.white : isToday ? accentBlue : textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}
