import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../providers/providers.dart';
import '../models/chat_message.dart';
import '../models/mood_entry.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  int _tab = 0;
  final _msgCtrl = TextEditingController();
  int _selectedMood = 2;
  final _noteCtrl = TextEditingController();
  bool _isPrivate = false;
  bool _sending = false;
  final _scrollCtrl = ScrollController();

  final _moods = ['😔', '😐', '😊', '😄', '💖'];
  final _moodLabels = ['LOW', 'BLAH', 'GOOD', 'GREAT', 'LOVED'];

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null || user.partnerId == null) return;

    setState(() => _sending = true);
    _msgCtrl.clear();
    final msg = ChatMessage(
      id: const Uuid().v4(),
      senderId: user.uid,
      senderName: user.name,
      text: text,
      sentAt: DateTime.now(),
    );
    await ref.read(chatServiceProvider).sendMessage(user.uid, user.partnerId!, msg);
    setState(() => _sending = false);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _submitMood() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final entry = MoodEntry(
      id: const Uuid().v4(),
      userId: user.uid,
      moodIndex: _selectedMood,
      note: _noteCtrl.text.trim(),
      isPrivate: _isPrivate,
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
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(children: [
          _tabBar(),
          Expanded(child: _tab == 0 ? _chatView() : _moodView()),
        ]),
      ),
    );
  }

  Widget _tabBar() => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(30)),
          child: Row(children: [
            _tabBtn('Chat 💬', 0),
            _tabBtn('Mood 🙂', 1),
          ]),
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

  Widget _chatView() {
    final user = ref.watch(currentUserProvider).value;
    final messagesAsync = ref.watch(chatProvider);

    if (user?.partnerId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Connect a partner first to start chatting! 💬',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 14)),
        ),
      );
    }

    return Column(children: [
      Expanded(
        child: messagesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
          error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: accentPink))),
          data: (messages) => ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _promptCard(),
              const SizedBox(height: 16),
              if (messages.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No messages yet. Say hello! 👋',
                        style: TextStyle(color: textSecondary)),
                  ),
                )
              else
                ...messages.map((m) => _messageBubble(m, user!.uid)),
            ],
          ),
        ),
      ),
      _reactionBar(),
      _inputBar(),
    ]);
  }

  Widget _promptCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [accentPink.withOpacity(0.2), accentPurple.withOpacity(0.2)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentPink.withOpacity(0.3)),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DAILY CONNECTION PROMPT',
              style: TextStyle(color: accentPink, fontSize: 10, letterSpacing: 1.5)),
          SizedBox(height: 8),
          Text('"What\'s one thing your partner did this week that made you feel truly seen?"',
              style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Answer together →', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
        ]),
      );

  Widget _messageBubble(ChatMessage msg, String myUid) {
    final mine = msg.senderId == myUid;
    final time = DateFormat('hh:mm a').format(msg.sentAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text('${mine ? 'You' : msg.senderName} • $time',
              style: const TextStyle(color: textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: mine ? accentPurple.withOpacity(0.3) : bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(msg.text, style: const TextStyle(color: textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _reactionBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: ['❤️', '✨', '👥', '🔥'].map((e) => Container(
            margin: const EdgeInsets.only(right: 8),
            width: 36, height: 36,
            decoration: BoxDecoration(color: bgCard, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                _msgCtrl.text += e;
              },
              child: Text(e, style: const TextStyle(fontSize: 16)),
            ),
          )).toList(),
        ),
      );

  Widget _inputBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(children: [
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
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: accentPurple, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ]),
      );

  Widget _moodView() {
    final myMoodsAsync = ref.watch(myMoodsProvider);
    final partnerMoodsAsync = ref.watch(partnerMoodsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Today's Pulse",
                style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('How are you feeling right now?', style: TextStyle(color: textSecondary)),
          ]),
          Container(width: 36, height: 36,
              decoration: const BoxDecoration(color: accentPink, shape: BoxShape.circle)),
        ]),
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
              child: Text('Any thoughts you\'d like to share?',
                  style: TextStyle(color: textSecondary, fontSize: 13)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                TextField(
                  controller: _noteCtrl,
                  style: const TextStyle(color: textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write a small note...',
                    hintStyle: TextStyle(color: textSecondary),
                    border: InputBorder.none,
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  GestureDetector(
                    onTap: () => setState(() => _isPrivate = !_isPrivate),
                    child: Row(children: [
                      Icon(_isPrivate ? Icons.lock : Icons.lock_open,
                          color: _isPrivate ? accentPurple : textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(_isPrivate ? 'PRIVATE' : 'SHARED',
                          style: TextStyle(
                              color: _isPrivate ? accentPurple : textSecondary, fontSize: 10)),
                    ]),
                  ),
                ]),
              ]),
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
          data: (myMoods) => partnerMoodsAsync.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (partnerMoods) {
              final positiveSync = myMoods.isEmpty
                  ? 0.0
                  : myMoods.where((m) => m.moodIndex >= 2).length / myMoods.length * 100;
              return Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('LAST 14 DAYS',
                      style: TextStyle(color: textSecondary, fontSize: 11, letterSpacing: 1.5)),
                  Text('${positiveSync.round()}% Positive Sync',
                      style: const TextStyle(color: accentPurple, fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                  child: myMoods.isEmpty
                      ? const Center(child: Text('No mood data yet', style: TextStyle(color: textSecondary)))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            myMoods.length.clamp(0, 14),
                            (i) {
                              final my = myMoods[i].moodIndex / 4;
                              final partner = i < partnerMoods.length
                                  ? partnerMoods[i].moodIndex / 4
                                  : 0.0;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 6,
                                    height: (80 * my).clamp(8.0, 80.0),
                                    decoration: BoxDecoration(
                                        color: accentPurple.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(3)),
                                  ),
                                  const SizedBox(width: 2),
                                  Container(
                                    width: 6,
                                    height: (80 * partner).clamp(8.0, 80.0),
                                    decoration: BoxDecoration(
                                        color: accentPink.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(3)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}
