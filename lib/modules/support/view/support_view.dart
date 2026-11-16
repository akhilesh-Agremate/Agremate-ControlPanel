import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/support/controller/support_controller.dart';
import 'package:agremate_admin/modules/support/model/support_faq.dart';
import '../../../core/utils/responsive.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<SupportController>();

    return Obx(() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, c) {
              final cards = [
                const _ContactCard(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: 'contact@agremate.com',
                ),
                const _ContactCard(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: '+91 9876543210',
                ),
                const _ContactCard(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  value: 'Mumbai, Maharashtra, India',
                ),
              ];
              if (c.maxWidth < 600) {
                return Column(
                  children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      SizedBox(width: double.infinity, child: cards[i]),
                      if (i < cards.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[2]),
                ],
              );
            }),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Frequently Asked Questions', style: AppTheme.heading2),
                ),
                const SizedBox(width: 12),
                if (sc.isSuperAdmin)
                  ElevatedButton.icon(
                    onPressed: () => _showFaqDialog(context, sc),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandSteelBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const _FaqSearch(),
            const SizedBox(height: 12),
            _categoryChips(sc),
            const SizedBox(height: 16),
            if (sc.isFaqsLoading.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (sc.faqError.value.isNotEmpty)
              Text(sc.faqError.value, style: AppTheme.bodyText)
            else if (sc.visibleFaqs.isEmpty)
              Text('No questions found.', style: AppTheme.bodyText)
            else
              ...sc.visibleFaqs.map((faq) => _faqTile(context, sc, faq)),
          ],
        ),
      );
    });
  }
  Widget _categoryChips(SupportController sc) {
    final chips = ['All', ...sc.categories];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((name) {
        final selected = sc.selectedCategory.value == name;
        return ChoiceChip(
          label: Text(name),
          selected: selected,
          selectedColor: AppTheme.brandPaleSky,
          labelStyle: TextStyle(
            color: selected ? AppTheme.brandSteelBlue : AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: selected ? AppTheme.brandSteelBlue : AppTheme.border,
          ),
          onSelected: (_) => sc.selectedCategory.value = name,
        );
      }).toList(),
    );
  }

  Widget _faqTile(BuildContext context, SupportController sc, SupportFaq faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.brandWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.brandSteelBlue, width: 1.5),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.border, width: 1.0),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          iconColor: AppTheme.brandSteelBlue,
          collapsedIconColor: AppTheme.textMuted,
          title: Text(faq.question, style: AppTheme.heading3.copyWith(fontSize: 14)),
          subtitle: faq.category.isEmpty
              ? null
              : Text(faq.category, style: AppTheme.caption),
          trailing: sc.isSuperAdmin
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      faq.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: faq.isActive ? AppTheme.brandSteelBlue : AppTheme.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more, color: AppTheme.textMuted),
                  ],
                )
              : null,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(faq.answer, style: AppTheme.bodyText),
            ),
            if (sc.isSuperAdmin) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => sc.toggleFaq(faq),
                    child: Text(faq.isActive ? 'Hide' : 'Show'),
                  ),
                  TextButton(
                    onPressed: () => _showFaqDialog(context, sc, faq: faq),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () => _confirmDelete(context, sc, faq),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppTheme.brandRed),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFaqDialog(BuildContext context, SupportController sc, {SupportFaq? faq}) {
    final qController = TextEditingController(text: faq?.question ?? '');
    final aController = TextEditingController(text: faq?.answer ?? '');
    final cController = TextEditingController(text: faq?.category ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        insetPadding: Responsive.isMobile(ctx)
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          faq == null ? 'Add New FAQ' : 'Edit FAQ',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: aController,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Answer',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Payments, Agreement, Support',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final question = qController.text.trim();
              final answer = aController.text.trim();
              if (question.isEmpty || answer.isEmpty) return;
              final ok = faq == null
                  ? await sc.createFaq(
                      question: question,
                      answer: answer,
                      category: cController.text.trim(),
                    )
                  : await sc.updateFaq(
                      SupportFaq(
                        id: faq.id,
                        question: question,
                        answer: answer,
                        category: cController.text.trim(),
                        displayOrder: faq.displayOrder,
                        isActive: faq.isActive,
                      ),
                    );
              if (ok && ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandSteelBlue),
            child: Text(faq == null ? 'Add Question' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SupportController sc, SupportFaq faq) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete FAQ'),
        content: const Text('This question will be deleted permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              sc.deleteFaq(faq);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FaqSearch extends StatefulWidget {
  const _FaqSearch();

  @override
  State<_FaqSearch> createState() => _FaqSearchState();
}

class _FaqSearchState extends State<_FaqSearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<SupportController>();
    return TextField(
      controller: _controller,
      onChanged: (value) => sc.faqQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Search questions',
        prefixIcon: const Icon(Icons.search, color: AppTheme.brandSteelBlue),
        filled: true,
        fillColor: AppTheme.brandWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.brandWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandSteelBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.brandPaleSky,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.brandSteelBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.brandSteelBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.heading3.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
