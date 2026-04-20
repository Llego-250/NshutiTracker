import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Stream<AppUser> watchUser(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((s) => AppUser.fromDoc(s));

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).update(data);

  /// Connect two users as partners
  Future<void> connectPartner(String myUid, String partnerEmail) async {
    final query = await _db
        .collection('users')
        .where('email', isEqualTo: partnerEmail)
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception('This email is not registered on NshutiTrack. Ask your partner to sign up first.');

    final partnerDoc = query.docs.first;
    final partnerId = partnerDoc.id;

    if (partnerId == myUid) throw Exception('You cannot connect with yourself.');

    final partnerData = partnerDoc.data();
    if (partnerData['partnerId'] != null && partnerData['partnerId'] != myUid) {
      throw Exception('This person is already bonded with someone else.');
    }
    final partnerName = (partnerDoc.data())['name'] ?? partnerEmail;
    final since = DateTime.now().toIso8601String().substring(0, 10);

    final myDoc = await _db.collection('users').doc(myUid).get();
    final myName = (myDoc.data() as Map)['name'] ?? '';

    // Link both users to each other
    await Future.wait([
      _db.collection('users').doc(myUid).update({
        'partnerId': partnerId,
        'partnerName': partnerName,
        'partnerSince': since,
      }),
      _db.collection('users').doc(partnerId).update({
        'partnerId': myUid,
        'partnerName': myName,
        'partnerSince': since,
      }),
    ]);
  }

  Future<void> disconnectPartner(String myUid, String partnerId) async {
    await Future.wait([
      _db.collection('users').doc(myUid).update({
        'partnerId': null,
        'partnerName': null,
        'partnerSince': null,
      }),
      _db.collection('users').doc(partnerId).update({
        'partnerId': null,
        'partnerName': null,
        'partnerSince': null,
      }),
    ]);
  }
}
