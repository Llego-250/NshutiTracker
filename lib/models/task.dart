import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String tag; // PERSONAL, PARTNER'S, CONNECTION GOAL
  final String time;
  final bool done;
  final String createdBy;
  final String? addedByName;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.time,
    required this.done,
    required this.createdBy,
    this.addedByName,
    required this.createdAt,
  });

  factory Task.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      tag: d['tag'] ?? 'PERSONAL',
      time: d['time'] ?? '',
      done: d['done'] ?? false,
      createdBy: d['createdBy'] ?? '',
      addedByName: d['addedByName'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'tag': tag,
        'time': time,
        'done': done,
        'createdBy': createdBy,
        'addedByName': addedByName,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  Task copyWith({bool? done}) => Task(
        id: id,
        title: title,
        description: description,
        tag: tag,
        time: time,
        done: done ?? this.done,
        createdBy: createdBy,
        addedByName: addedByName,
        createdAt: createdAt,
      );
}
