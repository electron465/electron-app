import 'package:equatable/equatable.dart';

/// Comercio aliado donde el cliente puede comprar en cuotas.
class Store extends Equatable {
  const Store({
    required this.id,
    required this.name,
    required this.category,
    required this.isOnline,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String category;

  /// `true` si vende online; `false` si es solo tienda física.
  final bool isOnline;
  final String? logoUrl;

  @override
  List<Object?> get props => [id, name, category, isOnline, logoUrl];
}
