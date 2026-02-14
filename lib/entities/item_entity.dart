import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemCondition {
  newCondition("New"),
  good("Good"),
  fair("Fair"),
  poor("Poor");

  final String value;
  const ItemCondition(this.value);
}

enum ItemCategory {
  electronics("Electronics"),
  furniture("Furniture"),
  bedding("Bedding"),
  clothing("Clothing"),
  vehicles("Vehicles"),
  others("Others");

  final String value;
  const ItemCategory(this.value);
}

class ItemEntity {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String condition;
  final String category;
  final double sellerPrice;
  final double basePrice;
  final String imageLink;
  final bool available;
  final DateTime dateCreated;
  final DateTime? expiryDate; // Added Expiry Date
  final double? latitude;
  final double? longitude;

  ItemEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.condition,
    required this.category,
    required this.sellerPrice,
    required this.basePrice,
    required this.imageLink,
    required this.available,
    required this.dateCreated,
    this.expiryDate,
    this.latitude,
    this.longitude,
  });

  factory ItemEntity.fromMap(Map<String, dynamic> map, String docId) {
    return ItemEntity(
      id: docId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      condition: map['condition'] ?? 'Fair',
      category: map['category'] ?? 'Others',
      sellerPrice: (map['sellerPrice'] ?? 0).toDouble(),
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      imageLink: map['imageLink'] ?? '',
      available: map['available'] ?? true,
      dateCreated: (map['dateCreated'] as Timestamp).toDate(),
      expiryDate: map['expiryDate'] != null ? (map['expiryDate'] as Timestamp).toDate() : null,
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'condition': condition,
      'category': category,
      'sellerPrice': sellerPrice,
      'basePrice': basePrice,
      'imageLink': imageLink,
      'available': available,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}