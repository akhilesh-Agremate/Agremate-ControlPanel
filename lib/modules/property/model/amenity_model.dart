class AmenityModel {
  final String id;
  final String name;
  final String description;
  final String type;

  const AmenityModel({
    required this.id,
    required this.name,
    this.description = '',
    this.type = '',
  });

  factory AmenityModel.fromJson(Map<String, dynamic> j) => AmenityModel(
    id: j['id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
    description: j['description']?.toString() ?? '',
    type: j['type']?.toString() ?? '',
  );
  bool get isPool => name.toLowerCase().contains('pool');
  bool get isGym => name.toLowerCase().contains('gym');

  String? get featureKey {
    final n = name.toLowerCase();
    if (n.contains('bedroom')) return 'Bedrooms';
    if (n.contains('bathroom')) return 'Bathrooms';
    if (n.contains('kitchen')) return 'Kitchen';
    if (n.contains('built')) return 'Built Year';
    return null;
  }
}