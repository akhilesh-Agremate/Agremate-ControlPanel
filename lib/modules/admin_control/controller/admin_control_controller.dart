import 'dart:typed_data';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_toast.dart';
import '../repository/admin_control_repository.dart';

class AdminControlController extends GetxController {
  final AdminControlRepository _repository;

  AdminControlController([AdminControlRepository? repository])
      : _repository = repository ??
            (Get.isRegistered<AdminControlRepository>()
                ? Get.find<AdminControlRepository>()
                : AdminControlRepository());

  final isContactMaskEnabled = false.obs;
  final isUpdating = false.obs;
  final isCreatingArticle = false.obs;
  final isGrantingAccess = false.obs;
  final errorMessage = ''.obs;
  bool _loadingContact = false;

  Future<void> loadLandlordContactAccess() async {
    if (_loadingContact || isUpdating.value) return;
    _loadingContact = true;
    try {
      isContactMaskEnabled.value =
          await _repository.getLandlordContactAccess();
    } catch (e) {
      final err = e.toString().replaceFirst('Exception: ', '');
      AppToast.error(
        err.isNotEmpty ? err : 'Failed to load landlord contact access',
      );
    } finally {
      _loadingContact = false;
    }
  }

  Future<bool> grantArticleAccess({
    required String phoneNumber,
    String? userId,
    bool grant = true,
  }) async {
    try {
      isGrantingAccess.value = true;
      final response = await _repository.grantArticleAccess(
        phoneNumber: phoneNumber,
        userId: userId,
        grant: grant,
      );
      final message = response['message']?.toString() ??
          'Dashboard access granted successfully for $phoneNumber.';
      AppToast.success(message);
      return true;
    } catch (e) {
      final err = e.toString().replaceFirst('Exception: ', '');
      AppToast.error(err.isNotEmpty ? err : 'Failed to grant access');
      return false;
    } finally {
      isGrantingAccess.value = false;
    }
  }

  Future<bool> createArticle({
    required String title,
    required String description,
    String? category,
    String? tags,
    String? sourceName,
    String? sourceLogoUrl,
    bool isTrending = false,
    bool isSourceVerified = false,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      isCreatingArticle.value = true;
      final response = await _repository.createArticle(
        title: title,
        description: description,
        category: category,
        tags: tags,
        sourceName: sourceName,
        sourceLogoUrl: sourceLogoUrl,
        isTrending: isTrending,
        isSourceVerified: isSourceVerified,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      final message = response['message']?.toString() ?? 'Article created successfully';
      AppToast.success(message);
      return true;
    } catch (e) {
      final err = e.toString().replaceFirst('Exception: ', '');
      AppToast.error(err.isNotEmpty ? err : 'Failed to create article');
      return false;
    } finally {
      isCreatingArticle.value = false;
    }
  }

  Future<void> toggleContactMask(bool value) async {
    if (isUpdating.value) return;
    final prevValue = isContactMaskEnabled.value;
    isContactMaskEnabled.value = value;
    isUpdating.value = true;

    try {
      final response = await _repository.setLandlordContactAccess(value);
      final dynamic resResult = response['result'];
      if (resResult is Map && resResult['isActive'] is bool) {
        isContactMaskEnabled.value = resResult['isActive'] as bool;
      }

      final message = response['message']?.toString() ??
          (value
              ? AppStrings.contactMaskEnabledMessage
              : AppStrings.contactMaskDisabledMessage);

      AppToast.success(message);
    } catch (e) {
      isContactMaskEnabled.value = prevValue;
      final err = e.toString().replaceFirst('Exception: ', '');
      AppToast.error(
        err.isNotEmpty ? err : AppStrings.updateSettingFailed,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
