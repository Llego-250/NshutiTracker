import 'package:cloud_firestore/cloud_firestore.dart';

class VisionItem {
  final String id;
  final String type; // goal, quote, image, streak
  final String title;
  final String description;
  final String? imageUrl;
  final double? progress;
  final double? targetAmount;
  final double? currentAmount;
  final String createdBy;
  final bool isPartner;
  final DateTime createdAt;

  const VisionItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.imageUrl,
    this.progress,
    this.targetAmount,
    this.currentAmount,
    required this.createdBy,
    required this.isPartner,
    required this.createdAt,
  });

  factory VisionItem.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VisionItem(
      id: doc.id,
      type: d['type'] ?? 'goal',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      imageUrl: d['imageUrl'],
      progress: (d['progress'] as num?)?.toDouble(),
      targetAmount: (d['targetAmount'] as num?)?.toDouble(),
      currentAmount: (d['currentAmount'] as num?)?.toDouble(),
      createdBy: d['createdBy'] ?? '',
      isPartner: d['isPartner'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'progress': progress,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'createdBy': createdBy,
        'isPartner': isPartner,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
