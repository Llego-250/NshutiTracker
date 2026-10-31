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
}
