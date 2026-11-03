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
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = ''.obs;

  Future<void> toggleContactMask(bool value) async {
    if (isUpdating.value) return;
    final prevValue = isContactMaskEnabled.value;
    isContactMaskEnabled.value = value;
    isUpdating.value = true;

    try {
      final response = await _repository.setLandlordContactAccess(value);
      final dynamic resResult = response['result'];
      if (resResult is bool) {
        isContactMaskEnabled.value = resResult;
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
