import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../theme.dart';
import '../../providers/providers.dart';
import '../../models/habit_log.dart';

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

    // Drop is visible only when canTap (ready for next intake) or never tapped yet
    // It vanishes after tap and reappears when cooldown ends
    final showDrop = canTap;

    // Fill level: full (1.0) when ready to tap, empty (0.0) when just tapped
    // As cooldown progresses minsLeft goes 300→0, so fill = 1 - minsLeft/300
    // But we hide the drop when !canTap, so fill is always 1.0 when visible
    const dropFill = 1.0;

    final emoji = habitIcons[habitType] ?? '💧';

    return AnimatedOpacity(
      opacity: showDrop ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: IgnorePointer(
        ignoring: !showDrop,
        child: GestureDetector(
          onTap: () => _handleTap(context, ref, user?.uid, habitType, goal),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arc showing daily goal progress
                CustomPaint(
                  size: const Size(64, 64),
                  painter: _ArcPainter(
                    progress: dailyProgress,
                    color: isComplete ? Colors.green : accentBlue,
                  ),
                ),
                // Pulsing drop shape
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) {
                    final pulse = 1.0 + _pulseCtrl.value * 0.07;
                    return Transform.scale(
                      scale: pulse,
                      child: CustomPaint(
                        size: const Size(36, 44),
                        painter: _DropPainter(fillLevel: dropFill),
                      ),
                    );
                  },
                ),
                // Emoji
                Text(emoji, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(
      BuildContext context, WidgetRef ref, String? uid, String habitType, int goal) async {
    if (uid == null) return;
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
}

// ── Partner habit progress bar shown on dashboard ─────────────────────────────
class PartnerHabitBar extends ConsumerWidget {
  const PartnerHabitBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final partnerLog = ref.watch(partnerHabitProvider).value;

    if (user == null || user.partnerId == null || partnerLog == null) {
      return const SizedBox();
    }

    final emoji = habitIcons[partnerLog.habitType] ?? '💧';
    final progress = (partnerLog.count / partnerLog.goal).clamp(0.0, 1.0);
    final isComplete = partnerLog.isComplete;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const CircleAvatar(
                radius: 12,
                backgroundColor: accentPink,
                child: Icon(Icons.person, color: Colors.white, size: 12)),
            const SizedBox(width: 8),
            Text(
              '${user.partnerName ?? "Partner"}\'s ${_habitLabel(partnerLog.habitType)}',
              style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ]),
          Text(
            '${partnerLog.count}/${partnerLog.goal} $emoji',
            style: TextStyle(
                color: isComplete ? Colors.green : accentPink,
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: bgCard2,
            valueColor: AlwaysStoppedAnimation(isComplete ? Colors.green : accentPink),
            minHeight: 8,
          ),
        ),
        if (isComplete) ...[
          const SizedBox(height: 6),
          const Text('✅ Daily goal reached!',
              style: TextStyle(color: Colors.green, fontSize: 11)),
        ],
      ]),
    );
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

// ── Drop painter ──────────────────────────────────────────────────────────────
class _DropPainter extends CustomPainter {
  final double fillLevel;
  const _DropPainter({required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w / 2, 0)
      ..cubicTo(w * 0.9, h * 0.4, w, h * 0.65, w / 2, h)
      ..cubicTo(0, h * 0.65, 0, h * 0.4, w / 2, 0)
      ..close();

    // Outline
    canvas.drawPath(
      path,
      Paint()
        ..color = accentBlue.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Fill with wave
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(path);
      final fillTop = h * (1.0 - fillLevel);
      final wavePath = Path()
        ..moveTo(0, fillTop)
        ..quadraticBezierTo(w * 0.25, fillTop - 3, w * 0.5, fillTop)
        ..quadraticBezierTo(w * 0.75, fillTop + 3, w, fillTop)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        wavePath,
        Paint()
          ..color = accentBlue.withOpacity(0.75)
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_DropPainter old) => old.fillLevel != fillLevel;
}

// ── Arc painter ───────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = bgCard2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

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
