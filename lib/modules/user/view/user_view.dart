import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Management', style: AppTheme.heading1),
          const SizedBox(height: 8),
          Text('Manage landlords and tenants across your properties.', style: AppTheme.bodyText),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Landlord Card
              Expanded(
                child: _buildUserCard(
                  title: 'Landlord',
                  color: AppTheme.accentCyan,
                  items: [
                    {'property': 'Skyline Heights', 'name': 'John Doe'},
                    {'property': 'Green Valley', 'name': 'Sarah Smith'},
                    {'property': 'Ocean View', 'name': 'Robert Brown'},
                    {'property': 'Urban Loft', 'name': 'Emma Wilson'},
                  ],
                  isLandlord: true,
                ),
              ),
              const SizedBox(width: 24),
              // Tenant Card
              Expanded(
                child: _buildUserCard(
                  title: 'Tenant',
                  color: AppTheme.accentPurple,
                  items: [
                    {'property': 'Skyline Heights', 'details': 'Apt 402 - Active'},
                    {'property': 'Green Valley', 'details': 'Villa 12 - Pending'},
                    {'property': 'Urban Loft', 'details': 'Studio B - Active'},
                    {'property': 'Maple Residency', 'details': 'Apt 105 - Expiring'},
                  ],
                  isLandlord: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String title,
    required Color color,
    required List<Map<String, String>> items,
    required bool isLandlord,
  }) {
    return GlassCard(
      glowColor: color,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isLandlord ? Icons.real_estate_agent_rounded : Icons.person_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['property']!, style: AppTheme.heading3.copyWith(color: Colors.black)),
                        const SizedBox(height: 4),
                        Text(
                          isLandlord ? 'Landlord: ${item['name']}' : 'Tenant: ${item['details']}',
                          style: AppTheme.bodyText,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
