import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../providers/providers.dart';
import '../models/mood_entry.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});
  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int _selectedMood = 2;
  final _noteCtrl = TextEditingController();

  final _moods = ['😔', '😐', '😊', '😄', '🤩'];
  final _moodLabels = ['LOW', 'BLAH', 'GOOD', 'GREAT', 'AMAZING'];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitMood() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final entry = MoodEntry(
      id: const Uuid().v4(),
      userId: user.uid,
      moodIndex: _selectedMood,
      note: _noteCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await ref.read(moodServiceProvider).addMood(entry);
    _noteCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood checked in! ✨')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myMoodsAsync = ref.watch(myMoodsProvider);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Today's Pulse",
                style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('How are you feeling right now?', style: TextStyle(color: textSecondary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (i) {
                    final sel = _selectedMood == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = i),
                      child: Column(children: [
                        Text(_moods[i], style: TextStyle(fontSize: sel ? 36 : 28)),
                        const SizedBox(height: 4),
                        Text(_moodLabels[i],
                            style: TextStyle(
                                color: sel ? accentPink : textSecondary,
                                fontSize: 10,
                                fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                      ]),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Anything on your mind?',
                      style: TextStyle(color: textSecondary, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: _noteCtrl,
                    style: const TextStyle(color: textPrimary),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write a small note...',
                      hintStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _submitMood,
                  child: Container(
                    width: double.infinity, height: 48,
                    decoration: BoxDecoration(color: accentPurple, borderRadius: BorderRadius.circular(30)),
                    alignment: Alignment.center,
                    child: const Text('Complete Check-In',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            myMoodsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
              error: (_, _) => const SizedBox(),
              data: (myMoods) {
                final positive = myMoods.isEmpty
                    ? 0.0
                    : myMoods.where((m) => m.moodIndex >= 2).length / myMoods.length * 100;
                return Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('LAST 14 DAYS',
                        style: TextStyle(color: textSecondary, fontSize: 11, letterSpacing: 1.5)),
                    Text('${positive.round()}% Positive',
                        style: const TextStyle(color: accentPurple, fontSize: 12)),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                    child: myMoods.isEmpty
                        ? const Center(
                            child: Text('No mood data yet', style: TextStyle(color: textSecondary)))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: myMoods.reversed.take(14).toList().reversed.map((m) {
                              return Container(
                                width: 10,
                                height: (80 * m.moodIndex / 4).clamp(8.0, 80.0),
                                decoration: BoxDecoration(
                                    color: accentPurple.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(3)),
                              );
                            }).toList(),
                          ),
                  ),
                ]);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
