import 'package:get/get.dart';
import 'package:agremate_admin/core/widgets/app_toast.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/modules/support/model/support_faq.dart';
import 'package:agremate_admin/modules/support/repository/support_repository.dart';

class SupportController extends GetxController {
  final SupportRepository _repository = SupportRepository();

  final faqs = <SupportFaq>[].obs;
  final isFaqsLoading = false.obs;
  final faqError = ''.obs;
  final selectedCategory = 'All'.obs;
  final faqQuery = ''.obs;
  final isSavingFaq = false.obs;

  bool get isSuperAdmin {
    if (!Get.isRegistered<AuthController>()) return false;
    return Get.find<AuthController>().isSuperAdmin;
  }

  List<String> get categories {
    final names = <String>[];
    for (final faq in faqs) {
      final name = faq.category.trim();
      if (name.isNotEmpty && !names.contains(name)) names.add(name);
    }
    return names;
  }

  List<SupportFaq> get visibleFaqs {
    final query = faqQuery.value.trim().toLowerCase();
    final category = selectedCategory.value;
    return faqs.where((faq) {
      if (category != 'All' &&
          faq.category.trim().toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query.isEmpty) return true;
      return faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
  }

  Future<void> fetchFaqs() async {
    try {
      isFaqsLoading.value = true;
      faqError.value = '';
      faqs.assignAll(
        await _repository.getFaqs(includeInactive: isSuperAdmin),
      );
    } catch (e) {
      faqError.value = _repository.errorText(e, 'Failed to load FAQs');
    } finally {
      isFaqsLoading.value = false;
    }
  }

  Future<bool> createFaq({
    required String question,
    required String answer,
    String? category,
  }) async {
    try {
      isSavingFaq.value = true;
      final message = await _repository.createFaq(
        question: question.trim(),
        answer: answer.trim(),
        category: category,
        displayOrder: faqs.length + 1,
      );
      AppToast.success(message);
      await fetchFaqs();
      return true;
    } catch (e) {
      AppToast.error(_repository.errorText(e, 'Failed to create FAQ'));
      return false;
    } finally {
      isSavingFaq.value = false;
    }
  }

  Future<bool> updateFaq(SupportFaq faq) async {
    try {
      isSavingFaq.value = true;
      final message = await _repository.updateFaq(faq);
      AppToast.success(message);
      await fetchFaqs();
      return true;
    } catch (e) {
      AppToast.error(_repository.errorText(e, 'Failed to update FAQ'));
      return false;
    } finally {
      isSavingFaq.value = false;
    }
  }

  Future<void> toggleFaq(SupportFaq faq) async {
    try {
      final message = await _repository.updateFaq(faq, isActive: !faq.isActive);
      AppToast.success(message);
      await fetchFaqs();
    } catch (e) {
      AppToast.error(_repository.errorText(e, 'Failed to update FAQ'));
    }
  }

  Future<void> deleteFaq(SupportFaq faq) async {
    try {
      final message = await _repository.deleteFaq(faq.id);
      AppToast.success(message);
      await fetchFaqs();
    } catch (e) {
      AppToast.error(_repository.errorText(e, 'Failed to delete FAQ'));
    }
  }
}
