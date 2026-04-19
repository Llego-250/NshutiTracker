import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  String _bondId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<List<ChatMessage>> watchMessages(String myUid, String partnerId) {
    final bondId = _bondId(myUid, partnerId);
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(ChatMessage.fromDoc).toList());
  }

  Future<void> sendMessage(String myUid, String partnerId, ChatMessage msg) {
    final bondId = _bondId(myUid, partnerId);
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('messages')
        .doc(msg.id)
        .set(msg.toMap());
  }
}
