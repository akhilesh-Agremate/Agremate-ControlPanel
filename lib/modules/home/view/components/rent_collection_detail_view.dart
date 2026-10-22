import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';

class RentCollectionDetailView extends StatelessWidget {
  const RentCollectionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final amountFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return ColoredBox(
      color: const Color(0xFFF8FAFD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                  onPressed: controller.closeRentCollectionDetails,
                ),
                const SizedBox(width: 8),
                Text('Rent Collections', style: AppTheme.heading2),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isRentCollectionsLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGreen),
                );
              }

              if (controller.rentCollectionsError.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.rentCollectionsError.value,
                        style: AppTheme.bodyText,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchRentCollections,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final items = controller.rentCollections;
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No rent collections found.',
                    style: AppTheme.bodyText,
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380,
                  mainAxisExtent: 200,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _RentCard(
                    propertyName: item.propertyName,
                    tenantName: item.tenantName,
                    landlordName: item.landlordName,
                    paidDate: _formatDate(item.paymentDate),
                    dueDate: _formatDate(item.dueDate),
                    amount: amountFormat.format(item.rentAmount),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy').format(parsed);
  }
}

class _RentCard extends StatelessWidget {
  final String propertyName;
  final String tenantName;
  final String landlordName;
  final String paidDate;
  final String dueDate;
  final String amount;

  const _RentCard({
    required this.propertyName,
    required this.tenantName,
    required this.landlordName,
    required this.paidDate,
    required this.dueDate,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + property name
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 22,
                  color: Color(0xFF1F5FBF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  propertyName.isEmpty ? '—' : propertyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _infoRow(Icons.person_outline_rounded, 'Tenant', tenantName),
          const SizedBox(height: 8),
          _infoRow(Icons.key_outlined, 'Landlord', landlordName),

          const Spacer(),
          const Divider(height: 1, color: Color(0xFFE6EBF2)),
          const SizedBox(height: 10),

          // Footer: dates on the left, amount on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid: $paidDate',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Due: $dueDate',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F5FBF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Icon + "Label: value"
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}