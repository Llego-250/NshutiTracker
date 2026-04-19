import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vision_item.dart';

class VisionService {
  final _db = FirebaseFirestore.instance;

  String _bondId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<List<VisionItem>> watchItems(String myUid, String? partnerId) {
    final bondId = partnerId != null ? _bondId(myUid, partnerId) : myUid;
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('vision')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(VisionItem.fromDoc).toList());
  }

  Future<void> addItem(String myUid, String? partnerId, VisionItem item) {
    final bondId = partnerId != null ? _bondId(myUid, partnerId) : myUid;
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('vision')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> deleteItem(String myUid, String? partnerId, String itemId) {
    final bondId = partnerId != null ? _bondId(myUid, partnerId) : myUid;
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('vision')
        .doc(itemId)
        .delete();
  }

  Future<void> updateProgress(
      String myUid, String? partnerId, String itemId, double progress, double current) {
    final bondId = partnerId != null ? _bondId(myUid, partnerId) : myUid;
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('vision')
        .doc(itemId)
        .update({'progress': progress, 'currentAmount': current});
  }
}
