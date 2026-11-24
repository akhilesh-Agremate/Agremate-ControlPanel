import 'package:dio/dio.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/support/model/support_faq.dart';

class SupportRepository {
  Future<List<SupportFaq>> getFaqs({bool includeInactive = false}) async {
    final response = await DioClient.instance.get(
      AppEndpoints.supportFaqs,
      queryParameters: includeInactive ? {'includeInactive': true} : null,
    );
    final data = response.data;
    if (data is Map && data['status'] == false) {
      throw Exception(data['message'] ?? 'Failed to load FAQs');
    }
    final result = data is Map ? data['result'] : data;
    if (result is! List) return [];
    return result
        .whereType<Map>()
        .map((e) => SupportFaq.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<String> createFaq({
    required String question,
    required String answer,
    String? category,
    int displayOrder = 0,
  }) async {
    final response = await DioClient.instance.post(
      AppEndpoints.supportFaqs,
      data: {
        'question': question,
        'answer': answer,
        'category': (category ?? '').trim(),
        'displayOrder': displayOrder,
        'isActive': true,
      },
    );
    return _message(response.data, 'FAQ created successfully.');
  }

  Future<String> updateFaq(SupportFaq faq, {bool? isActive}) async {
    final response = await DioClient.instance.put(
      '${AppEndpoints.supportFaqs}/${faq.id}',
      data: faq.toBody(active: isActive),
    );
    return _message(response.data, 'FAQ updated successfully.');
  }

  Future<String> deleteFaq(String id) async {
    final response = await DioClient.instance.delete(
      '${AppEndpoints.supportFaqs}/$id',
    );
    return _message(response.data, 'FAQ deleted successfully.');
  }

  String _message(dynamic data, String fallback) {
    if (data is Map && data['status'] == false) {
      throw Exception(data['message'] ?? fallback);
    }
    if (data is Map && data['message'] != null) {
      final text = data['message'].toString();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return fallback;
  }

  String errorText(Object error, String fallback) {
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    }
    final text = error.toString().replaceFirst('Exception: ', '');
    return text.isEmpty ? fallback : text;
  }
}
