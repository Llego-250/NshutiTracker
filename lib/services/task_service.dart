import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;

  /// Tasks are stored under a shared bond document keyed by sorted uid pair
  String _bondId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<List<Task>> watchTasks(String myUid, String? partnerId) {
    final bondId = partnerId != null ? _bondId(myUid, partnerId) : myUid;
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('tasks')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(Task.fromDoc).toList());
  }

  Future<void> addTask(String myUid, String? partnerId, Task task) {
    final bondId = partnerId != null ? _bondId(myUid, partnerId) : myUid;
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  Future<void> toggleTask(String myUid, String? partnerId, String taskId, bool done) {
    final bondId = partnerId != null ? _bondId(myUid, partnerId) : myUid;
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('tasks')
        .doc(taskId)
        .update({'done': done});
  }

  Future<void> deleteTask(String myUid, String? partnerId, String taskId) {
    final bondId = partnerId != null ? _bondId(myUid, partnerId) : myUid;
    return _db
        .collection('bonds')
        .doc(bondId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
