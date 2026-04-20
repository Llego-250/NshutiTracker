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
              Padding(
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
                      child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
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
                    '${DateFormat('MMM d, hh:mm a').format(task.createdAt)}',
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
              onPressed: () {},
              child: const Text('Edit Task',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
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
