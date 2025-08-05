class Item {
  final int? id;
  final String name;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;
  final DateTime? deletedAt;
  final bool deleted;
  final int? subcategoryId;
  final String userId;

  Item({
    this.id,
    required this.name,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.version = 1,
    this.deletedAt,
    this.deleted = false,
    this.subcategoryId,
    required this.userId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int?,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      version: json['version'] ?? 1,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      deleted: json['deleted'] ?? false,
      subcategoryId: json['subcategory_id'] as int?,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'deleted': deleted,
      'subcategory_id': subcategoryId,
      'user_id': userId,
    };
  }

  Item copyWith({
    int? id,
    String? name,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    DateTime? deletedAt,
    bool? deleted,
    int? subcategoryId,
    String? userId,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      deleted: deleted ?? this.deleted,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      userId: userId ?? this.userId,
    );
  }
}
