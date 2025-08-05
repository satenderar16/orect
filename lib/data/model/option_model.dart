import 'package:decimal/decimal.dart';

class Option {
  final int? id;
  final int itemId;
  final String name;
  final Decimal baseUnitPrice;
  final String? priceUnitSaved;
  final String? type; // You can make this an enum later if needed
  final String? unitTag;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;
  final DateTime? deletedAt;
  final bool deleted;

  Option({
    this.id,
    required this.itemId,
    required this.name,
    required this.baseUnitPrice,
    this.priceUnitSaved,
    this.type,
    this.unitTag,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.version = 1,
    this.deletedAt,
    this.deleted = false,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] as int?,
      itemId: json['item_id'] as int,
      name: json['name'] as String,
      baseUnitPrice: Decimal.parse(json['base_unit_price'].toString()),
      priceUnitSaved: json['price_unit_saved'] as String?,
      type: json['type'] as String?,
      unitTag: json['unit_tag'] as String?,
      userId: json['user_id'] as String,
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
      'item_id': itemId,
      'name': name,
      'base_unit_price': baseUnitPrice.toString(),
      'price_unit_saved': priceUnitSaved,
      'type': type,
      'unit_tag': unitTag,
      'user_id': userId,
      'deleted': deleted,
      // Do not send timestamps or id when inserting/updating unless required
    };
  }

  Option copyWith({
    int? id,
    int? itemId,
    String? name,
    Decimal? baseUnitPrice,
    String? priceUnitSaved,
    String? type,
    String? unitTag,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    DateTime? deletedAt,
    bool? deleted,
  }) {
    return Option(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      baseUnitPrice: baseUnitPrice ?? this.baseUnitPrice,
      priceUnitSaved: priceUnitSaved ?? this.priceUnitSaved,
      type: type ?? this.type,
      unitTag: unitTag ?? this.unitTag,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      deleted: deleted ?? this.deleted,
    );
  }
}
