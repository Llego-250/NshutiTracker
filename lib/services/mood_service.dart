import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';

class MoodService {
  final _db = FirebaseFirestore.instance;

  Future<void> addMood(MoodEntry entry) => _db
      .collection('moods')
      .doc(entry.userId)
      .collection('entries')
      .doc(entry.id)
      .set(entry.toMap());

  Stream<List<MoodEntry>> watchMoods(String userId, {int days = 14}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection('moods')
        .doc(userId)
        .collection('entries')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(MoodEntry.fromDoc).toList());
  }

  /// Watch partner moods (only non-private entries)
  Stream<List<MoodEntry>> watchPartnerMoods(String partnerId, {int days = 14}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection('moods')
        .doc(partnerId)
        .collection('entries')
        .where('isPrivate', isEqualTo: false)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(MoodEntry.fromDoc).toList());
  }
}
