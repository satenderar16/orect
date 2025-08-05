class CategoryModal {
  //remember to add all fields in the categoryMagic create a dynamic json:
  final int? id;
  final String name;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;
  final DateTime? deletedAt;
  final bool deleted;

  CategoryModal({
    this.id,
    required this.name,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.version = 1,
    this.deletedAt,
    this.deleted = false,
  });

  factory CategoryModal.fromJson(Map<String, dynamic> json) {
    return CategoryModal(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'name': name,
      // 'image_url': imageUrl,
      // 'created_at': createdAt?.toIso8601String(),
      // 'updated_at': updatedAt?.toIso8601String(),
      // 'version': version,
      // 'deleted_at': deletedAt?.toIso8601String(),
      // 'deleted': deleted, //can be sent but only required
    };
  }
  Map<String, dynamic> toJsonUpdateWithFilter(CategoryMagicJson magicJson) {
    final mJson = magicJson.toJson();

    final values = {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'version': version,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted': deleted,
    };

    final output = <String, dynamic>{};

    for (final entry in mJson.entries) {
      if (entry.value == true) {
        output[entry.key] = values[entry.key];
      }
    }

    return output;
  }



  Map<String, dynamic> toJsonUpdate({
    bool id = false,
    bool name = false,
    bool imageUrl = false,
    bool createdAt = false,
    bool updatedAt = false,
    bool version = false,
    bool deletedAt = false,
    bool deleted = false,
  }) {
    final map = <String, dynamic>{};

    if (id) map['id'] = this.id;
    if (name) map['name'] = this.name;
    if (imageUrl) map['image_url'] = this.imageUrl;
    if (createdAt) map['created_at'] = this.createdAt?.toIso8601String();
    if (updatedAt) map['updated_at'] = this.updatedAt?.toIso8601String();
    if (version) map['version'] = this.version;
    if (deletedAt) map['deleted_at'] = this.deletedAt?.toIso8601String();
    if (deleted) map['deleted'] = this.deleted;

    return map;
  }


  CategoryModal copyWith({
    int? id,
    String? name,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    DateTime? deletedAt,
    bool? deleted,
  }) {
    return CategoryModal(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      deleted: deleted ?? this.deleted,
    );
  }
/// for debuging and testing:

  @override
  String toString() {
    return 'Category('
        'id: $id, '
        'name: $name, '
        'imageUrl: $imageUrl, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'version: $version, '
        'deletedAt: $deletedAt, '
        'deleted: $deleted'
        ')';
  }
}

class CategoryMagicJson {
  final bool id;
  final bool name;
  final bool imageUrl;
  final bool createdAt;
  final bool updatedAt;
  final bool version;
  final bool deletedAt;
  final bool deleted;

  const CategoryMagicJson({
    this.id = false,
    this.name = false,
    this.imageUrl = false,
    this.createdAt = false,
    this.updatedAt = false,
    this.version = false,
    this.deletedAt = false,
    this.deleted = false,
  });

  Map<String, bool> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'version': version,
      'deleted_at': deletedAt,
      'deleted': deleted,
    };
  }
}
