import 'package:flutter/material.dart';
import '../theme.dart';
import 'chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: accentPink,
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: bgCard,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: const ChatScreen(),
          ),
        ),
        child: const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _connectPartnerCard(),
              const SizedBox(height: 20),
              _statsRow(),
              const SizedBox(height: 20),
              _progressCard(),
              const SizedBox(height: 24),
              _milestonesSection(),
              const SizedBox(height: 24),
              _todaysFocus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [accentPurple, accentPink]),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome home,', style: TextStyle(color: textSecondary, fontSize: 14)),
              Text('Solide AZE', style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Your bond is flourishing. Ready to grow together?',
                  style: TextStyle(color: textSecondary, fontSize: 11)),
            ],
          ),
        ],
      );

  Widget _connectPartnerCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.person_add, color: accentPurple, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connect Your Partner', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                  Text('Shared goals are within reach', style: TextStyle(color: textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: textSecondary),
          ],
        ),
      );

  Widget _statsRow() => Row(
        children: [
          _statCard('9', 'TO DO', Icons.list_alt, accentPurple),
          const SizedBox(width: 12),
          _statCard('4', 'PENDING', Icons.pending_actions, accentPink),
          const SizedBox(width: 12),
          _statCard('120', 'DONE', Icons.check_circle_outline, accentBlue),
        ],
      );

  Widget _statCard(String val, String label, IconData icon, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(val, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: textSecondary, fontSize: 10)),
            ],
          ),
        ),
      );

  Widget _progressCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            _progressRow('Shared Plans', 0.68, accentPurple, '68%'),
            const SizedBox(height: 16),
            _progressRow('Overall Progress', 0.84, accentPink, '84%'),
          ],
        ),
      );

  Widget _progressRow(String label, double val, Color color, String pct) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.hub, color: color, size: 16),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
              ]),
              Text(pct, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
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

  Widget _milestonesSection() {
    final milestones = [
      {'icon': '🏆', 'label': 'EARLY BIRD', 'locked': false},
      {'icon': '💝', 'label': 'DEEP CARE', 'locked': false},
      {'icon': '🥇', 'label': 'STREAK 10', 'locked': false},
      {'icon': '✨', 'label': 'RADIANT', 'locked': false},
      {'icon': '🔒', 'label': 'LOCKED', 'locked': true},
    ];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Milestones', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('4 EARNED', style: TextStyle(color: accentPurple, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: milestones.map((m) {
            final locked = m['locked'] as bool;
            return Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: locked ? bgCard : bgCard2,
                    shape: BoxShape.circle,
                    border: locked ? null : Border.all(color: accentPurple.withOpacity(0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(m['icon'] as String, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 6),
                Text(m['label'] as String,
                    style: TextStyle(color: locked ? textSecondary : textPrimary, fontSize: 9)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _todaysFocus() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Focus", style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('VIEW ALL', style: TextStyle(color: accentPurple, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          _focusItem('Evening Breathing', '08:30 PM', '5 min', false, Icons.play_arrow),
          const SizedBox(height: 10),
          _focusItem('Gratitude Note', '10:00 AM', 'One sentence', false, Icons.edit_note),
          const SizedBox(height: 10),
          _focusItemDone('Water Intake Check'),
        ],
      );

  Widget _focusItem(String title, String time, String duration, bool done, IconData action) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: accentPurple),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: accentPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: const Text('PARTNER', style: TextStyle(color: accentPurple, fontSize: 9)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text('$time  •  $duration', style: const TextStyle(color: textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Icon(action, color: accentPurple),
          ],
        ),
      );

  Widget _focusItemDone(String title) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: textSecondary, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w600)),
                  const Text('DAILY GOAL REACHED', style: TextStyle(color: Colors.green, fontSize: 10)),
                ],
              ),
            ),
            const Text('DONE', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
