class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final String? phoneNumber;
  final List<String> favoriteEvents;
  final List<String> attendedEvents;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    this.phoneNumber,
    this.favoriteEvents = const [],
    this.attendedEvents = const [],
    this.isAdmin = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
      favoriteEvents: List<String>.from(json['favoriteEvents'] ?? []),
      attendedEvents: List<String>.from(json['attendedEvents'] ?? []),
      isAdmin: json['isAdmin'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'favoriteEvents': favoriteEvents,
      'attendedEvents': attendedEvents,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    String? phoneNumber,
    List<String>? favoriteEvents,
    List<String>? attendedEvents,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      favoriteEvents: favoriteEvents ?? this.favoriteEvents,
      attendedEvents: attendedEvents ?? this.attendedEvents,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}