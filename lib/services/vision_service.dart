import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vision_item.dart';

class VisionService {
  final _db = FirebaseFirestore.instance;

  /// Each user's vision board lives in users/{uid}/vision.
  CollectionReference<Map<String, dynamic>> _vision(String uid) =>
      _db.collection('users').doc(uid).collection('vision');

  Stream<List<VisionItem>> watchItems(String uid) => _vision(uid)
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((s) => s.docs.map(VisionItem.fromDoc).toList());

  Future<void> addItem(String uid, VisionItem item) =>
      _vision(uid).doc(item.id).set(item.toMap());

  Future<void> deleteItem(String uid, String itemId) =>
      _vision(uid).doc(itemId).delete();

  Future<void> updateProgress(String uid, String itemId, double progress, double current) =>
      _vision(uid).doc(itemId).update({'progress': progress, 'currentAmount': current});
}
