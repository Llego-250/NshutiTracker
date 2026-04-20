import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/providers.dart';
import '../models/habit_log.dart';

class HabitTrackerWidget extends ConsumerWidget {
  const HabitTrackerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final myLog = ref.watch(myHabitProvider).value;
    final partnerLog = ref.watch(partnerHabitProvider).value;

    if (user == null) return const SizedBox();

    final habitType = user.habitType;
    final goal = user.habitGoal;
    final emoji = habitIcons[habitType] ?? '💧';
    final count = myLog?.count ?? 0;
    final progress = myLog?.progress ?? 0.0;
    final canTap = myLog?.canTap ?? true;
    final isComplete = myLog?.isComplete ?? false;
    final minsLeft = myLog?.minutesUntilNextTap() ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_habitLabel(habitType),
                  style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$count / $goal today',
                  style: const TextStyle(color: textSecondary, fontSize: 12)),
            ]),
            if (partnerLog != null)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('PARTNER', style: TextStyle(color: accentPink, fontSize: 9, letterSpacing: 1)),
                Text('${partnerLog.count}/${partnerLog.goal} $emoji',
                    style: const TextStyle(color: textSecondary, fontSize: 12)),
                if (partnerLog.isComplete)
                  const Text('✅ Done!', style: TextStyle(color: Colors.green, fontSize: 10)),
              ]),
          ]),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: bgCard2,
              valueColor: AlwaysStoppedAnimation(isComplete ? Colors.green : accentBlue),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // Tap icons grid
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(goal, (i) {
              final filled = i < count;
              return GestureDetector(
                onTap: filled || isComplete || !canTap
                    ? null
                    : () => _onTap(context, ref, user.uid, habitType, goal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: filled ? accentBlue.withOpacity(0.2) : bgCard2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: filled ? accentBlue : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 16,
                      color: filled ? null : const Color(0xFF3A3D50),
                    ),
                  ),
                ),
              );
            }),
          ),

          if (!canTap && !isComplete) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.timer_outlined, color: textSecondary, size: 14),
              const SizedBox(width: 4),
              Text('Next in ${minsLeft ~/ 60}h ${minsLeft % 60}m',
                  style: const TextStyle(color: textSecondary, fontSize: 11)),
            ]),
          ],

          if (isComplete) ...[
            const SizedBox(height: 10),
            const Row(children: [
              Icon(Icons.check_circle, color: Colors.green, size: 14),
              SizedBox(width: 4),
              Text('Daily goal reached! 🎉', style: TextStyle(color: Colors.green, fontSize: 11)),
            ]),
          ],
        ],
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref, String uid, String habitType, int goal) async {
    final msg = await ref.read(habitServiceProvider).tap(uid, habitType, goal);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: bgCard2,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  String _habitLabel(String type) => const {
        'water':    'Water Intake',
        'heart':    'Love Check-In',
        'food':     'Healthy Meals',
        'book':     'Reading',
        'exercise': 'Exercise',
        'sleep':    'Sleep',
        'meditate': 'Meditation',
        'vitamin':  'Vitamins',
      }[type] ?? 'Daily Habit';
}
