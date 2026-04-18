import 'package:flutter/material.dart';
import '../theme.dart';
import 'vision_board_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int _tab = 0;

  final _tasks = [
    {
      'tag': 'PARTNER\'S',
      'time': '08:00 AM',
      'title': 'Morning Coffee Ritual',
      'desc': 'Prepare a fresh brew and spend 10 mins disconnected from screens.',
      'done': false,
      'color': accentPurple,
      'addedBy': null,
    },
    {
      'tag': 'PERSONAL',
      'time': 'DONE',
      'title': 'Journal Gratitude',
      'desc': 'Write 3 things you appreciated about your partner.',
      'done': true,
      'color': Colors.green,
      'addedBy': null,
    },
    {
      'tag': 'PARTNER\'S',
      'time': '07:00 PM',
      'title': 'Evening Nature Walk',
      'desc': 'A gentle 20-minute walk through the park near the sunset.',
      'done': false,
      'color': accentPurple,
      'addedBy': 'SARAH ADDED THIS',
    },
    {
      'tag': 'CONNECTION GOAL',
      'time': 'TOMORROW',
      'title': 'Deep Conversation Night',
      'desc': 'Discuss our vision for the next five years. Use the prompt deck.',
      'done': false,
      'color': accentPink,
      'addedBy': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  Row(
                    children: [
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
                          child: const Row(
                            children: [
                              Icon(Icons.copy, color: textSecondary, size: 16),
                              SizedBox(width: 6),
                              Text('VISION\nBOARD',
                                  style: TextStyle(color: textPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _taskCard(_tasks[i]),
              ),
            ),
          ],
        ),
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
                  color: _tab == idx ? Colors.white : textSecondary, fontWeight: FontWeight.w600)),
        ),
      );

  Widget _taskCard(Map task) {
    final done = task['done'] as bool;
    final color = task['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(task['tag'] as String,
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Text(task['time'] as String,
                  style: TextStyle(
                      color: done ? Colors.green : textSecondary,
                      fontSize: 12,
                      fontWeight: done ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2, right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? Colors.green : Colors.transparent,
                  border: done ? null : Border.all(color: color),
                ),
                child: done ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] as String,
                      style: TextStyle(
                        color: done ? textSecondary : textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(task['desc'] as String,
                        style: const TextStyle(color: textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (task['addedBy'] != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const CircleAvatar(radius: 10, backgroundColor: accentPink),
                const SizedBox(width: 6),
                Text(task['addedBy'] as String,
                    style: const TextStyle(color: accentPurple, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
          if (task['tag'] == 'CONNECTION GOAL') ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.3,
                backgroundColor: bgCard2,
                valueColor: AlwaysStoppedAnimation(accentPink),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
