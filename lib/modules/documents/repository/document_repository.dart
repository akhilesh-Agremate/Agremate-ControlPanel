import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';

class DocumentRepository {
  Future<List<DocumentModel>> getAllDocuments() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.allDocuments);

      final List<dynamic> result;
      if (response.data is List) {
        result = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['result'] != null) {
        result = response.data['result'] is List
            ? response.data['result'] as List<dynamic>
            : [response.data['result']];
      } else if (response.data is Map) {
        return [DocumentModel.fromJson(response.data as Map<String, dynamic>)];
      } else {
        result = [];
      }

      return result
          .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
