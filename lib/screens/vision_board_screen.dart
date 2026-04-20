import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../providers/providers.dart';
import '../models/vision_item.dart';

class VisionBoardScreen extends ConsumerStatefulWidget {
  const VisionBoardScreen({super.key});
  @override
  ConsumerState<VisionBoardScreen> createState() => _VisionBoardScreenState();
}

class _VisionBoardScreenState extends ConsumerState<VisionBoardScreen> {
  int _viewMode = 0; // 0=list 1=large 2=small

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(visionProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                const SizedBox(height: 16),
                Row(children: [
                  const Text('Dreams', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                  const Spacer(),
                  _viewToggle(),
                ]),
                const SizedBox(height: 12),
              ]),
            ),
            Expanded(
              child: itemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: accentPurple)),
                error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: accentPink))),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No vision items yet.\nTap + to add your first dream!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textSecondary, fontSize: 14)),
                    );
                  }
                  if (_viewMode == 0) {
                    // List view
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _itemCard(items[i], user?.uid ?? ''),
                    );
                  }
                  // Grid view (large=2col, small=3col)
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _viewMode == 2 ? 3 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: _viewMode == 2 ? 0.8 : 0.9,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _itemGridCard(items[i], large: _viewMode == 1),
                  );
                },
              ),
            ),
          ]),
          Positioned(
            bottom: 20, right: 20,
            child: GestureDetector(
              onTap: () => _showAddItem(context, ref, user),
              child: Container(
                width: 48, height: 48,
                decoration: const BoxDecoration(color: accentPurple, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _viewToggle() {
    final modes = [
      (Icons.view_list_rounded, 'List'),
      (Icons.grid_view_rounded, 'Large'),
      (Icons.apps_rounded, 'Small'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: List.generate(3, (i) {
          final active = _viewMode == i;
          return GestureDetector(
            onTap: () => setState(() => _viewMode = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: active ? accentPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(modes[i].$1, color: active ? Colors.white : textSecondary, size: 18),
            ),
          );
        }),
      ),
    );
  }

  Widget _itemGridCard(VisionItem item, {required bool large}) => Container(
        padding: EdgeInsets.all(large ? 14 : 10),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.isPartner ? accentPink.withOpacity(0.25) : Colors.white.withOpacity(0.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (item.isPartner)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                  color: accentPink.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.favorite, color: accentPink, size: 9),
                SizedBox(width: 2),
                Text('PARTNER', style: TextStyle(color: accentPink, fontSize: 8)),
              ]),
            ),
          Text(item.title,
              maxLines: large ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: textPrimary, fontWeight: FontWeight.bold, fontSize: large ? 13 : 11)),
          if (large && item.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: textSecondary, fontSize: 10)),
          ],
          const Spacer(),
          Text(item.type.toUpperCase(),
              style: TextStyle(color: textSecondary, fontSize: large ? 9 : 8, letterSpacing: 1)),
          if (item.progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress!.clamp(0.0, 1.0),
                backgroundColor: bgCard2,
                valueColor: const AlwaysStoppedAnimation(accentPurple),
                minHeight: 3,
              ),
            ),
          ],
        ]),
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

  Widget _inputField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        style: const TextStyle(color: textPrimary),
        decoration: _deco(hint),
      );

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textSecondary),
        filled: true,
        fillColor: bgCard2,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      );
}


