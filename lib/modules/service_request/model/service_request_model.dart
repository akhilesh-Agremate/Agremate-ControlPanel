class ServiceMessage {
  final String id;
  final String senderUserId;
  final String message;
  final bool isSeen;
  final DateTime sentAt;

  ServiceMessage({
    required this.id,
    required this.senderUserId,
    required this.message,
    required this.isSeen,
    required this.sentAt,
  });

  factory ServiceMessage.fromJson(Map<String, dynamic> json) {
    return ServiceMessage(
      id: json['id']?.toString() ?? '',
      senderUserId: json['senderUserId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isSeen: json['isSeen'] as bool? ?? false,
      sentAt: DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now(),
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
  final String serviceType;   // maps from 'category'
  final String description;
  final String status;        // pending, in_progress, completed, solved
  final DateTime requestDate; // maps from 'raisedDate'
  final DateTime? completedDate;
  final DateTime? preferredVisitDate;
  final String priority;
  final String landlordName;
  final String location;
  final List<Map<String, dynamic>> chatMessages; // kept for view compatibility
  final List<ServiceMessage> messages;           // parsed from API

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
    // Parse nested property object
    final propObj = json['property'] as Map<String, dynamic>?;
    final propertyId = propObj?['id']?.toString() ?? '';
    final propertyName = propObj?['name']?.toString() ?? 'Unknown Property';

    // Parse address from nested JSON string
    String propertyAddress = '';
    final rawAddr = propObj?['address'];
    if (rawAddr is String && rawAddr.isNotEmpty) {
      try {
        // Try to extract Address from JSON-encoded string
        final addrMap = _tryParseAddress(rawAddr);
        propertyAddress = addrMap ?? rawAddr;
      } catch (_) {
        propertyAddress = rawAddr;
      }
    }

    // Parse tenant
    final tenantObj = json['tenant'] as Map<String, dynamic>?;
    final tenantName = tenantObj?['name']?.toString() ?? '';
    final tenantId = tenantObj?['id']?.toString() ?? '';

    // Parse messages
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    final messages = rawMessages
        .map((m) => ServiceMessage.fromJson(m as Map<String, dynamic>))
        .toList();

    // Build chatMessages list for view compatibility
    // Determine sender role: if senderUserId == tenant id → tenant, else → landlord
    final chatMessages = messages.map((m) {
      final isTenant = tenantId.isNotEmpty && m.senderUserId == tenantId;
      return <String, dynamic>{
        'sender': isTenant ? 'tenant' : 'landlord',
        'senderName': isTenant
            ? (tenantName.isNotEmpty ? tenantName : 'Tenant')
            : 'Landlord',
        'message': m.message,
        'time': _formatTime(m.sentAt),
        'isRead': m.isSeen,
        'senderUserId': m.senderUserId,
        'sentAt': m.sentAt,
      };
    }).toList();

    return ServiceRequestModel(
      id: json['id']?.toString() ?? '',
      propertyId: propertyId,
      propertyName: propertyName,
      propertyAddress: propertyAddress,
      tenantName: tenantName,
      tenantId: tenantId,
      serviceType: _normalizeCategory(json['category']?.toString()),
      description: json['description']?.toString() ?? '',
      status: _normalizeStatus(json['status']?.toString()),
      requestDate: DateTime.tryParse(json['raisedDate']?.toString() ?? '') ?? DateTime.now(),
      completedDate: json['solvedDate'] != null
          ? DateTime.tryParse(json['solvedDate'].toString())
          : null,
      preferredVisitDate: json['preferredVisitDate'] != null
          ? DateTime.tryParse(json['preferredVisitDate'].toString())
          : null,
      priority: json['priority']?.toString() ?? 'unknown',
      landlordName: 'N/A',
      location: propertyAddress,
      chatMessages: chatMessages,
      messages: messages,
    );
  }

  static String? _tryParseAddress(String raw) {
    try {
      // Simple key extraction without dart:convert to stay import-free
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

  static String _normalizeCategory(String? raw) {
    if (raw == null) return 'Others';
    // Map API categories to AppConstants.serviceTypes
    const map = {
      'plumbing': 'Plumbing',
      'electricity': 'Electricity',
      'electrical': 'Electricity', // Add this mapping
      'pest control': 'Pest Control',
      'community': 'Community',
      'mechanical': 'Mechanical',
      'maintenance': 'Maintenance',
      'security': 'Security',
    };
    return map[raw.toLowerCase()] ?? 'Others';
  }

  static String _normalizeStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'pending':   return 'pending';
      case 'in_progress':
      case 'inprogress': return 'in_progress';
      case 'completed':
      case 'solved':    return 'completed';
      default:          return raw ?? 'pending';
    }
  }
}
