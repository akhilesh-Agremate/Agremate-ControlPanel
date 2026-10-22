import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'package:agremate_admin/core/widgets/pdf_iframe_view.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/model/pg_property_detail_model.dart';
import 'package:agremate_admin/modules/property/controller/pg_property_detail_controller.dart';
import 'package:agremate_admin/modules/property/view/components/create_pg_property_panel.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import '../../auth/controller/auth_controller.dart';

class PgPropertyDetailView extends StatefulWidget {
  final PropertyModel property;

  const PgPropertyDetailView({super.key, required this.property});

  @override
  State<PgPropertyDetailView> createState() => _PgPropertyDetailViewState();
}

class _PgPropertyDetailViewState extends State<PgPropertyDetailView> {
  late final PgPropertyDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<PgPropertyDetailController>()
        ? Get.find<PgPropertyDetailController>()
        : Get.put(PgPropertyDetailController());
    _controller.init(widget.property);
  }

  @override
  void didUpdateWidget(covariant PgPropertyDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property.id != widget.property.id) {
      _controller.init(widget.property);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();
    final fmt = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return Obx(() {
      final pg = _controller.property.value;
      final isLoading = _controller.isLoading.value;

      if (_controller.isEditing.value) {
        if (isLoading) {
          return const ColoredBox(
            color: Color(0xFFF8FAFD),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final pgData = _controller.property.value ??
            PgPropertyDetailData.fromPropertyModel(widget.property);
        return CreatePgPropertyPanel(
          key: ValueKey(
              'edit_pg_${pgData.id}_${pgData.name}_${pgData.photoPaths.length}'),
          initial: pgData,
          onBack: _controller.stopEdit,
          onSubmit: (data) async {
            await pc.updatePgProperty(widget.property.id, data);
            _controller.stopEdit();
            _controller.refreshProperty();
          },
          amenityOptions: pc.amenities.toList(),
          amenitiesLoading: pc.isAmenitiesLoading.value,
        );
      }

      Widget statusBadge;
      final statusStr = (pg?.status ?? widget.property.statusLabel).toLowerCase();
      if (statusStr.contains('rented')) {
        statusBadge = StatusBadge.rented();
      } else if (statusStr.contains('avail') || statusStr.contains('vacant')) {
        statusBadge = StatusBadge.available();
      } else if (statusStr.contains('booked')) {
        statusBadge = StatusBadge.booked();
      } else if (statusStr.contains('request')) {
        statusBadge = StatusBadge.requested();
      } else if (statusStr.contains('maint')) {
        statusBadge = StatusBadge.maintenance();
      } else {
        statusBadge = StatusBadge.available();
      }

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF8FAFD),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_controller.openDocName.value != null) {
                        _controller.closeDocument();
                        return;
                      }
                      if (pc.returnTabIndex.value != null) {
                        nav.currentIndex.value = pc.returnTabIndex.value!;
                        pc.returnTabIndex.value = null;
                      }
                      pc.search('');
                      pc.closePropertyDetails();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _controller.openDocName.value ?? 'PG Property Detail',
                    style: AppTheme.heading2.copyWith(color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCEE1F3)),
                    ),
                    child: const Text(
                      'PG / Co-Living',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brandSteelBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_controller.openDocName.value == null) ...[
                    IconButton(
                      onPressed: _controller.refreshProperty,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      tooltip: 'Refresh',
                    ),
                    const SizedBox(width: 8),
                    if (_controller.canEdit) ...[
                      OutlinedButton.icon(
                        onPressed: _controller.startEdit,
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (_controller.canDelete) ...[
                      OutlinedButton.icon(
                        onPressed: () => _controller.confirmDelete(context),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: AppTheme.accentRed,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.accentRed),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.accentRed),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ],
                  statusBadge,
                ],
              ),
            ),
            const Divider(color: Colors.black12, height: 1),

            if (isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppTheme.accentBlue,
                backgroundColor: Color(0xFFE8F1FB),
              )
            else
              const SizedBox(height: 2),

            Expanded(
              child: _controller.openDocName.value != null
                  ? _buildDocumentViewer()
                  : pg == null
                      ? Center(
                          child: Text(
                            _controller.loadError.value ?? 'Loading PG details...',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 960;
                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeroRow(pg),
                                  const SizedBox(height: 20),
                                  _buildContentLayout(
                                    isWide: isWide,
                                    pg: pg,
                                    fmt: fmt,
                                    nav: nav,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDocumentViewer() {
    final docName = _controller.openDocName.value ?? 'Document Preview';
    final docUrl = _controller.openDocUrl.value ?? '';
    final isPdf = docUrl.toLowerCase().contains('.pdf') || docName.toLowerCase().endsWith('.pdf');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                docName,
                style: AppTheme.heading2.copyWith(color: Colors.black87),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _controller.closeDocument,
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: docUrl.isEmpty
                ? const Center(child: Text('Invalid document URL'))
                : isPdf
                    ? PdfIframeView(url: docUrl)
                    : Image.network(
                        docUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroRow(PgPropertyDetailData pg) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720;
        final photoPaths = pg.photoPaths.isNotEmpty ? pg.photoPaths : pg.images;

        final imageSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: photoPaths.isEmpty
                    ? Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: Color(0xFFCBD5E1),
                          size: 44,
                        ),
                      )
                    : Obx(() {
                        final idx = _controller.selectedImageIndex.value
                            .clamp(0, photoPaths.length - 1);
                        final currentUrl = photoPaths[idx];
                        return Image.network(
                          currentUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Color(0xFFCBD5E1),
                              size: 40,
                            ),
                          ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.accentBlue,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        );
                      }),
              ),
            ),
            if (photoPaths.length > 1) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photoPaths.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected = _controller.selectedImageIndex.value == index;
                      return GestureDetector(
                        onTap: () => _controller.selectImage(index),
                        child: Container(
                          width: 52,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentBlue : Colors.black12,
                              width: isSelected ? 2 : 1,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(photoPaths[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ],
        );

        final infoSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pg.name,
                    style: AppTheme.heading1.copyWith(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppTheme.accentRed,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pg.address.isNotEmpty ? pg.address : 'Address not specified',
                    style: AppTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMiniBadge(Icons.layers_rounded, '${pg.totalFloors} Floors'),
                _buildMiniBadge(Icons.meeting_room_rounded, '${pg.totalRooms} Rooms'),
                _buildMiniBadge(Icons.bed_rounded, '${pg.totalBeds} Beds'),
                if (pg.displayRentPerBed.isNotEmpty)
                  _buildMiniBadge(Icons.payments_rounded, '₹${pg.displayRentPerBed}/bed'),
              ],
            ),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageSection,
              const SizedBox(height: 16),
              infoSection,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: imageSection),
            const SizedBox(width: 24),
            Expanded(flex: 6, child: infoSection),
          ],
        );
      },
    );
  }

  Widget _buildMiniBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6E8FA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.brandSteelBlue),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentLayout({
    required bool isWide,
    required PgPropertyDetailData pg,
    required NumberFormat fmt,
    required NavigationController nav,
  }) {
    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pg.description.trim().isNotEmpty)
          _buildCardSection(
            icon: Icons.info_outline,
            title: 'About Property',
            child: Text(
              pg.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),

        _buildBuildingLayoutSection(pg),
        _buildPgDetailsChipsSection(pg),

        if (pg.amenityLabels.isNotEmpty)
          _buildAmenitiesSection(pg),

        if (pg.houseRules.isNotEmpty)
          _buildHouseRulesSection(pg),
        _buildLocationSection(pg),
      ],
    );

    final rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLandlordCard(pg),
        const SizedBox(height: 16),
        _buildFinanceSection(pg, fmt, nav),
        const SizedBox(height: 16),
        _buildDocumentsSection(pg),
      ],
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftColumn,
          const SizedBox(height: 16),
          rightColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: leftColumn),
        const SizedBox(width: 24),
        Expanded(flex: 5, child: rightColumn),
      ],
    );
  }

  AuthController? get _auth =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  /// Only Super Admin and Landlord can open the tenant list.
  bool get _canViewTenants {
    final a = _auth;
    return a != null && (a.isSuperAdmin || a.isLandlord);
  }

  void _showOccupiedTenantsDialog(PgPropertyDetailData pg) {
    final entries = <({PgFloor floor, PgRoom room, PgBed bed})>[];
    for (final f in pg.floors) {
      for (final r in f.rooms) {
        for (final b in r.beds) {
          if (b.isOccupied) entries.add((floor: f, room: r, bed: b));
        }
      }
    }

    String startDate(String? raw) {
      final s = (raw ?? '').trim();
      if (s.isEmpty) return '-';
      final d = DateTime.tryParse(s);
      return d != null ? DateFormat('dd-MM-yyyy').format(d.toLocal()) : s;
    }

    String val(String? v) => (v == null || v.trim().isEmpty) ? '-' : v.trim();

    Widget line(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Occupied beds (${entries.length})',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: entries.isEmpty
                    ? const Center(child: Text('No occupied beds.'))
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final e = entries[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.floor.floorName} · ${e.room.roomName} · ${e.bed.bedNumber}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            val(e.bed.tenantName),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          line(Icons.phone_outlined, val(e.bed.tenantPhone)),
                          line(Icons.mail_outline_rounded, val(e.bed.tenantEmail)),
                          line(Icons.calendar_today_outlined,
                              'Start date: ${startDate(e.bed.joinDate)}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuildingLayoutSection(PgPropertyDetailData pg) {
    final totalBeds = pg.totalBeds;
    final occupiedBeds = pg.occupiedBeds;
    final vacantBeds = pg.availableBeds;

    return _buildCardSection(
      icon: Icons.apartment_outlined,
      title: 'Building layout',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLayoutStatBox(
                  label: 'Total beds',
                  value: '$totalBeds',
                  valueColor: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: (_canViewTenants && occupiedBeds > 0)
                      ? () => _showOccupiedTenantsDialog(pg)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: _buildLayoutStatBox(
                    label: 'Occupied',
                    value: '$occupiedBeds',
                    valueColor: const Color(0xFF16A34A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: pg.floors.isNotEmpty
                      ? () => _showFloorDetailsDialog(pg, pg.floors.first)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: _buildLayoutStatBox(
                    label: 'Vacant',
                    value: '$vacantBeds',
                    valueColor: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Tap a floor to view rooms and beds.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          if (pg.floors.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: const Center(
                child: Text(
                  'No floor layout data configured for this PG.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isTwoCol = constraints.maxWidth >= 460;
                if (isTwoCol) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: pg.floors.map((floor) {
                      return SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: _buildFloorCard(floor, pg),
                      );
                    }).toList(),
                  );
                }
                return Column(
                  children: pg.floors.map((floor) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildFloorCard(floor, pg),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLayoutStatBox({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorCard(PgFloor floor, PgPropertyDetailData pg) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFloorDetailsDialog(pg, floor),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDCE8F6)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.layers_outlined,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      floor.floorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${floor.rooms.length} rms · ${floor.totalBeds} beds',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF2563EB),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFloorDetailsDialog(PgPropertyDetailData pg, PgFloor floor) {
    showDialog(
      context: context,
      builder: (ctx) => _PgFloorBedDetailsDialog(
        pg: pg,
        initialFloor: floor,
      ),
    );
  }

  Widget _buildPgDetailsChipsSection(PgPropertyDetailData pg) {
    return _buildCardSection(
      icon: Icons.grid_view_outlined,
      title: 'PG details',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildInfoChip(label: pg.pgType, icon: Icons.groups_outlined),
          _buildInfoChip(label: pg.genderAllowed, icon: Icons.wc_outlined),
          if (pg.roomType.isNotEmpty)
            _buildInfoChip(label: pg.roomType, icon: Icons.meeting_room_outlined),
          if (pg.rentPerBed.isNotEmpty)
            _buildInfoChip(label: '₹${pg.rentPerBed}/bed', icon: Icons.payments_outlined),
          if (pg.rentPaymentDate != null)
            _buildInfoChip(
              label: 'Rent Payment Date: ${pg.rentPaymentDate}',
              icon: Icons.event_outlined,
            ),
          _buildInfoChip(
            label: '${pg.floors.length} floors · ${pg.totalRooms} rooms · ${pg.totalBeds} beds',
            icon: Icons.layers_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCCE2F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D68BD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(PgPropertyDetailData pg) {
    return _buildCardSection(
      icon: Icons.star_outline_rounded,
      title: 'Amenities',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pg.amenityLabels.map((label) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_amenityIcon(label), size: 15, color: AppTheme.brandSteelBlue),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHouseRulesSection(PgPropertyDetailData pg) {
    return _buildCardSection(
      icon: Icons.rule_outlined,
      title: 'House rules',
      child: Column(
        children: pg.houseRules.map((rule) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD6E8FA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rule,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationSection(PgPropertyDetailData pg) {
    final hasCoords = pg.latitude != null && pg.longitude != null;

    return _buildCardSection(
      icon: Icons.location_on_outlined,
      title: 'Location',
      trailing: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _controller.shareLocation(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.share_outlined, size: 15, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text(
                  'Share',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pg.address.isNotEmpty ? pg.address : 'Address not specified',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (hasCoords) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lat: ${pg.latitude!.toStringAsFixed(5)}, Lng: ${pg.longitude!.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              TextButton.icon(
                onPressed: _controller.openGoogleMaps,
                icon: const Icon(Icons.map_rounded, size: 16, color: Color(0xFF2563EB)),
                label: const Text(
                  'Open in Maps',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildLandlordCard(PgPropertyDetailData pg) {
    final landlord = pg.landlord;
    final name = landlord?.name.isNotEmpty == true ? landlord!.name : 'N/A';
    final phone = landlord?.phone.isNotEmpty == true ? landlord!.phone : 'N/A';
    final email = landlord?.email.isNotEmpty == true ? landlord!.email : 'N/A';
    final addr = landlord?.address.isNotEmpty == true ? landlord!.address : 'N/A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: AppTheme.accentBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LANDLORD',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          _buildContactInfoRow(Icons.phone_rounded, phone),
          const SizedBox(height: 8),
          _buildContactInfoRow(Icons.email_rounded, email),
          if (addr.isNotEmpty && addr != 'N/A') ...[
            const SizedBox(height: 8),
            _buildContactInfoRow(Icons.location_on_rounded, addr),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.black45),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceSection(
    PgPropertyDetailData pg,
    NumberFormat fmt,
    NavigationController nav,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              const Icon(Icons.account_balance_wallet_outlined, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              const Text(
                'FINANCE & PRICING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => nav.currentIndex.value = 3,
                icon: const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.accentBlue),
                label: const Text(
                  'More Details',
                  style: TextStyle(color: AppTheme.accentBlue, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFinanceCard(
                  'Rent / Bed',
                  pg.displayRentPerBed.isNotEmpty
                      ? '₹${pg.displayRentPerBed}'
                      : (pg.rent > 0 ? fmt.format(pg.rent) : '₹0'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinanceCard(
                  'Advance',
                  fmt.format(pg.advance),
                ),
              ),
            ],
          ),
          if (pg.rentPaymentDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    'Rent Due Day: ${pg.rentPaymentDate}th of month',
                    style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(PgPropertyDetailData pg) {
    final docs = pg.documents;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.folder_rounded, color: AppTheme.accentBlue, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'DOCUMENTS & PHOTOS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (docs.isEmpty)
            const Text(
              'No documents or photos uploaded yet.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final d = docs[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        d.isPdf
                            ? Icons.picture_as_pdf_rounded
                            : Icons.image_rounded,
                        color: d.isPdf ? AppTheme.accentRed : AppTheme.brandSteelBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.documentName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (d.category.isNotEmpty)
                              Text(
                                d.category,
                                style: const TextStyle(fontSize: 10, color: Colors.black54),
                              ),
                          ],
                        ),
                      ),
                      if (d.fileUrl.isNotEmpty) ...[
                        IconButton(
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          tooltip: 'Preview',
                          onPressed: () => _controller.openDocument(d.documentName, d.fileUrl),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Colors.black87),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 18, endIndent: 18, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }

  IconData _amenityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('wifi')) return Icons.wifi_rounded;
    if (lower.contains('gym')) return Icons.fitness_center_rounded;
    if (lower.contains('pool')) return Icons.pool_rounded;
    if (lower.contains('laundry')) return Icons.local_laundry_service_rounded;
    if (lower.contains('food') || lower.contains('mess') || lower.contains('kitchen')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('clean') || lower.contains('housekeeping')) {
      return Icons.cleaning_services_rounded;
    }
    if (lower.contains('ac') || lower.contains('air')) return Icons.ac_unit_rounded;
    if (lower.contains('cctv') || lower.contains('security')) return Icons.security_rounded;
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('power') || lower.contains('backup')) return Icons.battery_charging_full_rounded;
    if (lower.contains('water') || lower.contains('ro')) return Icons.water_drop_rounded;
    if (lower.contains('bed')) return Icons.king_bed_rounded;
    if (lower.contains('bath') || lower.contains('wash')) return Icons.bathroom_rounded;
    return Icons.star_outline_rounded;
  }
}

class _PgFloorBedDetailsDialog extends StatefulWidget {
  final PgPropertyDetailData pg;
  final PgFloor initialFloor;

  const _PgFloorBedDetailsDialog({
    required this.pg,
    required this.initialFloor,
  });

  @override
  State<_PgFloorBedDetailsDialog> createState() => _PgFloorBedDetailsDialogState();
}

class _PgFloorBedDetailsDialogState extends State<_PgFloorBedDetailsDialog> {
  late PgFloor _selectedFloor;
  final Set<String> _expandedRoomIds = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedFloor = widget.initialFloor;
    if (_selectedFloor.rooms.isNotEmpty) {
      final firstRoom = _selectedFloor.rooms.first;
      _expandedRoomIds.add(firstRoom.id.isNotEmpty ? firstRoom.id : firstRoom.roomName);
    }
  }

  AuthController? get _auth =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  String _last10(String? v) {
    final d = (v ?? '').replaceAll(RegExp(r'[^\d]'), '');
    return d.length > 10 ? d.substring(d.length - 10) : d;
  }

  bool _isMyBed(PgBed bed) {
    final a = _auth;
    if (a == null) return false;

    final myId = a.userId.value.trim();
    final tId = (bed.tenant?['id'] ?? bed.tenant?['userId'] ?? '').toString().trim();
    if (myId.isNotEmpty && tId.isNotEmpty && myId == tId) return true;

    final myPhone = _last10(a.userPhone.value);
    if (myPhone.length == 10 && myPhone == _last10(bed.tenantPhone)) return true;

    final myEmail = a.userEmail.value.trim().toLowerCase();
    final bedEmail = (bed.tenantEmail ?? '').trim().toLowerCase();
    return myEmail.isNotEmpty && myEmail == bedEmail;
  }

  /// Super Admin and Landlord see every tenant; a tenant sees only their own bed.
  bool _canSeeTenant(PgBed bed) {
    final a = _auth;
    if (a == null) return false;
    if (a.isSuperAdmin || a.isLandlord) return true;
    if (a.isTenant) return _isMyBed(bed);
    return false;
  }

  void _showTenantDetailsDialog(PgRoom room, PgBed bed) {
    String start = '-';
    final raw = (bed.joinDate ?? '').trim();
    if (raw.isNotEmpty) {
      final d = DateTime.tryParse(raw);
      start = d != null ? DateFormat('dd-MM-yyyy').format(d.toLocal()) : raw;
    }

    Widget row(IconData icon, String label, String? value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2F6BFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Text(
                  (value == null || value.trim().isEmpty) ? '-' : value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Tenant details · ${room.roomName} · ${bed.bedNumber}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row(Icons.person_outline_rounded, 'Name', bed.tenantName),
              row(Icons.phone_outlined, 'Mobile number', bed.tenantPhone),
              row(Icons.mail_outline_rounded, 'Email ID', bed.tenantEmail),
              row(Icons.calendar_today_outlined, 'Start date', start),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomDetailsModal(BuildContext context, PgRoom room) {
    showDialog(
      context: context,
      builder: (ctx) => _PgRoomDetailsViewDialog(
        pg: widget.pg,
        floor: _selectedFloor,
        room: room,
      ),
    );
  }

  Widget _buildDetailInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Future<void> _showMoveTenantInDialog({
    required BuildContext context,
    required PgFloor floor,
    required PgRoom room,
    required PgBed bed,
    required double rent,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => _MoveTenantInDialog(
        floor: floor,
        room: room,
        bed: bed,
        rent: rent,
      ),
    );
    if (saved == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat('#,##,###');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: const Color(0xFFF8FAFC),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxHeight: 760),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.pg.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (widget.pg.floors.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.pg.floors.map((floor) {
                    final isSelected = floor.floorName == _selectedFloor.floorName;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFloor = floor;
                            _expandedRoomIds.clear();
                            if (floor.rooms.isNotEmpty) {
                              final r = floor.rooms.first;
                              _expandedRoomIds.add(r.id.isNotEmpty ? r.id : r.roomName);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            floor.floorName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 18),

            Expanded(
              child: _selectedFloor.rooms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          const Text(
                            'No rooms added to this floor yet.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _selectedFloor.rooms.length,
                      itemBuilder: (context, index) {
                        final room = _selectedFloor.rooms[index];
                        final roomKey = room.id.isNotEmpty ? room.id : room.roomName;
                        final isExpanded = _expandedRoomIds.contains(roomKey);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedRoomIds.remove(roomKey);
                                    } else {
                                      _expandedRoomIds.add(roomKey);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF4FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.door_front_door_outlined,
                                          color: Color(0xFF2563EB),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              room.roomName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${room.totalBeds} beds · ${room.occupiedBeds} occupied',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: const Color(0xFF2563EB),
                                        size: 26,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded) ...[
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${room.roomName} beds',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${room.totalBeds} beds',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      InkWell(
                                        onTap: () => _showRoomDetailsModal(context, room),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F8FE),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFDBEAFE)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.star_outline_rounded,
                                                color: Color(0xFF2563EB),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Room details',
                                                style: TextStyle(
                                                  color: Color(0xFF2563EB),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Spacer(),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: Color(0xFF2563EB),
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      if (room.beds.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Text(
                                            'No beds configured in this room.',
                                            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                          ),
                                        )
                                      else
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: room.beds.map((bed) {
                                            final isOccupied = bed.isOccupied;
                                            final rent = bed.rentAmount > 0
                                                ? bed.rentAmount
                                                : (bed.rent > 0 ? bed.rent : room.rentPerBed);
                                            final rentFormatted = rent > 0
                                                ? '₹${currencyFmt.format(rent.toInt())}'
                                                : '₹0';

                                            if (isOccupied) {
                                              final showName = _canSeeTenant(bed);
                                              final label = (showName && (bed.tenantName ?? '').trim().isNotEmpty)
                                                  ? bed.tenantName!
                                                  : 'Occupied';

                                              return InkWell(
                                                onTap: showName ? () => _showTenantDetailsDialog(room, bed) : null,
                                                borderRadius: BorderRadius.circular(14),
                                                child: Container(
                                                  width: 120,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF8FAFC),
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.single_bed_outlined,
                                                        color: Color(0xFF64748B),
                                                        size: 24,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        label,
                                                        style: const TextStyle(
                                                          color: Color(0xFF475569),
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        rentFormatted,
                                                        style: const TextStyle(
                                                          color: Color(0xFF64748B),
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            return InkWell(
                                              onTap: () {
                                                _showMoveTenantInDialog(
                                                  context: context,
                                                  floor: _selectedFloor,
                                                  room: room,
                                                  bed: bed,
                                                  rent: rent,
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(14),
                                              child: Container(
                                                width: 120,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF0FDF4),
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: const Color(0xFF86EFAC),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.single_bed_outlined,
                                                      color: Color(0xFF16A34A),
                                                      size: 24,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    const Text(
                                                      'Vacant',
                                                      style: TextStyle(
                                                        color: Color(0xFF16A34A),
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      rentFormatted,
                                                      style: const TextStyle(
                                                        color: Color(0xFF16A34A),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PgRoomDetailsViewDialog extends StatelessWidget {
  final PgPropertyDetailData pg;
  final PgFloor floor;
  final PgRoom room;

  const _PgRoomDetailsViewDialog({
    required this.pg,
    required this.floor,
    required this.room,
  });

  static const _blue = Color(0xFF2F6BFF);
  static const _ink = Color(0xFF1E293B);
  static const _muted = Color(0xFF64748B);
  static const _line = Color(0xFFE2E8F0);
  static const _lightBlue = Color(0xFFEAF1FF);

  static const _amenityNames = [
    'Wifi',
    'Hot water',
    'AC',
    'Food',
    'Laundry',
    'Housekeeping',
    'Parking',
    'Power backup',
    'CCTV',
  ];

  String _money(num v) {
    if (v <= 0) return '0';
    return NumberFormat('#,##,###').format(v.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final rent = room.rentPerBed > 0 ? room.rentPerBed : room.rent;
    final advance = room.beds.isNotEmpty && room.beds.first.advance != null
        ? room.beds.first.advance!
        : 0;
    final payDate = pg.rentPaymentDate;
    final bedCount = room.totalBeds > 0 ? room.totalBeds : room.beds.length;
    final selected = room.amenitiesList.map((a) => a.toLowerCase()).toSet();
    final photos = room.images
        .map((i) => i.thumbnailUrl.isNotEmpty ? i.thumbnailUrl : i.url)
        .where((u) => u.isNotEmpty)
        .toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.meeting_room_outlined, color: _blue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.roomName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        Text(
                          '${floor.floorName} · $bedCount beds · Room details',
                          style: const TextStyle(fontSize: 12.5, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: _muted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _line),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  const Text(
                    'Photos',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _ink),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _lightBlue,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _blue),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_camera_outlined,
                                color: _blue, size: 22),
                            SizedBox(height: 4),
                            Text('Add',
                                style: TextStyle(color: _blue, fontSize: 12)),
                          ],
                        ),
                      ),
                      for (final url in photos)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            url,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: _lightBlue,
                              child: const Icon(Icons.broken_image_outlined,
                                  color: _muted),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Bed pricing',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _ink),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    onChanged: null,
                    title: const Text('Apply to all beds',
                        style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      '$bedCount beds',
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _box('Rent per bed', '₹ ${_money(rent)}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _box(
                          'advance Amount',
                          advance > 0 ? _money(advance) : '10000',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _box(
                    'Rent Payment Date',
                    payDate == null ? 'Select' : '$payDate',
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Amenities',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _ink),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Set common amenities for this room, then apply to every room. You can still customize any room individually.',
                    style: TextStyle(fontSize: 12.5, color: _muted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final name in [
                        ..._amenityNames,
                        ...room.amenitiesList.where((a) => !_amenityNames.any(
                            (n) => n.toLowerCase() == a.toLowerCase())),
                      ])
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected.contains(name.toLowerCase())
                                ? _lightBlue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected.contains(name.toLowerCase())
                                  ? _blue
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected.contains(name.toLowerCase())
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: selected.contains(name.toLowerCase())
                                  ? _blue
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Save',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: _muted)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _line),
          ),
          child: Text(value, style: const TextStyle(fontSize: 15, color: _ink)),
        ),
      ],
    );
  }
}

class _MoveTenantInDialog extends StatefulWidget {
  final PgFloor floor;
  final PgRoom room;
  final PgBed bed;
  final double rent;

  const _MoveTenantInDialog({
    required this.floor,
    required this.room,
    required this.bed,
    required this.rent,
  });

  @override
  State<_MoveTenantInDialog> createState() => _MoveTenantInDialogState();
}

class _MoveTenantInDialogState extends State<_MoveTenantInDialog> {
  late final TextEditingController _rentController;
  final _advanceController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _startDateController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final rentInt = widget.rent.toInt();
    _rentController = TextEditingController(
      text: rentInt > 0 ? '₹ ${NumberFormat('#,##,###').format(rentInt)}' : '',
    );
    if (widget.bed.advance != null && widget.bed.advance! > 0) {
      _advanceController.text = '₹ ${NumberFormat('#,##,###').format(widget.bed.advance!.toInt())}';
    }
  }

  @override
  void dispose() {
    _rentController.dispose();
    _advanceController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final date = _startDateController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Full name is required.',
        backgroundColor: AppTheme.accentRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid 10-digit phone number.',
        backgroundColor: AppTheme.accentRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid email address.',
        backgroundColor: AppTheme.accentRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (date.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Tenancy start date is required.',
        backgroundColor: AppTheme.accentRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    widget.bed.status = 1;
    widget.bed.tenantName = name;
    widget.bed.tenantPhone = phone;
    widget.bed.tenantEmail = email;
    widget.bed.joinDate = date;

    Navigator.of(context).pop(true);
    Get.snackbar(
      'Success',
      'Tenant "$name" moved in to ${widget.bed.bedNumber} successfully!',
      backgroundColor: AppTheme.accentGreen,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.single_bed_outlined,
                      color: Color(0xFFDC2626),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Move tenant in',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.floor.floorName} · ${widget.room.roomName} · ${widget.bed.bedNumber}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Vacant',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rent amount',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _rentController,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'advance Amount',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _advanceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            hintText: 'Enter amount',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildFieldLabel('Full name'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                decoration: _buildInputDecoration(
                  hintText: "Tenant's name",
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 18),

              _buildFieldLabel('Phone number'),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                decoration: _buildInputDecoration(
                  hintText: '90000 00000',
                  prefixIcon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 18),

              _buildFieldLabel('Gmail'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                decoration: _buildInputDecoration(
                  hintText: 'tenant@gmail.com',
                  prefixIcon: Icons.mail_outline_rounded,
                ),
              ),
              const SizedBox(height: 18),
              _buildFieldLabel('Tenancy start date'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: IgnorePointer(
                  child: TextField(
                    controller: _startDateController,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                    decoration: _buildInputDecoration(
                      hintText: 'dd-mm-yyyy',
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Move tenant in',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF475569),
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF2563EB), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}

