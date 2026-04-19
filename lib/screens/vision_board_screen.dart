import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../providers/providers.dart';
import '../models/vision_item.dart';

class VisionBoardScreen extends ConsumerWidget {
  const VisionBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(visionProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Stack(children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              itemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
                error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: accentPink))),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No vision items yet.\nTap + to add your first dream!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textSecondary, fontSize: 14)),
                      ),
                    );
                  }
                  // Split into two columns
                  final left = items.where((_, i) => i.isEven).toList();
                  final right = items.where((_, i) => i.isOdd).toList();
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(children: left.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _itemCard(item, user?.uid ?? ''),
                      )).toList())),
                      const SizedBox(width: 12),
                      Expanded(child: Column(children: right.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _itemCard(item, user?.uid ?? ''),
                      )).toList())),
                    ],
                  );
                },
              ),
            ]),
          ),
          Positioned(
            bottom: 20, right: 20,
            child: Column(children: [
              _fab(Icons.add, accentPurple, () => _showAddItem(context, ref, user)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _fab(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );

  Widget _itemCard(VisionItem item, String myUid) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (item.isPartner)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: accentPink.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.favorite, color: accentPink, size: 10),
                SizedBox(width: 3),
                Text('PARTNER', style: TextStyle(color: accentPink, fontSize: 9)),
              ]),
            ),
          Text(item.title,
              style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(item.description, style: const TextStyle(color: textSecondary, fontSize: 11)),
          ],
          if (item.progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress!.clamp(0.0, 1.0),
                backgroundColor: bgCard2,
                valueColor: const AlwaysStoppedAnimation(accentPurple),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(item.progress! * 100).round()}%\nPROGRESS',
                  style: const TextStyle(color: accentPurple, fontSize: 9)),
              if (item.targetAmount != null)
                Text('\$${item.currentAmount?.round() ?? 0} /\n\$${item.targetAmount!.round()}',
                    style: const TextStyle(color: textSecondary, fontSize: 9)),
            ]),
          ],
          const SizedBox(height: 6),
          Text(item.type.toUpperCase(),
              style: const TextStyle(color: textSecondary, fontSize: 9, letterSpacing: 1)),
        ]),
      );

  void _showAddItem(BuildContext context, WidgetRef ref, appUser) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'goal';
    bool isPartner = false;

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
              left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Add Vision Item',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _inputField(titleCtrl, 'Title'),
            const SizedBox(height: 10),
            _inputField(descCtrl, 'Description'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: type,
              dropdownColor: bgCard2,
              style: const TextStyle(color: textPrimary),
              decoration: _deco('Type'),
              items: ['goal', 'quote', 'streak', 'travel']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setModal(() => type = v!),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Checkbox(
                value: isPartner,
                onChanged: (v) => setModal(() => isPartner = v!),
                activeColor: accentPurple,
              ),
              const Text('Partner item', style: TextStyle(color: textSecondary)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: accentPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (appUser == null || titleCtrl.text.trim().isEmpty) return;
                  final item = VisionItem(
                    id: const Uuid().v4(),
                    type: type,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    createdBy: appUser.uid,
                    isPartner: isPartner,
                    createdAt: DateTime.now(),
                  );
                  await ref.read(visionServiceProvider)
                      .addItem(appUser.uid, appUser.partnerId, item);
                  if (context.mounted) Navigator.pop(ctx);
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  static Widget _inputField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        style: const TextStyle(color: textPrimary),
        decoration: _deco(hint),
      );

  static InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textSecondary),
        filled: true,
        fillColor: bgCard2,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      );
}

extension _IndexedWhere<T> on List<T> {
  List<T> where(bool Function(T, int) test) {
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      if (test(this[i], i)) result.add(this[i]);
    }
    return result;
  }
}
