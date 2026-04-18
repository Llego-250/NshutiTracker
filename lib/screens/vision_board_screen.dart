import 'package:flutter/material.dart';
import '../theme.dart';

class VisionBoardScreen extends StatelessWidget {
  const VisionBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Our Shared',
                      style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                  ShaderMask(
                    shaderCallback: (b) => btnGradient.createShader(b),
                    child: const Text('Ethereal Bond',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Text('A curated space for our mutual dreams, whispers, and milestones.',
                      style: TextStyle(color: textSecondary, fontSize: 13)),
                  const SizedBox(height: 24),
                  _grid(),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  _fab(Icons.image, accentPurple),
                  const SizedBox(height: 10),
                  _fab(Icons.qr_code_scanner, accentPink),
                  const SizedBox(height: 10),
                  _fab(Icons.add, accentPurple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab(IconData icon, Color color) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      );

  Widget _grid() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _goalCard(),
                  const SizedBox(height: 12),
                  _imageCard(),
                  const SizedBox(height: 12),
                  _quoteCard('The best thing to hold onto in life is each other.', '— AUDREY HEPBURN', true),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _streakCard(),
                  const SizedBox(height: 12),
                  _travelCard(),
                  const SizedBox(height: 12),
                  _quoteCard(
                      '"Connection is the energy that exists between people when they feel seen, heard, and valued."',
                      'ADDED BY M.',
                      false),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _goalCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: accentPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.power_settings_new, color: accentPurple, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: accentPink.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: const Row(children: [
                    Icon(Icons.favorite, color: accentPink, size: 10),
                    SizedBox(width: 3),
                    Text('PARTNER', style: TextStyle(color: accentPink, fontSize: 9)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Cabin in the Alps',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            const Text("Saving for our 2025 winter escape. Let's make it happen!",
                style: TextStyle(color: textSecondary, fontSize: 11)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.65,
                backgroundColor: bgCard2,
                valueColor: AlwaysStoppedAnimation(accentPurple),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('65%\nPROGRESS', style: TextStyle(color: accentPurple, fontSize: 9)),
                Text('\$12,400 /\n\$20,000', style: TextStyle(color: textSecondary, fontSize: 9)),
              ],
            ),
          ],
        ),
      );

  Widget _streakCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.arrow_outward, color: textSecondary, size: 18),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(6)),
                child: const Text('STREAK', style: TextStyle(color: textSecondary, fontSize: 9)),
              ),
            ]),
            const SizedBox(height: 8),
            const Text('Morning Yoga Streak',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('30 days of mindful movement together.',
                style: TextStyle(color: textSecondary, fontSize: 11)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (i) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < 3 ? accentPurple : bgCard2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _imageCard() => Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF2A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(10),
        child: const Text('"Wherever you are is my home."',
            style: TextStyle(color: textSecondary, fontSize: 11, fontStyle: FontStyle.italic)),
      );

  Widget _travelCard() => Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF0A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kyoto 2026',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            const Text('FUTURE TRAVEL', style: TextStyle(color: textSecondary, fontSize: 9)),
          ],
        ),
      );

  Widget _quoteCard(String quote, String author, bool isPartner) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPartner)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('99', style: TextStyle(color: textSecondary, fontSize: 24, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: accentPink.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: const Row(children: [
                      Icon(Icons.favorite, color: accentPink, size: 10),
                      SizedBox(width: 3),
                      Text('PARTNER', style: TextStyle(color: accentPink, fontSize: 9)),
                    ]),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            Text(quote, style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (!isPartner) const CircleAvatar(radius: 8, backgroundColor: accentPurple),
                if (!isPartner) const SizedBox(width: 6),
                Text(author, style: const TextStyle(color: textSecondary, fontSize: 10)),
              ],
            ),
          ],
        ),
      );
}
