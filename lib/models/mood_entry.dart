import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final String userId;
  final int moodIndex; // 0=LOW 1=BLAH 2=GOOD 3=GREAT 4=AMAZING
  final String note;
  final DateTime createdAt;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.moodIndex,
    required this.note,
    required this.createdAt,
  });

  factory MoodEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      userId: d['userId'] ?? '',
      moodIndex: d['moodIndex'] ?? 2,
      note: d['note'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'moodIndex': moodIndex,
        'note': note,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
