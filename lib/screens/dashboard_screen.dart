import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/providers.dart';
import '../services/user_service.dart';
import 'widgets/habit_tracker_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  void _showConnectPartner(BuildContext context, String uid) {
    final emailCtrl = TextEditingController();
    bool loading = false;
    String? error;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Connect Your Partner',
                  style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Enter your partner\'s email address to link your bond.',
                  style: TextStyle(color: textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'partner@email.com',
                  hintStyle: const TextStyle(color: textSecondary),
                  prefixIcon: const Icon(Icons.email_outlined, color: textSecondary, size: 18),
                  filled: true,
                  fillColor: bgCard2,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: accentPink, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: btnGradient,
                      borderRadius: BorderRadius.circular(14)),
                  child: TextButton(
                    onPressed: loading
                        ? null
                        : () async {
                            final email = emailCtrl.text.trim();
                            if (email.isEmpty) {
                              setModal(() => error = 'Please enter an email.');
                              return;
                            }
                            setModal(() { loading = true; error = null; });
                            try {
                              await ref.read(userServiceProvider).connectPartner(uid, email);
                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              setModal(() {
                                loading = false;
                                error = e.toString().replaceAll('Exception: ', '');
                              });
                            }
                          },
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Connect 💖',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
          error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: accentPink))),
          data: (user) {
            if (user == null) return const SizedBox();
            final tasks = tasksAsync.value ?? [];
            final todo = tasks.where((t) => !t.done).length;
            final done = tasks.where((t) => t.done).length;
            final todayTasks = tasks.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [accentPurple, accentPink]),
                      ),
                      child: user.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(user.photoUrl!, fit: BoxFit.cover))
                          : const Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome home,', style: TextStyle(color: textSecondary, fontSize: 14)),
                        Text(user.name, style: const TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text('Your bond is flourishing. Ready to grow together?',
                            style: TextStyle(color: textSecondary, fontSize: 11)),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 20),

                  // Connect partner card
                  if (user.partnerId == null)
                    GestureDetector(
                      onTap: () => _showConnectPartner(context, user.uid),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.person_add, color: accentPurple, size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Connect Your Partner', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                              Text('Shared goals are within reach', style: TextStyle(color: textSecondary, fontSize: 12)),
                            ],
                          )),
                          const Icon(Icons.chevron_right, color: textSecondary),
                        ]),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        const CircleAvatar(radius: 20, backgroundColor: accentPink,
                            child: Icon(Icons.favorite, color: Colors.white, size: 16)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bonded with ${user.partnerName}',
                                style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                            if (user.partnerSince != null)
                              Text('Since ${user.partnerSince}',
                                  style: const TextStyle(color: textSecondary, fontSize: 12)),
                          ],
                        )),
                        const Icon(Icons.favorite, color: accentPink, size: 18),
                      ]),
                    ),

                  const SizedBox(height: 20),

                  // Partner habit progress
                  const PartnerHabitBar(),
                  const SizedBox(height: 20),

                  // Stats
                  Row(children: [
                    _statCard('$todo', 'TO DO', Icons.list_alt, accentPurple),
                    const SizedBox(width: 12),
                    _statCard('${tasks.where((t) => !t.done && t.tag == "PARTNER\'S").length}',
                        'PENDING', Icons.pending_actions, accentPink),
                    const SizedBox(width: 12),
                    _statCard('$done', 'DONE', Icons.check_circle_outline, accentBlue),
                  ]),
                  const SizedBox(height: 20),

                  // Progress
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      _progressRow('Shared Plans',
                          tasks.isEmpty ? 0 : done / tasks.length, accentPurple,
                          tasks.isEmpty ? '0%' : '${(done / tasks.length * 100).round()}%'),
                      const SizedBox(height: 16),
                      _progressRow('Overall Progress',
                          tasks.isEmpty ? 0 : done / tasks.length, accentPink,
                          tasks.isEmpty ? '0%' : '${(done / tasks.length * 100).round()}%'),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Today's focus
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Today's Focus",
                        style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('VIEW ALL', style: TextStyle(color: accentPurple, fontSize: 12)),
                  ]),
                  const SizedBox(height: 14),
                  if (todayTasks.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No tasks yet. Add some in the Planner!',
                          style: TextStyle(color: textSecondary)),
                    ))
                  else
                    ...todayTasks.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: t.done ? _focusItemDone(t.title) : _focusItem(t.title, t.time, t.tag),
                    )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(String val, String label, IconData icon, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(val, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: textSecondary, fontSize: 10)),
          ]),
        ),
      );

  Widget _progressRow(String label, double val, Color color, String pct) => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(Icons.hub, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
          ]),
          Text(pct, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val.clamp(0.0, 1.0),
            backgroundColor: bgCard2,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ]);

  Widget _focusItem(String title, String time, String tag) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(border: Border.all(color: accentPurple), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: accentPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(tag, style: const TextStyle(color: accentPurple, fontSize: 9)),
              ),
            ]),
            if (time.isNotEmpty)
              Text(time, style: const TextStyle(color: textSecondary, fontSize: 11)),
          ])),
          const Icon(Icons.play_arrow, color: accentPurple),
        ]),
      );

  Widget _focusItemDone(String title) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 36),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: textSecondary,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w600)),
            const Text('DAILY GOAL REACHED', style: TextStyle(color: Colors.green, fontSize: 10)),
          ])),
          const Text('DONE', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      );
}
