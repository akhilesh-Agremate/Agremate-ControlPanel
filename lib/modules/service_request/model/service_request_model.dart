class ServiceRequestModel {
  final String id;
  final String propertyId;
  final String propertyName;
  final String tenantName;
  final String serviceType;
  final String description;
  final String status; // pending, in_progress, completed
  final DateTime requestDate;
  final DateTime? completedDate;
  final String priority; // low, medium, high

  ServiceRequestModel({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.tenantName,
    required this.serviceType,
    required this.description,
    this.status = 'pending',
    required this.requestDate,
    this.completedDate,
    this.priority = 'medium',
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
}
