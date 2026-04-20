import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit_log.dart';

class HabitService {
  final _db = FirebaseFirestore.instance;

  String _todayId(String userId) {
    final now = DateTime.now();
    return '${userId}_${now.year}-${now.month}-${now.day}';
  }

  /// Watch today's habit log for a user
  Stream<HabitLog?> watchTodayLog(String userId) {
    final docId = _todayId(userId);
    return _db
        .collection('habits')
        .doc(docId)
        .snapshots()
        .map((s) => s.exists ? HabitLog.fromDoc(s) : null);
  }

  /// Watch partner's today log (read-only)
  Stream<HabitLog?> watchPartnerLog(String partnerId) =>
      watchTodayLog(partnerId);

  /// Tap the habit — increments count, enforces 5h cooldown
  Future<String> tap(String userId, String habitType, int goal) async {
    final docId = _todayId(userId);
    final ref = _db.collection('habits').doc(docId);
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
        id: docId,
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
