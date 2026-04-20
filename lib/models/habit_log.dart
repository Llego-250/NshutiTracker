import 'package:cloud_firestore/cloud_firestore.dart';

// Available habit icons the couple can choose from
const habitIcons = {
  'water':    '💧',
  'heart':    '❤️',
  'food':     '🍎',
  'book':     '📖',
  'exercise': '🏃',
  'sleep':    '😴',
  'meditate': '🧘',
  'vitamin':  '💊',
};

class HabitLog {
  final String id;
  final String userId;
  final String habitType;   // key from habitIcons
  final int count;          // glasses / times tapped today
  final int goal;           // daily goal (e.g. 8 glasses)
  final DateTime date;      // day this log belongs to
  final DateTime lastTap;   // last time user tapped

  const HabitLog({
    required this.id,
    required this.userId,
    required this.habitType,
    required this.count,
    required this.goal,
    required this.date,
    required this.lastTap,
  });

  factory HabitLog.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return HabitLog(
      id: doc.id,
      userId: d['userId'] ?? '',
      habitType: d['habitType'] ?? 'water',
      count: d['count'] ?? 0,
      goal: d['goal'] ?? 8,
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastTap: (d['lastTap'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'habitType': habitType,
        'count': count,
        'goal': goal,
        'date': Timestamp.fromDate(date),
        'lastTap': Timestamp.fromDate(lastTap),
      };

  // Minutes remaining before next tap is allowed (cooldown = 5 hours = 300 min)
  int minutesUntilNextTap() {
    final diff = DateTime.now().difference(lastTap).inMinutes;
    final remaining = 300 - diff;
    return remaining > 0 ? remaining : 0;
  }

  bool get canTap => minutesUntilNextTap() == 0;
  bool get isComplete => count >= goal;
  double get progress => (count / goal).clamp(0.0, 1.0);

  HabitLog copyWith({int? count, DateTime? lastTap}) => HabitLog(
        id: id,
        userId: userId,
        habitType: habitType,
        count: count ?? this.count,
        goal: goal,
        date: date,
        lastTap: lastTap ?? this.lastTap,
      );
}
