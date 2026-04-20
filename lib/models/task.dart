import 'package:cloud_firestore/cloud_firestore.dart';

class SubTask {
  final String title;
  bool done;
  SubTask({required this.title, this.done = false});

  factory SubTask.fromMap(Map<String, dynamic> m) =>
      SubTask(title: m['title'] ?? '', done: m['done'] ?? false);
  Map<String, dynamic> toMap() => {'title': title, 'done': done};
}

class Task {
  final String id;
  final String title;
  final String description;
  final String tag;
  final String time;
  final bool done;
  final String createdBy;
  final String? addedByName;
  final DateTime createdAt;
  final String? location;
  final String? meetingLink;
  final String priority; // High Medium Low None
  final bool notification;
  final String repeat;   // None Daily Weekly Monthly
  final List<SubTask> subtasks;
  final String? imageUrl;

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
    this.location,
    this.meetingLink,
    this.priority = 'None',
    this.notification = false,
    this.repeat = 'None',
    this.subtasks = const [],
    this.imageUrl,
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
      location: d['location'],
      meetingLink: d['meetingLink'],
      priority: d['priority'] ?? 'None',
      notification: d['notification'] ?? false,
      repeat: d['repeat'] ?? 'None',
      subtasks: (d['subtasks'] as List<dynamic>? ?? [])
          .map((e) => SubTask.fromMap(e as Map<String, dynamic>))
          .toList(),
      imageUrl: d['imageUrl'],
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
        'location': location,
        'meetingLink': meetingLink,
        'priority': priority,
        'notification': notification,
        'repeat': repeat,
        'subtasks': subtasks.map((s) => s.toMap()).toList(),
        'imageUrl': imageUrl,
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
        location: location,
        meetingLink: meetingLink,
        priority: priority,
        notification: notification,
        repeat: repeat,
        subtasks: subtasks,
        imageUrl: imageUrl,
      );
}
