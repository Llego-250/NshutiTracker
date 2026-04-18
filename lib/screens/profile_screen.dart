import 'package:flutter/material.dart';
import '../theme.dart';
import '../screens/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedMood = 1;
  bool _nocturnal = true;
  int _accentIdx = 0;

  final _moods = [
    {'icon': Icons.sentiment_satisfied_alt, 'label': 'Joyful'},
    {'icon': Icons.cloud, 'label': 'Dreamy'},
    {'icon': Icons.bolt, 'label': 'Calm'},
    {'icon': Icons.self_improvement, 'label': 'Mindful'},
  ];

  final _accents = [accentPink, Colors.green, Colors.amber];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _profileHeader(),
              const SizedBox(height: 24),
              _moodCard(),
              const SizedBox(height: 16),
              _bondEvolution(),
              const SizedBox(height: 16),
              _moodJourney(),
              const SizedBox(height: 16),
              _sanctuaryStyle(),
              const SizedBox(height: 16),
              _actionTile(Icons.send, 'Send a Care Note', 'Surprise Liam with a digital hug'),
              const SizedBox(height: 10),
              _actionTile(Icons.link, 'Partner Settings', 'Connected with Liam J.', trailing: const Icon(Icons.settings, color: textSecondary, size: 18)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: accentPink, size: 18),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: accentPink, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() => Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: bgCard,
                child: Icon(Icons.person, size: 60, color: textSecondary),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: accentPurple, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Solide Aze',
              style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('99 ', style: TextStyle(color: textSecondary, fontSize: 12)),
              const Text('Deepening roots, growing light.',
                  style: TextStyle(color: accentPurple, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.edit, color: textSecondary, size: 14),
            ],
          ),
        ],
      );

  Widget _moodCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CURRENT MOOD',
                style: TextStyle(color: textSecondary, fontSize: 10, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_moods.length, (i) {
                final sel = _selectedMood == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = i),
                  child: Column(
                    children: [
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
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );

  Widget _bondEvolution() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bond Evolution',
                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Milestone: Soul Sync', style: TextStyle(color: textSecondary, fontSize: 12)),
                  ],
                ),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.78,
                        backgroundColor: bgCard2,
                        valueColor: const AlwaysStoppedAnimation(accentPink),
                        strokeWidth: 5,
                      ),
                      const Text('78%', style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _levelRow('PERSONAL GROWTH', 0.75, accentPurple, 'LEVEL 12'),
            const SizedBox(height: 10),
            _levelRow('SHARED WELLNESS', 0.55, accentPink, 'LEVEL 09'),
          ],
        ),
      );

  Widget _levelRow(String label, double val, Color color, String level) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: textSecondary, fontSize: 11)),
              Text(level, style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
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
        ],
      );

  Widget _moodJourney() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mood Journey',
                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Last 7 Days', style: TextStyle(color: accentPurple, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final h = (0.3 + (i % 4) * 0.18).clamp(0.2, 1.0);
                  return Container(
                    width: 28,
                    height: 80 * h,
                    decoration: BoxDecoration(
                      color: accentPurple.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _journeyIcon(Icons.alarm, true),
                _journeyIcon(Icons.star_border, false),
                _journeyIcon(Icons.favorite_border, false),
                _journeyIcon(Icons.diamond_outlined, false),
              ],
            ),
          ],
        ),
      );

  Widget _journeyIcon(IconData icon, bool active) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? accentPink.withOpacity(0.2) : bgCard2,
          shape: BoxShape.circle,
          border: active ? Border.all(color: accentPink) : null,
        ),
        child: Icon(icon, color: active ? accentPink : textSecondary, size: 18),
      );

  Widget _sanctuaryStyle() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sanctuary Style',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Theme Accents', style: TextStyle(color: textSecondary)),
                Row(
                  children: List.generate(3, (i) => GestureDetector(
                    onTap: () => setState(() => _accentIdx = i),
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: _accents[i],
                        shape: BoxShape.circle,
                        border: _accentIdx == i ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                    ),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nocturnal Mode', style: TextStyle(color: textSecondary)),
                Switch(
                  value: _nocturnal,
                  onChanged: (v) => setState(() => _nocturnal = v),
                  activeColor: accentPurple,
                ),
              ],
            ),
          ],
        ),
      );

  Widget _actionTile(IconData icon, String title, String subtitle, {Widget? trailing}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: accentPink.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: accentPink, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(color: textSecondary, fontSize: 12)),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: textSecondary),
          ],
        ),
      );
}
