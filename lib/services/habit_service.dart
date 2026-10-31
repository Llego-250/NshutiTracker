import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit_log.dart';

class HabitService {
  final _db = FirebaseFirestore.instance;

  /// Each user's daily habit logs live in users/{uid}/habits/{yyyy-m-d}.
  DocumentReference<Map<String, dynamic>> _todayDoc(String userId) {
    final now = DateTime.now();
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc('${now.year}-${now.month}-${now.day}');
  }

  /// Watch today's habit log for a user
  Stream<HabitLog?> watchTodayLog(String userId) => _todayDoc(userId)
      .snapshots()
      .map((s) => s.exists ? HabitLog.fromDoc(s) : null);

  /// Tap the habit — increments count, enforces 5h cooldown
  Future<String> tap(String userId, String habitType, int goal) async {
    final ref = _todayDoc(userId);
    final snap = await ref.get();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (snap.exists) {
      final log = HabitLog.fromDoc(snap);
      if (!log.canTap) {
        final mins = log.minutesUntilNextTap();
        final h = mins ~/ 60;
        final m = mins % 60;
        return h > 0 ? 'Next tap in ${h}h ${m}m' : 'Next tap in ${m}m';
      }
      if (log.isComplete) return 'Daily goal reached! 🎉';
      await ref.update({
        'count': log.count + 1,
        'lastTap': Timestamp.fromDate(now),
      });
      return log.count + 1 >= goal ? 'Goal reached! 🎉' : '+1 logged!';
    } else {
      // First tap of the day
      final log = HabitLog(
        id: ref.id,
        userId: userId,
        habitType: habitType,
        count: 1,
        goal: goal,
        date: today,
        lastTap: now,
      );
      await ref.set(log.toMap());
      return '+1 logged!';
    }
  }

  /// Update habit settings (type + goal) for a user
  Future<void> updateSettings(String userId, String habitType, int goal) =>
      _db.collection('users').doc(userId).update({
        'habitType': habitType,
        'habitGoal': goal,
      });
}
