import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import '../model/support_ticket_model.dart';

class SupportTicketRepository {
  dynamic _unwrap(dynamic response) {
    final body = response.data;
    if (body is Map && body['status'] == false) {
      throw Exception(body['message'] ?? 'Request failed');
    }
    return body is Map ? body['result'] : body;
  }

  Future<SupportListResult> getAll({
    int? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await DioClient.instance.get(
      AppEndpoints.supportTickets,
      queryParameters: {
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return SupportListResult.fromJson(Map<String, dynamic>.from(_unwrap(r)));
  }

  Future<SupportListResult> getMy({int? status}) async {
    final r = await DioClient.instance.get(
      AppEndpoints.supportTicketsMy,
      queryParameters: {if (status != null) 'status': status},
    );
    final list = (_unwrap(r) as List? ?? [])
        .map((e) => SupportTicketModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return SupportListResult(null, list, list.length);
  }

  Future<SupportTicketDetail> getDetail(String id) async {
    final r = await DioClient.instance.get(AppEndpoints.supportTicketDetail(id));
    return SupportTicketDetail.fromJson(Map<String, dynamic>.from(_unwrap(r)));
  }

  Future<void> markSeen(String id) async {
    _unwrap(await DioClient.instance.post(AppEndpoints.supportTicketSeen(id)));
  }

  Future<void> sendMessage(String id, String message,
      {bool isInternal = false}) async {
    _unwrap(await DioClient.instance.post(
      AppEndpoints.supportTicketMessages(id),
      data: {
        'message': message,
        'isInternal': isInternal,
        'documentDetailIds': <String>[],
      },
    ));
  }

  Future<void> updateStatus(String id, int newStatus,
      {String? notes, String? resolutionNote}) async {
    _unwrap(await DioClient.instance.patch(
      AppEndpoints.supportTicketStatus(id),
      data: {
        'newStatus': newStatus,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (resolutionNote != null && resolutionNote.isNotEmpty)
          'resolutionNote': resolutionNote,
      },
    ));
  }
}