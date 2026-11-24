import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/app_colors.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/modules/home/model/rental_agreement_item.dart';

class RentalAgreementsDetailView extends StatelessWidget {
  const RentalAgreementsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return ColoredBox(
      color: AppColors.scaffoldLight,
      child: Obx(() {
        if (c.isRentalAgreementsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentGreen),
          );
        }
        if (c.rentalAgreementsError.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(c.rentalAgreementsError.value, style: AppTheme.bodyText),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: c.fetchRentalAgreements,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filter = c.rentalAgreementFilter.value;
        final all = c.rentalAgreements;
        final shown = filter == 'All'
            ? all.toList()
            : all.where((a) => a.status == filter).toList();
        final statuses = ['All', ...{...all.map((a) => a.status).where((s) => s.isNotEmpty)}];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(c, all.length),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        w < 600 ? 14 : 28, 0, w < 600 ? 14 : 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in statuses)
                              ChoiceChip(
                                label: Text(s),
                                selected: filter == s,
                                onSelected: (_) =>
                                c.rentalAgreementFilter.value = s,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (shown.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text('No rental agreements found.',
                                  style: AppTheme.bodyText),
                            ),
                          )
                        else
                          _grid(shown.map(_card).toList(), w),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _header(HomeController c, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary, size: 20),
            onPressed: c.closeRentalAgreementDetails,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rental Agreements', style: AppTheme.heading2),
                Text('$total agreements on the platform',
                    style: AppTheme.bodyText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(List<Widget> cards, double width) {
    Widget col(List<Widget> items) => Column(children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        items[i],
      ],
    ]);

    if (width < 800) return col(cards);

    final left = <Widget>[], right = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      (i.isEven ? left : right).add(cards[i]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: col(left)),
        const SizedBox(width: 12),
        Expanded(child: col(right)),
      ],
    );
  }

  Widget _card(RentalAgreementItem a) {
    final df = DateFormat('MMM d, yyyy');
    final rent = a.rentAmount > 0
        ? NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(a.rentAmount)
        : '';
    final creator = [a.creatorName, a.creatorRole]
        .where((v) => v.isNotEmpty && v != 'Unknown')
        .join(' · ');

    return GlassCard(
      color: AppTheme.brandWhite,
      borderColor: AppTheme.border,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppTheme.brandPaleSky,
                child: Icon(Icons.description_outlined,
                    color: AppTheme.brandSteelBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_dash(a.propertyName), style: AppTheme.heading3),
                    Text(
                      a.agreementType.isEmpty
                          ? '-'
                          : '${a.agreementType} agreement',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ),
              _statusChip(a.status),
            ],
          ),
          if (a.propertyAddress.isNotEmpty) ...[
            const SizedBox(height: 10),
            _row(Icons.location_on_outlined, a.propertyAddress),
          ],
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _row(Icons.real_estate_agent_outlined,
                    'Landlord: ${_dash(a.landlordName)}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _row(Icons.person_outline,
                    'Tenant: ${_dash(a.tenantName)}'),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _row(
                  Icons.currency_rupee,
                  'Rent: ${rent.isEmpty ? '-' : rent}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _row(
                  Icons.calendar_today_outlined,
                  'Start: ${a.startDate == null ? '-' : df.format(a.startDate!.toLocal())}',
                ),
              ),
            ],
          ),

          if (creator.isNotEmpty) ...[
            const SizedBox(height: 8),
            _row(Icons.edit_note_rounded, 'Created by $creator'),
          ],
        ],
      ),
    );
  }

  String _dash(String value) => value.isEmpty ? '-' : value;

  Widget _row(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 15, color: AppTheme.textSecondary),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: AppTheme.bodyText)),
    ],
  );

  Widget _cell(IconData icon, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTheme.caption),
        ],
      ),
      const SizedBox(height: 2),
      Text(value, style: AppTheme.bodyText),
    ],
  );

  Widget _statusChip(String status) {
    final s = status.toLowerCase();
    final good = s == 'active' || s == 'approved';
    final bad = s == 'inactive';
    final bg = good
        ? AppTheme.statusActiveBg
        : bad
        ? AppTheme.brandRedLight
        : AppTheme.brandPaleSky;
    final fg = good
        ? AppTheme.statusActiveText
        : bad
        ? AppTheme.brandRed
        : AppTheme.brandSteelBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.isEmpty ? 'Unknown' : status,
          style: AppTheme.caption
              .copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}