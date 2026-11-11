import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../model/document_category.dart';

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

  Future<List<DocumentModel>> getPropertyDocuments(String propertyId) async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.getPropertyDocumentByPropertyId,
        queryParameters: {'propertyId': propertyId},
      );
      final data = response.data;
      final List<dynamic> result;
      if (data is List) {
        result = data;
      } else if (data is Map && data['result'] is List) {
        result = data['result'] as List<dynamic>;
      } else if (data is Map && data['result'] is Map) {
        result = [data['result']];
      } else {
        result = [];
      }
      return result
          .whereType<Map>()
          .map((json) => DocumentModel.fromPropertyDocumentApi(
              Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DocumentCategory>> getDocumentCategories() async {
    try {
      final response =
      await DioClient.instance.get(AppEndpoints.documentCategories);
      final data = response.data;

      if (data is Map && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to load categories');
      }

      final raw = data is Map ? data['result'] : data;
      if (raw is! List) return [];

      return raw
          .whereType<Map>()
          .map((e) => DocumentCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, 'Failed to load categories'));
    }
  }

  Future<List<DocumentEntity>> getEntitiesByCategory(int category) async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.entitiesByCategory,
        queryParameters: {
          'category': category,
          'page': 1,
          'pageSize': 50,
        },
      );
      final data = response.data;
      if (data is Map && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to load entities');
      }
      final raw = data is Map ? data['result'] : data;
      final list = raw is List
          ? raw
          : raw is Map
              ? (raw['items'] ?? raw['data'] ?? raw['entities'] ?? const [])
              : const [];
      if (list is! List) return [];
      return list
          .whereType<Map>()
          .map((e) => DocumentEntity.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, 'Failed to load entities'));
    }
  }

  Future<Map<String, dynamic>?> uploadDocument({
    required String? propertyId,
    required String category,
    required PlatformFile file,
    required String fileName,
  }) async {
    final bytes = await _readBytes(file);
    if (bytes == null) throw Exception('Could not read the selected file.');
    try {
      final form = FormData.fromMap({
        'files': MultipartFile.fromBytes(bytes, filename: fileName),
        'documentCategory': category,
        if (propertyId != null && propertyId.isNotEmpty) 'id': propertyId,
      });
      final response = await DioClient.instance.post(
        AppEndpoints.uploadDoc,
        data: form,
      );
      final data = response.data;
      if (data is Map && data['status'] == false) {
        throw Exception(data['message'] ?? 'Upload failed');
      }
      if (data is Map) {
        final result = data['result'];
        final firstResult = (result is List && result.isNotEmpty)
            ? Map<String, dynamic>.from(result.first as Map)
            : null;
        return <String, dynamic>{
          'message': (data['message'] ?? 'Document uploaded successfully').toString(),
          if (firstResult != null) ...firstResult,
        };
      }
      return <String, dynamic>{
        'message': 'Document uploaded successfully',
      };
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, 'Upload failed'));
    }
  }

  String _dioMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    final code = e.response?.statusCode;
    if (code != null) return '$fallback ($code)';
    return fallback;
  }

  Future<List<int>?> _readBytes(PlatformFile file) async {
    final f = file as dynamic;
    try {
      final b = await f.xFile.readAsBytes();
      if (b != null) return List<int>.from(b);
    } catch (_) {}
    try {
      final chunks = <int>[];
      await for (final c in (f.readStream as Stream<List<int>>)) {
        chunks.addAll(c);
      }
      if (chunks.isNotEmpty) return chunks;
    } catch (_) {}
    return null;
  }

  Future<String> softDeleteDocument(List<String> ids) async {
    Object? lastError;
    for (final id in ids) {
      try {
        final response = await DioClient.instance
            .delete(AppEndpoints.deleteDocument(id));
        final data = response.data;
        if (data is Map && data['status'] == true) {
          return (data['message'] ?? 'Document deleted successfully')
              .toString();
        }
        lastError = Exception(
          data is Map ? (data['message'] ?? 'Delete failed') : 'Delete failed',
        );
      } on DioException catch (e) {
        final data = e.response?.data;
        lastError = Exception(
          data is Map && data['message'] != null
              ? data['message'].toString()
              : (e.message ?? 'Delete failed'),
        );
        if (e.response?.statusCode != 404) throw lastError;
      }
    }
    throw lastError ?? Exception('Delete failed');
  }
}
