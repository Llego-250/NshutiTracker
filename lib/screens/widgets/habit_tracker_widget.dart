import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../theme.dart';
import '../../providers/providers.dart';
import '../../models/habit_log.dart';

// ── FAB drop button shown above nav bar ───────────────────────────────────────
class HabitFabButton extends ConsumerStatefulWidget {
  const HabitFabButton({super.key});
  @override
  ConsumerState<HabitFabButton> createState() => _HabitFabButtonState();
}

class _HabitFabButtonState extends ConsumerState<HabitFabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final myLog = ref.watch(myHabitProvider).value;

    final habitType = user?.habitType ?? 'water';
    final goal = user?.habitGoal ?? 8;
    final count = myLog?.count ?? 0;
    final canTap = myLog?.canTap ?? true;
    final isComplete = myLog?.isComplete ?? false;
    final minsLeft = myLog?.minutesUntilNextTap() ?? 0;
    final dailyProgress = goal > 0 ? (count / goal).clamp(0.0, 1.0) : 0.0;

    // Cooldown fill: 1.0 = just tapped (full blue), fades to 0.0 over 5h
    final cooldownFill = canTap ? 0.0 : (1.0 - (minsLeft / 300.0)).clamp(0.0, 1.0);
    // After tap it's full, then fades — we want fill = 1 right after tap, 0 when cooldown done
    final dropFill = canTap && count > 0 ? 0.0 : (!canTap ? (minsLeft / 300.0) : 0.0);

    final emoji = habitIcons[habitType] ?? '💧';

    return GestureDetector(
      onTap: () => _handleTap(context, ref, user?.uid, habitType, goal, canTap, isComplete),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer progress arc (daily goal)
            CustomPaint(
              size: const Size(64, 64),
              painter: _ArcPainter(progress: dailyProgress, color: isComplete ? Colors.green : accentBlue),
            ),
            // Drop shape
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                final pulse = canTap && count == 0
                    ? 1.0 + _pulseCtrl.value * 0.06
                    : 1.0;
                return Transform.scale(
                  scale: pulse,
                  child: CustomPaint(
                    size: const Size(40, 48),
                    painter: _DropPainter(
                      fillLevel: isComplete ? 1.0 : dropFill,
                      isEmpty: count == 0,
                      isComplete: isComplete,
                    ),
                  ),
                );
              },
            ),
            // Emoji / icon inside drop
            Text(
              isComplete ? '✅' : emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    String? uid,
    String habitType,
    int goal,
    bool canTap,
    bool isComplete,
  ) async {
    if (uid == null) return;

    if (!canTap && !isComplete) {
      // Show detail sheet
      _showDetailSheet(context, ref);
      return;
    }

    if (isComplete) {
      _showDetailSheet(context, ref);
      return;
    }

    final msg = await ref.read(habitServiceProvider).tap(uid, habitType, goal);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: bgCard2,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _HabitDetailSheet(),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────
class _HabitDetailSheet extends ConsumerWidget {
  const _HabitDetailSheet();

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
    final canTap = myLog?.canTap ?? true;
    final isComplete = myLog?.isComplete ?? false;
    final minsLeft = myLog?.minutesUntilNextTap() ?? 0;
    final progress = goal > 0 ? (count / goal).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // Title row
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_habitLabel(habitType),
                  style: const TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('$count of $goal $emoji today',
                  style: const TextStyle(color: textSecondary, fontSize: 13)),
            ]),
            Text('$emoji', style: const TextStyle(fontSize: 32)),
          ]),
          const SizedBox(height: 20),

          // Progress bar
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: bgCard2,
                  valueColor: AlwaysStoppedAnimation(isComplete ? Colors.green : accentBlue),
                  minHeight: 10,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('${(progress * 100).round()}%',
                style: TextStyle(
                    color: isComplete ? Colors.green : accentBlue,
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),

          // Drop icons grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(goal, (i) {
              final filled = i < count;
              // Cooldown fade for the last filled drop
              final isLastFilled = filled && i == count - 1 && !canTap;
              final fadeFraction = isLastFilled ? (minsLeft / 300.0).clamp(0.0, 1.0) : 1.0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: filled
                      ? accentBlue.withOpacity(0.15 + 0.65 * fadeFraction)
                      : bgCard2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: filled ? accentBlue.withOpacity(fadeFraction) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 18,
                    color: filled ? null : const Color(0xFF2A2D3E),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Status row
          if (!canTap && !isComplete)
            _statusRow(Icons.timer_outlined, accentBlue,
                'Next intake in ${minsLeft ~/ 60}h ${minsLeft % 60}m'),
          if (isComplete)
            _statusRow(Icons.check_circle, Colors.green, 'Daily goal reached! 🎉'),
          if (canTap && !isComplete)
            _statusRow(Icons.water_drop, accentBlue, 'Tap the drop to log an intake!'),

          // Partner status
          if (partnerLog != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const CircleAvatar(radius: 14, backgroundColor: accentPink,
                    child: Icon(Icons.person, color: Colors.white, size: 14)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${user.partnerName ?? "Partner"}\'s progress',
                      style: const TextStyle(color: textSecondary, fontSize: 11)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (partnerLog.count / partnerLog.goal).clamp(0.0, 1.0),
                      backgroundColor: bgDark,
                      valueColor: AlwaysStoppedAnimation(
                          partnerLog.isComplete ? Colors.green : accentPink),
                      minHeight: 6,
                    ),
                  ),
                ])),
                const SizedBox(width: 10),
                Text('${partnerLog.count}/${partnerLog.goal}',
                    style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statusRow(IconData icon, Color color, String text) => Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]);

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

// ── Drop shape painter ────────────────────────────────────────────────────────
class _DropPainter extends CustomPainter {
  final double fillLevel; // 0.0 = empty, 1.0 = full
  final bool isEmpty;
  final bool isComplete;

  const _DropPainter({
    required this.fillLevel,
    required this.isEmpty,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop path
    final path = Path()
      ..moveTo(w / 2, 0)
      ..cubicTo(w * 0.9, h * 0.4, w, h * 0.65, w / 2, h)
      ..cubicTo(0, h * 0.65, 0, h * 0.4, w / 2, 0)
      ..close();

    // Outline
    final outlinePaint = Paint()
      ..color = isEmpty
          ? const Color(0xFF2A3A4A)
          : (isComplete ? Colors.green : accentBlue).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, outlinePaint);

    if (fillLevel > 0) {
      // Clip to drop shape then draw fill
      canvas.save();
      canvas.clipPath(path);

      final fillTop = h * (1.0 - fillLevel);
      final fillPaint = Paint()
        ..color = isComplete
            ? Colors.green.withOpacity(0.7)
            : accentBlue.withOpacity(0.3 + 0.5 * fillLevel)
        ..style = PaintingStyle.fill;

      // Wave effect at the fill surface
      final wavePath = Path()
        ..moveTo(0, fillTop)
        ..quadraticBezierTo(w * 0.25, fillTop - 4, w * 0.5, fillTop)
        ..quadraticBezierTo(w * 0.75, fillTop + 4, w, fillTop)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();

      canvas.drawPath(wavePath, fillPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_DropPainter old) =>
      old.fillLevel != fillLevel || old.isEmpty != isEmpty || old.isComplete != isComplete;
}

// ── Arc progress painter ──────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background track
    canvas.drawCircle(center, radius,
        Paint()
          ..color = bgCard2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress || old.color != color;
}
