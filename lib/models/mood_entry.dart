import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final String userId;
  final int moodIndex; // 0=LOW 1=BLAH 2=GOOD 3=GREAT 4=LOVED
  final String note;
  final bool isPrivate;
  final DateTime createdAt;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.moodIndex,
    required this.note,
    required this.isPrivate,
    required this.createdAt,
  });

  factory MoodEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      userId: d['userId'] ?? '',
      moodIndex: d['moodIndex'] ?? 2,
      note: d['note'] ?? '',
      isPrivate: d['isPrivate'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'moodIndex': moodIndex,
        'note': note,
        'isPrivate': isPrivate,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
