import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class AdminControlRepository {
  Future<bool> getLandlordContactAccess() async {
    AppLogger.i('AdminControlRepository', 'getLandlordContactAccess');
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.landlordContactAccessStatus,
      );
      final data = response.data;
      if (data is Map && data['status'] == false) {
        throw Exception(
          data['message'] ?? 'Failed to load landlord contact access',
        );
      }
      final result = data is Map ? data['result'] : null;
      if (result is Map && result['isActive'] is bool) {
        return result['isActive'] as bool;
      }
      return false;
    } on DioException catch (e) {
      final body = e.response?.data;
      throw Exception(body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Failed to load landlord contact access');
    }
  }

  Future<Map<String, dynamic>> setLandlordContactAccess(bool isActive) async {
    AppLogger.i('AdminControlRepository', 'setLandlordContactAccess isActive=$isActive');
    try {
      final response = await DioClient.instance.patch(
        AppEndpoints.landlordContactAccessStatus,
        data: {'isActive': isActive},
      );
      final data = response.data;
      if (data is Map && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to update landlord contact access');
      }
      if (data is Map) return Map<String, dynamic>.from(data);
      return {'status': true, 'result': {'isActive': isActive}};
    } on DioException catch (e) {
      final body = e.response?.data;
      throw Exception(body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Failed to update landlord contact access');
    }
  }

  Future<Map<String, dynamic>> createArticle({
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
    String? publishedAt,
  }) async {
    AppLogger.i('AdminControlRepository', 'createArticle started');
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('Title', title),
        MapEntry('Description', description),
        MapEntry('Category', category ?? ''),
        MapEntry('Tags', tags ?? ''),
        MapEntry('SourceName', sourceName ?? ''),
        MapEntry('SourceLogoUrl', sourceLogoUrl ?? ''),
        MapEntry('IsTrending', isTrending.toString()),
        MapEntry('IsSourceVerified', isSourceVerified.toString()),
        MapEntry('PublishedAt', publishedAt ?? DateTime.now().toUtc().toIso8601String()),
      ]);

      if (imageBytes != null && imageBytes.isNotEmpty) {
        final fileName = imageName ?? 'image.jpg';
        formData.files.add(MapEntry(
          'heroImage',
          MultipartFile.fromBytes(imageBytes, filename: fileName),
        ));
        formData.files.add(MapEntry(
          'thumbnailImage',
          MultipartFile.fromBytes(imageBytes, filename: fileName),
        ));
      }

      final response = await DioClient.instance.post(
        AppEndpoints.createArticle,
        data: formData,
      );

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map && data['status'] == false) {
          throw Exception(data['message'] ?? 'Failed to create article');
        }
        return data is Map ? Map<String, dynamic>.from(data) : {};
      }
      throw Exception(data is Map
          ? (data['message'] ?? 'Failed to create article')
          : 'Status code: ${response.statusCode}');
    } catch (e, stack) {
      AppLogger.e('AdminControlRepository', 'createArticle failed', e, stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> grantArticleAccess({
    required String phoneNumber,
    String? userId,
    bool grant = true,
  }) async {
    AppLogger.i('AdminControlRepository', 'grantArticleAccess started for $phoneNumber');
    try {
      final body = <String, dynamic>{
        'phoneNumber': phoneNumber,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        'grant': grant,
      };

      final response = await DioClient.instance.post(
        AppEndpoints.articleGrantAccess,
        data: body,
      );

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map && data['status'] == false) {
          throw Exception(data['message'] ?? 'Failed to grant access');
        }
        return data is Map ? Map<String, dynamic>.from(data) : {};
      }
      throw Exception(data is Map
          ? (data['message'] ?? 'Failed to grant access')
          : 'Status code: ${response.statusCode}');
    } catch (e, stack) {
      AppLogger.e('AdminControlRepository', 'grantArticleAccess failed', e, stack);
      rethrow;
    }
  }
}
