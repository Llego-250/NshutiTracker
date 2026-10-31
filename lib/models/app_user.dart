import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String bio;
  final String? photoUrl;
  final String currentMood;
  final int accentIdx;
  final bool nocturnalMode;
  final String habitType;   // e.g. 'water', 'journal', 'book'
  final int habitGoal;      // daily goal count

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.bio,
    this.photoUrl,
    this.currentMood = 'Dreamy',
    this.accentIdx = 0,
    this.nocturnalMode = true,
    this.habitType = 'water',
    this.habitGoal = 8,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: d['email'] ?? '',
      name: d['name'] ?? '',
      bio: d['bio'] ?? '',
      photoUrl: d['photoUrl'],
      currentMood: d['currentMood'] ?? 'Dreamy',
      accentIdx: d['accentIdx'] ?? 0,
      nocturnalMode: d['nocturnalMode'] ?? true,
      habitType: d['habitType'] ?? 'water',
      habitGoal: d['habitGoal'] ?? 8,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'bio': bio,
        'photoUrl': photoUrl,
        'currentMood': currentMood,
        'accentIdx': accentIdx,
        'nocturnalMode': nocturnalMode,
        'habitType': habitType,
        'habitGoal': habitGoal,
      };

  AppUser copyWith({
    String? name,
    String? bio,
    String? photoUrl,
    String? currentMood,
    int? accentIdx,
    bool? nocturnalMode,
  }) =>
      AppUser(
        uid: uid,
        email: email,
        name: name ?? this.name,
        bio: bio ?? this.bio,
        photoUrl: photoUrl ?? this.photoUrl,
        currentMood: currentMood ?? this.currentMood,
        accentIdx: accentIdx ?? this.accentIdx,
        nocturnalMode: nocturnalMode ?? this.nocturnalMode,
      );
}
