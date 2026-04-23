import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/providers.dart';

class FindScreen extends ConsumerWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
          error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: accentPink))),
          data: (user) {
            if (user == null) return const SizedBox();
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.history, color: textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      user.partnerId != null ? 'PARTNER CONNECTED' : 'NO PARTNER YET',
                      style: TextStyle(
                          color: user.partnerId != null ? Colors.green : textSecondary,
                          fontSize: 12),
                    ),
                  ]),
                ),
              ),
              Expanded(
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E1A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: accentPurple.withOpacity(0.1)),
                    ),
                    child: CustomPaint(
                      painter: _MapPainter(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // My avatar
                  Positioned(
                    bottom: 100, right: 80,
                    child: _avatar(user.name.split(' ').first, accentBlue, 'YOU'),
                  ),
                  // Partner avatar
                  if (user.partnerId != null)
                    Positioned(
                      top: 80, left: 80,
                      child: _avatar(user.partnerName?.split(' ').first ?? 'PARTNER', accentPink,
                          user.partnerName?.split(' ').first.toUpperCase() ?? 'PARTNER'),
                    ),
                  // Find & Vibrate button
                  Positioned(
                    bottom: 30,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: accentPurple.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentPurple, width: 2),
                      ),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.vibration, color: accentPurple, size: 28),
                        SizedBox(height: 4),
                        Text('FIND &\nVIBRATE',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: accentPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ]),
              ),
              // Partner info / connect
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
                child: user.partnerId == null
                    ? _connectWidget(context, ref, user.uid)
                    : Row(children: [
                        const CircleAvatar(radius: 20, backgroundColor: accentPink,
                            child: Icon(Icons.person, color: Colors.white, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(user.partnerName ?? 'Partner',
                                style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: accentPurple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4)),
                              child: const Text('PARTNER',
                                  style: TextStyle(color: accentPurple, fontSize: 9)),
                            ),
                          ]),
                          if (user.partnerSince != null)
                            Text('Connected since ${user.partnerSince}',
                                style: const TextStyle(color: textSecondary, fontSize: 12)),
                        ])),
                        GestureDetector(
                          onTap: () => _showManagePartner(context, ref, user.uid, user.partnerId!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                border: Border.all(color: textSecondary),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('MANAGE', style: TextStyle(color: textPrimary, fontSize: 12)),
                          ),
                        ),
                      ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _avatar(String initials, Color color, String label) => Column(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            color: bgCard,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)],
          ),
          alignment: Alignment.center,
          child: Text(initials[0].toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ]);

  Widget _connectWidget(BuildContext context, WidgetRef ref, String myUid) {
    final emailCtrl = TextEditingController();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Connect Your Partner',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: TextField(
            controller: emailCtrl,
            style: const TextStyle(color: textPrimary),
            decoration: InputDecoration(
              hintText: "Partner's email",
              hintStyle: const TextStyle(color: textSecondary),
              filled: true,
              fillColor: bgCard2,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            try {
              await ref.read(userServiceProvider).connectPartner(myUid, emailCtrl.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partner connected! 💖')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e'), backgroundColor: accentPink),
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: accentPurple, shape: BoxShape.circle),
            child: const Icon(Icons.link, color: Colors.white, size: 20),
          ),
        ),
      ]),
    ]);
  }

  void _showManagePartner(BuildContext context, WidgetRef ref, String myUid, String partnerId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgCard,
        title: const Text('Partner Settings', style: TextStyle(color: textPrimary)),
        content: const Text('Do you want to disconnect from your partner?',
            style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(userServiceProvider).disconnectPartner(myUid, partnerId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Disconnect', style: TextStyle(color: accentPink)),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentBlue.withOpacity(0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.35)
      ..cubicTo(size.width * 0.2, size.height * 0.5,
          size.width * 0.6, size.height * 0.45, size.width * 0.65, size.height * 0.65);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
