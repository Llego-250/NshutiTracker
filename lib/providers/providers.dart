import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/task_service.dart';
import '../services/mood_service.dart';
import '../services/vision_service.dart';
import '../services/habit_service.dart';
import '../models/app_user.dart';
import '../models/task.dart';
import '../models/mood_entry.dart';
import '../models/vision_item.dart';
import '../models/habit_log.dart';

// ── Services ──────────────────────────────────────────────────────────────────
final authServiceProvider = Provider((_) => AuthService());
final userServiceProvider = Provider((_) => UserService());
final taskServiceProvider = Provider((_) => TaskService());
final moodServiceProvider = Provider((_) => MoodService());
final visionServiceProvider = Provider((_) => VisionService());
final habitServiceProvider = Provider((_) => HabitService());

// ── Auth state ────────────────────────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

// ── Current user profile ──────────────────────────────────────────────────────
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(userServiceProvider).watchUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, _) => Stream.value(null),
  );
});

// ── Tasks ─────────────────────────────────────────────────────────────────────
final tasksProvider = StreamProvider<List<Task>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(taskServiceProvider).watchTasks(user.uid);
});

// ── My moods ──────────────────────────────────────────────────────────────────
final myMoodsProvider = StreamProvider<List<MoodEntry>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(moodServiceProvider).watchMoods(user.uid);
});

// ── Vision board ──────────────────────────────────────────────────────────────
final visionProvider = StreamProvider<List<VisionItem>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(visionServiceProvider).watchItems(user.uid);
});

// ── Habit tracker ─────────────────────────────────────────────────────────────
final myHabitProvider = StreamProvider<HabitLog?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(habitServiceProvider).watchTodayLog(user.uid);
});
