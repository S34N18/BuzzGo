class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.color,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      color: json['color'] ?? '#000000',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'color': color,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}