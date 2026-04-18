import 'package:flutter/material.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _tab = 0;
  final _msgCtrl = TextEditingController();
  int _selectedMood = 2;

  final _messages = [
    {'from': 'Maya', 'time': '10:24 AM', 'text': "I'm feeling really grateful for our morning coffee today. It felt so peaceful before the work rush. 🕯️❤️", 'mine': false},
    {'from': 'You', 'time': '10:28 AM', 'text': "Me too. Let's make it a ritual every Tuesday? I really needed that stillness.", 'mine': true},
  ];

  final _moods = ['😔', '😐', '😊', '😄', '💖'];
  final _moodLabels = ['LOW', 'BLAH', 'GOOD', 'GREAT', 'LOVED'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _tabBar(),
            Expanded(child: _tab == 0 ? _chatView() : _moodView()),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: [
              _tabBtn('Chat 💬', 0),
              _tabBtn('Mood 🙂', 1),
            ],
          ),
        ),
      );

  Widget _tabBtn(String label, int idx) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = idx),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _tab == idx ? bgCard2 : Colors.transparent,
              borderRadius: BorderRadius.circular(26),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    color: _tab == idx ? textPrimary : textSecondary,
                    fontWeight: _tab == idx ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
      );

  Widget _chatView() => Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _promptCard(),
                const SizedBox(height: 16),
                ..._messages.map((m) => _messageBubble(m)),
              ],
            ),
          ),
          _reactionBar(),
          _inputBar(),
        ],
      );

  Widget _promptCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentPink.withOpacity(0.2), accentPurple.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentPink.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DAILY CONNECTION PROMPT',
                style: TextStyle(color: accentPink, fontSize: 10, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            const Text('"What\'s one thing your partner did this week that made you feel truly seen?"',
                style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Answer together →', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _messageBubble(Map msg) {
    final mine = msg['mine'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text('${msg['from']} • ${msg['time']}',
              style: const TextStyle(color: textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: mine ? accentPurple.withOpacity(0.3) : bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(msg['text'] as String, style: const TextStyle(color: textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _reactionBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: ['❤️', '✨', '👥', '🔥'].map((e) => _reactionBtn(e)).toList()
            ..add(Container(
              margin: const EdgeInsets.only(left: 8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: bgCard, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: textSecondary, size: 18),
            )),
        ),
      );

  Widget _reactionBtn(String emoji) => Container(
        margin: const EdgeInsets.only(right: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bgCard, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      );

  Widget _inputBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: _msgCtrl,
                  style: const TextStyle(color: textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Type your message here ...',
                    hintStyle: TextStyle(color: textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: accentPurple, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ],
        ),
      );

  Widget _moodView() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Pulse",
                        style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('How are you feeling right now?', style: TextStyle(color: textSecondary)),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: accentPink, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (i) {
                      final selected = _selectedMood == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = i),
                        child: Column(
                          children: [
                            Text(_moods[i],
                                style: TextStyle(fontSize: selected ? 36 : 28)),
                            const SizedBox(height: 4),
                            Text(_moodLabels[i],
                                style: TextStyle(
                                    color: selected ? accentPink : textSecondary,
                                    fontSize: 10,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Any thoughts you\'d like to share?',
                        style: TextStyle(color: textSecondary, fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        const TextField(
                          style: TextStyle(color: textPrimary),
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Write a small note...',
                            hintStyle: TextStyle(color: textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline, color: textSecondary, size: 12),
                              SizedBox(width: 4),
                              Text('PRIVATE', style: TextStyle(color: textSecondary, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(color: accentPurple, borderRadius: BorderRadius.circular(30)),
                    alignment: Alignment.center,
                    child: const Text('Complete Check-In',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LAST 14 DAYS',
                    style: TextStyle(color: textSecondary, fontSize: 11, letterSpacing: 1.5)),
                const Text('82% Positive Sync', style: TextStyle(color: accentPurple, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(14, (i) {
                  final h1 = (0.3 + (i % 5) * 0.15).clamp(0.2, 1.0);
                  final h2 = (0.4 + (i % 4) * 0.12).clamp(0.2, 1.0);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 6,
                            height: 80 * h1,
                            decoration: BoxDecoration(
                              color: accentPurple.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            width: 6,
                            height: 80 * h2,
                            decoration: BoxDecoration(
                              color: accentPink.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      );
}
