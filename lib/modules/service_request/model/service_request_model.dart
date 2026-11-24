class ServiceMessage {
  final String id;
  final String senderUserId;
  final String senderName;
  final String senderRole;
  final String message;
  final bool isSeen;
  final DateTime sentAt;

  ServiceMessage({
    required this.id,
    required this.senderUserId,
    this.senderName = '',
    this.senderRole = '',
    required this.message,
    required this.isSeen,
    required this.sentAt,
  });

  factory ServiceMessage.fromJson(Map<String, dynamic> json) {
    return ServiceMessage(
      id: json['id']?.toString() ?? '',
      senderUserId:
          json['senderUserId']?.toString() ??
          json['senderId']?.toString() ??
          json['userId']?.toString() ??
          '',
      senderName:
          json['senderName']?.toString() ?? json['name']?.toString() ?? '',
      senderRole:
          json['senderRole']?.toString() ??
          json['role']?.toString() ??
          json['senderType']?.toString() ??
          json['sender']?.toString() ??
          '',
      message:
          json['message']?.toString() ??
          json['text']?.toString() ??
          json['content']?.toString() ??
          '',
      isSeen: json['isSeen'] as bool? ?? json['isRead'] as bool? ?? false,
      sentAt:
          DateTime.tryParse(
            json['sentAt']?.toString() ??
                json['createdAt']?.toString() ??
                json['time']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }
}

class ServiceRequestModel {
  final String id;
  final String propertyId;
  final String propertyName;
  final String propertyAddress;
  final String tenantName;
  final String tenantId;
  final String serviceType;
  final String description;
  final String status;
  final DateTime requestDate;
  final DateTime? completedDate;
  final DateTime? preferredVisitDate;
  final String priority;
  final String landlordName;
  final String location;
  final List<Map<String, dynamic>> chatMessages;
  final List<ServiceMessage> messages;

  ServiceRequestModel({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    this.propertyAddress = '',
    required this.tenantName,
    this.tenantId = '',
    required this.serviceType,
    required this.description,
    this.status = 'pending',
    required this.requestDate,
    this.completedDate,
    this.preferredVisitDate,
    this.priority = 'unknown',
    this.landlordName = 'N/A',
    this.location = '',
    this.chatMessages = const [],
    this.messages = const [],
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed' || status == 'solved';

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    final propObj = json['property'] as Map<String, dynamic>?;
    final tenantObj = json['tenant'] as Map<String, dynamic>?;

    final propertyId =
        json['propertyId']?.toString() ?? propObj?['id']?.toString() ?? '';
    final propertyName =
        json['propertyName']?.toString() ??
        propObj?['name']?.toString() ??
        'Unknown Property';

    String propertyAddress = '';
    final rawAddr = propObj?['address'];
    if (rawAddr is String && rawAddr.isNotEmpty) {
      propertyAddress = _tryParseAddress(rawAddr) ?? rawAddr;
    }

    final tenantName =
        json['tenantName']?.toString() ?? tenantObj?['name']?.toString() ?? '';
    final tenantId =
        json['tenantId']?.toString() ?? tenantObj?['id']?.toString() ?? '';
    final landlordName =
        json['landlordName']?.toString().isNotEmpty == true
            ? json['landlordName'].toString()
            : 'N/A';

    final tenantMessage = json['tenantMessage']?.toString().trim() ?? '';
    final landlordMessage = json['landlordMessage']?.toString().trim() ?? '';

    final rawMessages = json['messages'] as List<dynamic>? ??
        json['chatMessages'] as List<dynamic>? ??
        json['chat'] as List<dynamic>? ??
        [];
    final messages = rawMessages
        .whereType<Map>()
        .map((m) => ServiceMessage.fromJson(Map<String, dynamic>.from(m)))
        .toList();


    final chatMessages = <Map<String, dynamic>>[];
    final rawMaps = rawMessages.whereType<Map>().toList();

    if (messages.isNotEmpty) {
      for (var i = 0; i < messages.length; i++) {
        final m = messages[i];
        final raw = rawMaps[i];

        final attachments = _readAttachments(raw);
        if (raw['isAttachment'] == true) {
        }

        final isFileMsg = raw['isAttachment'] == true;
        if (m.message.trim().isEmpty && attachments.isEmpty && !isFileMsg) {
          continue;
        }

        final sender = _senderKind(
          senderUserId: m.senderUserId,
          senderName: m.senderName,
          senderRole: m.senderRole,
          tenantId: tenantId,
          tenantName: tenantName,
          landlordName: landlordName,
        );
        String senderName;
        if (sender == 'admin') {
          senderName = 'Support Team';
        } else if (sender == 'tenant') {
          senderName = m.senderName.isNotEmpty
              ? m.senderName
              : (tenantName.isNotEmpty ? tenantName : 'Tenant');
        } else {
          senderName = m.senderName.isNotEmpty
              ? m.senderName
              : (landlordName != 'N/A' ? landlordName : 'Landlord');
        }

        chatMessages.add({
          'sender': sender,
          'senderName': senderName,
          'message': (m.message.trim().isEmpty && attachments.isEmpty && isFileMsg)
              ? '📎 Attachment'
              : m.message,
          'time': _formatTime(m.sentAt),
          'isRead': m.isSeen,
          'senderUserId': m.senderUserId,
          'sentAt': m.sentAt,
          if (attachments.isNotEmpty) 'attachments': attachments,
          if (attachments.isNotEmpty) 'attachmentName': attachments.first['name'],
          if (attachments.isNotEmpty &&
              (attachments.first['url'] ?? '').isNotEmpty)
            'attachmentUrl': attachments.first['url'],
        });
      }
      chatMessages.sort((a, b) {
        final da = a['sentAt'];
        final db = b['sentAt'];
        if (da is DateTime && db is DateTime) return da.compareTo(db);
        return 0;
      });
    }

    final hasTenantChat = chatMessages.any((m) => m['sender'] == 'tenant');
    if (tenantMessage.isNotEmpty && !hasTenantChat) {
      chatMessages.insert(0, {
        'sender': 'tenant',
        'senderName': tenantName.isNotEmpty ? tenantName : 'Tenant',
        'message': tenantMessage,
        'time': '',
        'isRead': true,
      });
    }
    final existingTexts = chatMessages
        .map((m) => (m['message'] as String).trim().toLowerCase())
        .toSet();
    if (landlordMessage.isNotEmpty &&
        !existingTexts.contains(landlordMessage.toLowerCase())) {
      chatMessages.add({
        'sender': 'landlord',
        'senderName': landlordName != 'N/A' ? landlordName : 'Landlord',
        'message': landlordMessage,
        'time': '',
        'isRead': true,
      });
    }

    return ServiceRequestModel(
      id: json['id']?.toString() ??
          json['maintenanceRequestId']?.toString() ??
          '',
      propertyId: propertyId,
      propertyName: propertyName,
      propertyAddress: propertyAddress,
      tenantName: tenantName,
      tenantId: tenantId,
      serviceType: normalizeCategory(json['category']?.toString()),
      description:
          json['description']?.toString() ??
          json['issueTitle']?.toString() ??
          '',
      status: _normalizeStatus(json['status']?.toString()),
      requestDate:
          DateTime.tryParse(
            json['requestedDate']?.toString() ??
                json['raisedDate']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      completedDate: DateTime.tryParse(
        json['closedDate']?.toString() ?? json['solvedDate']?.toString() ?? '',
      ),
      preferredVisitDate: json['preferredVisitDate'] != null
          ? DateTime.tryParse(json['preferredVisitDate'].toString())
          : null,
      priority: json['priority']?.toString() ?? 'unknown',
      landlordName: landlordName,
      location: propertyAddress,
      chatMessages: chatMessages,
      messages: messages,
    );
  }
  static List<Map<String, String>> _readAttachments(Map raw) {
    final atts = raw['attachments'] ??
        raw['fileAttachments'] ??
        raw['files'] ??
        raw['documents'] ??
        raw['media'] ??
        raw['images'];
    final out = <Map<String, String>>[];
    if (atts is List) {
      for (final item in atts) {
        final one = _oneAttachment(item);
        if (one != null) out.add(one);
      }
    }
    if (out.isEmpty) {
      final direct = _oneAttachment(raw);
      if (direct != null &&
          (raw['fileUrl'] != null ||
              raw['attachmentUrl'] != null ||
              raw['imageUrl'] != null ||
              raw['absolutePath'] != null ||
              raw['url'] != null ||
              raw['thumbnailUrl'] != null)) {
        out.add(direct);
      }
    }
    return out;
  }

  static Map<String, String>? _oneAttachment(dynamic item) {
    if (item is! Map) {
      final s = item?.toString().trim() ?? '';
      if (s.isEmpty || s == 'null') return null;
      if (!s.startsWith('http') && !s.contains('.')) return null;
      return {
        'name': s.split('?').first.split('/').last,
        'url': _fileUrl(s),
        'thumb': '',
      };
    }
    final name = _pick(item, [
          'fileName',
          'name',
          'originalName',
          'originalFileName',
        ]) ??
        '';
    final url = _fileUrl(_pick(item, [
      'absolutePath',
      'fileUrl',
      'url',
      'fileURL',
      'attachmentUrl',
      'signedUrl',
      'presignedUrl',
      'imageUrl',
      'mediaUrl',
      'filePath',
      'path',
      'relativePath',
      'location',
    ]) ??
        '');
    final thumb = _fileUrl(_pick(item, ['thumbnailUrl', 'thumbnailPath']) ?? '');
    if (name.isEmpty && url.isEmpty && thumb.isEmpty) return null;
    final shown = name.isNotEmpty
        ? name
        : (url.isNotEmpty ? url : thumb).split('?').first.split('/').last;
    return {'name': shown, 'url': url.isNotEmpty ? url : thumb, 'thumb': thumb};
  }

  static String _fileUrl(String path) {
    final value = path.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://amplify-agremate-dev-76a83-deployment.s3.ap-south-1.amazonaws.com/${value.startsWith('/') ? value.substring(1) : value}';
  }

  static String? _pick(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return null;
  }

  static String _senderKind({
    required String senderUserId,
    required String senderName,
    required String senderRole,
    required String tenantId,
    required String tenantName,
    required String landlordName,
  }) {
    final role = senderRole.toLowerCase().replaceAll(' ', '');
    if (role.contains('superadmin') ||
        role.contains('admin') ||
        role.contains('support')) {
      return 'admin';
    }
    if (role.contains('landlord')) return 'landlord';
    if (role.contains('tenant')) return 'tenant';
    if (tenantId.isNotEmpty && senderUserId == tenantId) return 'tenant';
    final name = senderName.trim().toLowerCase();
    final tenant = tenantName.trim().toLowerCase();
    if (tenant.isNotEmpty && name == tenant) return 'tenant';
    final landlord = landlordName.trim().toLowerCase();
    if (landlord.isNotEmpty && landlord != 'n/a' && name == landlord) {
      return 'landlord';
    }
    return 'tenant';
  }

  static String? _tryParseAddress(String raw) {
    try {
      final match = RegExp(r'"Address"\s*:\s*"([^"]+)"').firstMatch(raw);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  static String _formatTime(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$min $ampm';
  }

  static String normalizeCategory(String? raw) {
    if (raw == null || raw.isEmpty) return 'Others';
    final key = raw.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    const map = {
      'plumbing': 'Plumbing',
      'electricity': 'Electricity',
      'electrical': 'Electricity',
      'pestcontrol': 'Pest Control',
      'community': 'Community',
      'mechanical': 'Mechanical',
      'maintenance': 'Maintenance',
      'security': 'Security',
      'securityandaccess': 'Security',
      'other': 'Others',
      'others': 'Others',
    };
    return map[key] ?? 'Others';
  }

  static String _normalizeStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'pending':
        return 'pending';
      case 'accepted':
        return 'accepted';
      case 'rejected':
        return 'rejected';
      case 'in_progress':
      case 'inprogress':
        return 'in_progress';
      case 'completed':
      case 'solved':
        return 'completed';
      default:
        return (raw ?? 'pending').toLowerCase();
    }
  }
}
