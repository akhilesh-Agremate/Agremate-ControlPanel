import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/home/model/rental_agreement_item.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class RentalAgreementRepository {
  Future<List<RentalAgreementItem>> getRentalAgreements({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.rentalAgreements,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      AppLogger.d(
        'RentalAgreementRepository',
        'getRentalAgreements status=${response.statusCode}',
      );
      final data = response.data;
      List<dynamic> list = const [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['result'] is List) {
        list = data['result'] as List;
      }
      return list
          .whereType<Map>()
          .map((e) => RentalAgreementItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stack) {
      AppLogger.e(
        'RentalAgreementRepository',
        'getRentalAgreements failed',
        e,
        stack,
      );
      rethrow;
    }
  }
}