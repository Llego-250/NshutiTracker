import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;

  /// Each user's tasks live in users/{uid}/tasks, so only that user can see them.
  CollectionReference<Map<String, dynamic>> _tasks(String uid) =>
      _db.collection('users').doc(uid).collection('tasks');

  Stream<List<Task>> watchTasks(String uid) => _tasks(uid)
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((s) => s.docs.map(Task.fromDoc).toList());

  Future<void> addTask(String uid, Task task) =>
      _tasks(uid).doc(task.id).set(task.toMap());

  Future<void> toggleTask(String uid, String taskId, bool done) =>
      _tasks(uid).doc(taskId).update({'done': done});

  /// Edit a task: only the fields in [data] are changed.
  Future<void> updateTask(String uid, String taskId, Map<String, dynamic> data) =>
      _tasks(uid).doc(taskId).update(data);

  Future<void> deleteTask(String uid, String taskId) =>
      _tasks(uid).doc(taskId).delete();
}
