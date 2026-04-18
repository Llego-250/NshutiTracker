import 'package:flutter/material.dart';
import '../theme.dart';

class FindScreen extends StatelessWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, color: textSecondary, size: 14),
                    SizedBox(width: 6),
                    Text('12M AGO • STALE', style: TextStyle(color: textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Map background
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
                  // Nshuti avatar
                  Positioned(
                    top: 80,
                    left: 80,
                    child: _avatar('NSHUTI', accentPink),
                  ),
                  // You avatar
                  Positioned(
                    bottom: 100,
                    right: 80,
                    child: _avatar('YOU', accentBlue),
                  ),
                  // Find & Vibrate button
                  Positioned(
                    bottom: 30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: accentPurple.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentPurple, width: 2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.vibration, color: accentPurple, size: 28),
                          SizedBox(height: 4),
                          Text('FIND &\nVIBRATE',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: accentPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 20, backgroundColor: accentPink),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('Nshuti', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          _PartnerBadge(),
                        ]),
                        Text('Connected since June 2023', style: TextStyle(color: textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: textSecondary),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('MANAGE', style: TextStyle(color: textPrimary, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String label, Color color) => Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
              color: bgCard,
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)],
            ),
            child: Icon(Icons.person, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      );
}

class _PartnerBadge extends StatelessWidget {
  const _PartnerBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: accentPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
        child: const Text('PARTNER', style: TextStyle(color: accentPurple, fontSize: 9)),
      );
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
      ..cubicTo(
        size.width * 0.2, size.height * 0.5,
        size.width * 0.6, size.height * 0.45,
        size.width * 0.65, size.height * 0.65,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
