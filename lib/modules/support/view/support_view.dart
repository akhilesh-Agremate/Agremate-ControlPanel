import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/support/controller/support_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<SupportController>();

    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact cards
            Row(
              children: [
                Expanded(child: _ContactCard(icon: Icons.email_rounded, title: 'Email', value: 'contact@agremate.com', color: AppTheme.accentCyan)),
                const SizedBox(width: 16),
                Expanded(child: _ContactCard(icon: Icons.phone_rounded, title: 'Phone', value: '+91 9876543210', color: AppTheme.accentGreen)),
                const SizedBox(width: 16),
                Expanded(child: _ContactCard(icon: Icons.location_on_rounded, title: 'Address', value: 'Mumbai, Maharashtra, India', color: AppTheme.accentPurple)),
              ],
            ),
            const SizedBox(height: 32),

            // FAQ Header with Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Frequently Asked Questions', style: AppTheme.heading2),
                ElevatedButton.icon(
                  onPressed: () => _showAddFaqDialog(context, sc),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sc.faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: AppTheme.solidCardDecoration(borderRadius: 12),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                iconColor: AppTheme.accentGreen,
                collapsedIconColor: AppTheme.textMuted,
                title: Text(faq['q']!, style: AppTheme.heading3.copyWith(fontSize: 14)),
                children: [Text(faq['a']!, style: AppTheme.bodyText)],
              ),
            )),
            const SizedBox(height: 32),

            // Support ticket form
            Text('Submit a Ticket', style: AppTheme.heading2),
            const SizedBox(height: 16),
            GlassCard(
              glowColor: AppTheme.accentBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => sc.name.value = v,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Your Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (v) => sc.email.value = v,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (v) => sc.message.value = v,
                    maxLines: 4,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: sc.isSubmitting.value ? null : sc.submitTicket,
                        child: sc.isSubmitting.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bgDark))
                            : const Text('Submit Ticket'),
                      ),
                      const SizedBox(width: 16),
                      if (sc.isSubmitted.value)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 20),
                            SizedBox(width: 6),
                            Text('Ticket submitted!', style: TextStyle(color: AppTheme.accentGreen)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
  void _showAddFaqDialog(BuildContext context, SupportController sc) {
    final qController = TextEditingController();
    final aController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: AppTheme.accentGreen),
            const SizedBox(width: 12),
            const Text('Add New FAQ', style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'e.g., How do I reset my password?',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: aController,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Answer',
                hintText: 'Provide a clear explanation...',
                alignLabelWithHint: true,
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
            onPressed: () {
              if (qController.text.isNotEmpty && aController.text.isNotEmpty) {
                sc.addFaq(qController.text, aController.text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            child: const Text('Add Question'),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _ContactCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: color,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTheme.heading3),
          const SizedBox(height: 6),
          Text(value, style: AppTheme.bodyText, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
