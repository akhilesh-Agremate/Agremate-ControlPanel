import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/model/pg_property_detail_model.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class PgPropertyDetailController extends GetxController {
  final property = Rxn<PgPropertyDetailData>();
  final isLoading = false.obs;
  final loadError = Rxn<String>();
  final selectedImageIndex = 0.obs;
  final selectedFloor = Rxn<PgFloor>();
  final openDocName = Rxn<String>();
  final openDocUrl = Rxn<String>();
  final isEditing = false.obs;

  String? _currentPropertyId;

  bool get canEdit {
    if (!Get.isRegistered<AuthController>()) return true;
    final auth = Get.find<AuthController>();
    return auth.isSuperAdmin || auth.isLandlord;
  }

  bool get canDelete {
    if (!Get.isRegistered<AuthController>()) return true;
    final auth = Get.find<AuthController>();
    return !auth.isTenant;
  }

  void init(PropertyModel model) {
    if (_currentPropertyId == model.id && property.value != null) {
      return;
    }
    _currentPropertyId = model.id;
    property.value = PgPropertyDetailData.fromPropertyModel(model);
    selectedImageIndex.value = 0;
    selectedFloor.value = null;
    openDocName.value = null;
    openDocUrl.value = null;
    isEditing.value = false;
    loadById(model.id);
  }

  Future<void> loadById(String id) async {
    try {
      isLoading.value = true;
      loadError.value = null;
      _currentPropertyId = id;

      final response = await DioClient.instance.get(
        '${AppEndpoints.adminDashboardProperties}/$id',
      );

      final data = response.data;
      if (data is Map && data['result'] is Map) {
        final parsed = PgPropertyDetailData.fromJson(
          Map<String, dynamic>.from(data['result']),
        );
        property.value = parsed;
        if (selectedFloor.value != null) {
          final matched = parsed.floors.firstWhereOrNull(
            (f) => f.index == selectedFloor.value!.index,
          );
          selectedFloor.value = matched ?? (parsed.floors.isNotEmpty ? parsed.floors.first : null);
        }
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e, stack) {
      AppLogger.e('PgPropertyDetailController', 'loadById failed id=$id', e, stack);
      loadError.value = 'Failed to load PG property details: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProperty() async {
    final id = _currentPropertyId ?? property.value?.id;
    if (id != null && id.isNotEmpty) {
      await loadById(id);
    }
  }

  void selectImage(int index) {
    final max = (property.value?.photoPaths.length ?? 1) - 1;
    selectedImageIndex.value = index.clamp(0, max < 0 ? 0 : max);
  }

  void selectFloor(PgFloor? floor) {
    selectedFloor.value = floor;
  }

  void openDocument(String name, String url) {
    openDocName.value = name;
    openDocUrl.value = url;
  }

  void closeDocument() {
    openDocName.value = null;
    openDocUrl.value = null;
  }

  void startEdit() {
    if (Get.isRegistered<PropertyController>()) {
      final pc = Get.find<PropertyController>();
      if (pc.amenities.isEmpty) pc.fetchAmenities();
      if (pc.featureOptions.isEmpty) pc.fetchFeatures();
    }
    isEditing.value = true;
  }

  void stopEdit() {
    isEditing.value = false;
  }

  String get locationLine {
    final addr = property.value?.address ?? '';
    return addr.trim().isNotEmpty ? addr : 'Address not set';
  }

  String get headerStatusLabel {
    return property.value?.status ?? 'Available';
  }

  int get totalBedsCount => property.value?.totalBeds ?? 0;
  int get occupiedBedsCount => property.value?.occupiedBeds ?? 0;
  int get vacantBedsCount => property.value?.availableBeds ?? 0;

  Future<void> shareLocation(BuildContext context) async {
    final lat = property.value?.latitude;
    final lng = property.value?.longitude;
    final url = (lat != null && lng != null)
        ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationLine)}';

    await Clipboard.setData(ClipboardData(text: url));
    Get.snackbar(
      'Copied',
      'Location link copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () => openGoogleMaps(),
        child: const Text('OPEN', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> openGoogleMaps() async {
    final lat = property.value?.latitude;
    final lng = property.value?.longitude;
    final url = (lat != null && lng != null)
        ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationLine)}';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void confirmDelete(BuildContext context) {
    final currentProp = property.value;
    final propId = currentProp?.id ?? _currentPropertyId;
    final propName = currentProp?.name ?? 'this property';
    if (propId == null || propId.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Property', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "$propName"?\n\n'
          'Property delete request will be submitted. It will be hidden after 24 hours and permanently deleted after 3 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (Get.isRegistered<PropertyController>()) {
                await Get.find<PropertyController>().deleteProperty(propId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
