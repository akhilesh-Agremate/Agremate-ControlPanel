import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/finance/controller/finance_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/documents/controller/document_controller.dart';

class PropertyDetailPanel extends StatelessWidget {
  final PropertyModel property;

  const PropertyDetailPanel({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();
    final fmt = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    // Visibility logic based on status
    final showTenant =
        property.status == PropertyStatus.rented ||
        property.status == PropertyStatus.booked ||
        property.status == PropertyStatus.requested;

    Widget statusBadge;
    switch (property.status) {
      case PropertyStatus.rented:
        statusBadge = StatusBadge.rented();
        break;
      case PropertyStatus.available:
        statusBadge = StatusBadge.available();
        break;
      case PropertyStatus.booked:
        statusBadge = StatusBadge.booked();
        break;
      case PropertyStatus.requested:
        statusBadge = StatusBadge.requested();
        break;
      case PropertyStatus.maintenance:
        statusBadge = StatusBadge.maintenance();
        break;
      default:
        statusBadge = StatusBadge(
          label: property.statusLabel,
          color: AppTheme.accentGreen,
        );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white, // Light theme background
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (pc.returnTabIndex.value != null) {
                      nav.currentIndex.value = pc.returnTabIndex.value!;
                      pc.returnTabIndex.value = null;
                    }
                    pc.selectedProperty.value = null;
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                  tooltip: 'Back to List',
                ),
                const SizedBox(width: 8),
                Text(
                  'Property Detail',
                  style: AppTheme.heading2.copyWith(color: Colors.black),
                ),
                const Spacer(),
                statusBadge,
              ],
            ),
          ),
          const Divider(color: Colors.black12, height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1: Image + Name/Desc
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            property.imageUrl,
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              property.name,
                              style: AppTheme.heading1.copyWith(
                                fontSize: 36,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Premium ${property.propertyType} located in the heart of ${property.city}. Featuring modern architecture and top-tier security systems for a comfortable living experience.',
                              style: AppTheme.bodyText.copyWith(
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppTheme.accentRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${property.address.address}, ${property.city}',
                                  style: AppTheme.bodyText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ROW 2: Features + Landlord
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Features & Facilities', Colors.black),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _buildFeatureIcon(Icons.wifi, 'Fast WiFi'),
                                _buildFeatureIcon(Icons.pool, 'Pool'),
                                _buildFeatureIcon(Icons.fitness_center, 'Gym'),
                                _buildFeatureIcon(Icons.park, 'Garden'),
                                _buildFeatureIcon(
                                  Icons.security_rounded,
                                  '24/7 Security',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: _buildContactCard(
                          title: 'Landlord',
                          name: property.landlordName,
                          phone: property.landlordPhone ?? 'N/A',
                          email: property.landlordEmail ?? 'N/A',
                          address: 'Landlord Office, Block A, Mumbai',
                          accentColor: AppTheme.accentBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ROW 3: Amenities + Tenant
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Amenities', Colors.black),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildAmenityBox('Bakery', Icons.bakery_dining),
                                _buildAmenityBox('Laundry', Icons.local_laundry_service),
                                _buildAmenityBox('Parking', Icons.local_parking),
                                _buildAmenityBox('Balcony', Icons.balcony),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: showTenant
                            ? _buildContactCard(
                                title: 'Tenant',
                                name: property.primaryTenantName ?? 'N/A',
                                phone: property.primaryTenantPhone ?? 'N/A',
                                email: property.primaryTenantEmail ?? 'N/A',
                                address: property.address.address,
                                accentColor: AppTheme.accentGreen,
                              )
                            : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.person_add_disabled_rounded,
                                      color: Colors.black38,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No Tenant Occupying',
                                      style: AppTheme.bodyText.copyWith(
                                        color: Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ROW 4: Finance + Documents
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionHeader('Finance', Colors.black),
                                TextButton.icon(
                                  onPressed: () {
                                    // Navigate to finance details
                                    final fc = Get.find<FinanceController>();
                                    fc.selectProperty(property.id, property.name);
                                    nav.currentIndex.value = 3; // Finance tab
                                  },
                                  icon: const Icon(Icons.info_outline_rounded,
                                      size: 14, color: AppTheme.accentGreen),
                                  label: Text(
                                    'More Details',
                                    style: TextStyle(
                                      color: AppTheme.accentGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.accentGreen.withValues(alpha: 0.1),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFinanceCard(
                                    'Monthly Rent',
                                    fmt.format(property.rentAmount),
                                    Colors.black, // Dark color as requested
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildFinanceCard(
                                    'Advance',
                                    fmt.format(property.advanceAmount),
                                    Colors.black, // Dark color as requested
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Documents', Colors.black),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDocumentSection(
                                    'Landlord Docs',
                                    ['Ownership_Deed.pdf', 'Tax_Reciept.pdf'],
                                    AppTheme.accentBlue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDocumentSection(
                                    'Tenant Docs',
                                    ['Agreement.pdf', 'ID_Proof.pdf'],
                                    AppTheme.accentGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, [Color color = AppTheme.textMuted]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTheme.heading3.copyWith(
            fontSize: 14,
            letterSpacing: 2,
            color: color == Colors.black ? Colors.black54 : color,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Tooltip(
        message: label,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
      ),
    );
  }

  Widget _buildAmenityBox(String label, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentCyan, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTheme.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(color: Colors.black45),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.heading1.copyWith(color: color, fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String name,
    required String phone,
    required String email,
    required String address,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.caption.copyWith(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 12),
          _buildContactRow(Icons.phone_rounded, phone),
          const SizedBox(height: 8),
          _buildContactRow(Icons.email_rounded, email),
          const SizedBox(height: 8),
          _buildContactRow(Icons.location_on_rounded, address),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black38, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyText.copyWith(fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(String label, List<String> docs, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        ...docs.map(
          (doc) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppTheme.accentRed,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      doc,
                      style: AppTheme.caption.copyWith(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
