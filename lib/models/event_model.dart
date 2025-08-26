class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final double latitude;
  final double longitude;
  final String categoryId;
  final String organizerId;
  final double price;
  final int maxAttendees;
  final int currentAttendees;
  final List<String> attendees;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.organizerId,
    required this.price,
    required this.maxAttendees,
    this.currentAttendees = 0,
    this.attendees = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] ?? '',
      organizerId: json['organizerId'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      maxAttendees: json['maxAttendees'] ?? 0,
      currentAttendees: json['currentAttendees'] ?? 0,
      attendees: List<String>.from(json['attendees'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'categoryId': categoryId,
      'organizerId': organizerId,
      'price': price,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'attendees': attendees,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    double? latitude,
    double? longitude,
    String? categoryId,
    String? organizerId,
    double? price,
    int? maxAttendees,
    int? currentAttendees,
    List<String>? attendees,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categoryId: categoryId ?? this.categoryId,
      organizerId: organizerId ?? this.organizerId,
      price: price ?? this.price,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      attendees: attendees ?? this.attendees,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}