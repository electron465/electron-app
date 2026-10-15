import '../../domain/entities/store.dart';

class StoreModel extends Store {
  const StoreModel({
    required super.id,
    required super.name,
    required super.category,
    required super.isOnline,
    super.logoUrl,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    isOnline: json['is_online'] as bool,
    logoUrl: json['logo_url'] as String?,
  );
}
