class Sauna {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final double pricePerHour;
  final String imageUrl;
  final bool isActive;

  Sauna({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.pricePerHour,
    required this.imageUrl,
    this.isActive = true,
  });

  factory Sauna.fromMap(Map<String, dynamic> map, String documentId) {
    return Sauna(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      capacity: map['capacity'] ?? 0,
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'capacity': capacity,
      'pricePerHour': pricePerHour,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
