import 'package:get/get.dart';

class SupportController extends GetxController {
  final name = ''.obs;
  final email = ''.obs;
  final message = ''.obs;
  final isSubmitting = false.obs;
  final isSubmitted = false.obs;

  final faqs = [
    {'q': 'How do I add a new landlord?', 'a': 'Go to the Property section and click the "Add Landlord" button in the top right corner. Fill in the required details and submit.'},
    {'q': 'How do I view tenant details?', 'a': 'Navigate to the Property section and click on any tenant badge in the recent logins list to see their rented property details.'},
    {'q': 'How do I track rent payments?', 'a': 'Go to the Finance section where you can see all rented properties. Click on any property to view month-wise rent payment history.'},
    {'q': 'How do I manage service requests?', 'a': 'The Services section shows all 8 service categories. Click on any category card to see properties that have requested that specific service.'},
    {'q': 'How do I access documents?', 'a': 'The Documents section works like Google Drive. Navigate through Landlord and Tenant folders to find specific documents.'},
    {'q': 'How do I contact support?', 'a': 'You can reach us at contact@agremate.com or call +91 9876543210. You can also submit a ticket through the form below.'},
  ];

  void submitTicket() async {
    if (name.value.isEmpty || email.value.isEmpty || message.value.isEmpty) return;
    isSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSubmitting.value = false;
    isSubmitted.value = true;
    Future.delayed(const Duration(seconds: 3), () { isSubmitted.value = false; });
    name.value = '';
    email.value = '';
    message.value = '';
  }
}
