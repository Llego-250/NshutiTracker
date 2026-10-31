import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';

class MoodService {
  final _db = FirebaseFirestore.instance;

  /// Each user's mood check-ins live in users/{uid}/moods.
  CollectionReference<Map<String, dynamic>> _moods(String uid) =>
      _db.collection('users').doc(uid).collection('moods');

  Future<void> addMood(MoodEntry entry) =>
      _moods(entry.userId).doc(entry.id).set(entry.toMap());

  Stream<List<MoodEntry>> watchMoods(String uid, {int days = 14}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _moods(uid)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(MoodEntry.fromDoc).toList());
  }
}
