import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

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

  Future<String> uploadDocument({
    required String? propertyId,
    required int category,
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
      final response =
      await DioClient.instance.post(AppEndpoints.uploadDoc, data: form);
      final data = response.data;
      if (data is Map && data['status'] == false) {
        throw Exception(data['message'] ?? 'Upload failed');
      }
      return (data is Map ? data['message'] : null)?.toString() ??
          'Document uploaded successfully';
    } on DioException catch (e) {
      final data = e.response?.data;
      throw Exception(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : (e.message ?? 'Upload failed'),
      );
    }
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
