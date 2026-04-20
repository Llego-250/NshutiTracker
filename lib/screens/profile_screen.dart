import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/providers.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/habit_log.dart';
import 'auth_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _moods = [
    {'icon': Icons.sentiment_satisfied_alt, 'label': 'Joyful'},
    {'icon': Icons.cloud, 'label': 'Dreamy'},
    {'icon': Icons.bolt, 'label': 'Calm'},
    {'icon': Icons.self_improvement, 'label': 'Mindful'},
  ];
  final _accents = [accentPink, Colors.green, Colors.amber];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
          error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: accentPink))),
          data: (user) {
            if (user == null) return const SizedBox();
            final moodIdx = _moods.indexWhere((m) => m['label'] == user.currentMood);
            final selectedMood = moodIdx >= 0 ? moodIdx : 1;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Avatar
                Stack(children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: bgCard,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null
                        ? const Icon(Icons.person, size: 60, color: textSecondary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: accentPurple, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 12),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(user.name,
                    style: const TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(user.bio.isEmpty ? 'Tap to add bio' : user.bio,
                      style: const TextStyle(color: accentPurple, fontSize: 13)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _editBio(context, ref, user.uid, user.bio),
                    child: const Icon(Icons.edit, color: textSecondary, size: 14),
                  ),
                ]),
                const SizedBox(height: 24),

                // Mood card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('CURRENT MOOD',
                        style: TextStyle(color: textSecondary, fontSize: 10, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(_moods.length, (i) {
                        final sel = selectedMood == i;
                        return GestureDetector(
                          onTap: () async {
                            await ref.read(userServiceProvider).updateUser(user.uid, {
                              'currentMood': _moods[i]['label'],
                            });
                          },
                          child: Column(children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sel ? accentPurple.withOpacity(0.3) : bgCard2,
                                borderRadius: BorderRadius.circular(12),
                                border: sel ? Border.all(color: accentPurple) : null,
                              ),
                              child: Icon(_moods[i]['icon'] as IconData,
                                  color: sel ? accentPurple : textSecondary, size: 22),
                            ),
                            const SizedBox(height: 6),
                            Text(_moods[i]['label'] as String,
                                style: TextStyle(
                                    color: sel ? accentPurple : textSecondary, fontSize: 11)),
                          ]),
                        );
                      }),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // Bond evolution
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Bond Evolution',
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Milestone: Soul Sync',
                            style: TextStyle(color: textSecondary, fontSize: 12)),
                      ]),
                      SizedBox(
                        width: 56, height: 56,
                        child: Stack(alignment: Alignment.center, children: [
                          const CircularProgressIndicator(
                            value: 0.78,
                            backgroundColor: bgCard2,
                            valueColor: AlwaysStoppedAnimation(accentPink),
                            strokeWidth: 5,
                          ),
                          const Text('78%',
                              style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _levelRow('PERSONAL GROWTH', 0.75, accentPurple, 'LEVEL 12'),
                    const SizedBox(height: 10),
                    _levelRow('SHARED WELLNESS', 0.55, accentPink, 'LEVEL 09'),
                  ]),
                ),
                const SizedBox(height: 16),

                // Habit tracker settings
                _habitSettingsCard(context, ref, user.uid, user.habitType, user.habitGoal),
                const SizedBox(height: 16),

                // Sanctuary style
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Sanctuary Style',
                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Theme Accents', style: TextStyle(color: textSecondary)),
                      Row(
                        children: List.generate(3, (i) => GestureDetector(
                          onTap: () async {
                            await ref.read(userServiceProvider)
                                .updateUser(user.uid, {'accentIdx': i});
                          },
                          child: Container(
                            width: 24, height: 24,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: _accents[i],
                              shape: BoxShape.circle,
                              border: user.accentIdx == i
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                          ),
                        )),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Nocturnal Mode', style: TextStyle(color: textSecondary)),
                      Switch(
                        value: user.nocturnalMode,
                        onChanged: (v) async {
                          await ref.read(userServiceProvider)
                              .updateUser(user.uid, {'nocturnalMode': v});
                        },
                        activeColor: accentPurple,
                      ),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),

                // Partner settings
                if (user.partnerId != null)
                  _actionTile(Icons.link, 'Partner Settings',
                      'Connected with ${user.partnerName ?? "partner"}',
                      trailing: const Icon(Icons.settings, color: textSecondary, size: 18)),
                const SizedBox(height: 10),
                _actionTile(Icons.send, 'Send a Care Note', 'Surprise your partner with a digital hug'),
                const SizedBox(height: 24),

                // Logout
                GestureDetector(
                  onTap: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (_) => false,
                      );
                    }
                  },
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.logout, color: accentPink, size: 18),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: accentPink, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 20),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _habitSettingsCard(BuildContext context, WidgetRef ref, String uid, String habitType, int goal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Daily Habit Tracker',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        const Text('Choose your shared daily habit icon',
            style: TextStyle(color: textSecondary, fontSize: 12)),
        const SizedBox(height: 16),

        // Icon picker
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: habitIcons.entries.map((e) {
            final selected = e.key == habitType;
            return GestureDetector(
              onTap: () => ref.read(habitServiceProvider).updateSettings(uid, e.key, goal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? accentPurple.withOpacity(0.2) : bgCard2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? accentPurple : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(e.value, style: const TextStyle(fontSize: 20)),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Goal slider
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Daily Goal', style: TextStyle(color: textSecondary)),
          Text('$goal times', style: const TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
        ]),
        Slider(
          value: goal.toDouble(),
          min: 1,
          max: 12,
          divisions: 11,
          activeColor: accentPurple,
          inactiveColor: bgCard2,
          label: '$goal',
          onChanged: (v) => ref.read(habitServiceProvider).updateSettings(uid, habitType, v.round()),
        ),
      ]),
    );
  }

  Widget _levelRow(String label, double val, Color color, String level) => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: textSecondary, fontSize: 11)),
          Text(level, style: TextStyle(color: color, fontSize: 11)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            backgroundColor: bgCard2,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ]);

  Widget _actionTile(IconData icon, String title, String subtitle, {Widget? trailing}) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: accentPink.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: accentPink, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(color: textSecondary, fontSize: 12)),
          ])),
          trailing ?? const Icon(Icons.chevron_right, color: textSecondary),
        ]),
      );

  void _editBio(BuildContext context, WidgetRef ref, String uid, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgCard,
        title: const Text('Edit Bio', style: TextStyle(color: textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Your bio...',
            hintStyle: const TextStyle(color: textSecondary),
            filled: true,
            fillColor: bgCard2,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(userServiceProvider).updateUser(uid, {'bio': ctrl.text.trim()});
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: accentPurple)),
          ),
        ],
      ),
    );
  }
}
