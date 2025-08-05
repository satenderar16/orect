class Subcategory {
  final int? id;
  final String name;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;
  final DateTime? deletedAt;
  final bool deleted;
  final int? categoryId;
  final String userId;

  Subcategory({
    this.id,
    required this.name,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.version = 1,
    this.deletedAt,
    this.deleted = false,
    this.categoryId,
    required this.userId,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] as int?,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      version: json['version'] ?? 1,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      deleted: json['deleted'] ?? false,
      categoryId: json['category_id'] as int?,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'deleted': deleted,
      'category_id': categoryId,
      'user_id': userId,
      // Don't include id, timestamps, version unless required by your insert/update logic
    };
  }

  Subcategory copyWith({
    int? id,
    String? name,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    DateTime? deletedAt,
    bool? deleted,
    int? categoryId,
    String? userId,
  }) {
    return Subcategory(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      deleted: deleted ?? this.deleted,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
    );
  }
}
