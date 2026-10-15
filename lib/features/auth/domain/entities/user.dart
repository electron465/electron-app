import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.documentId,
    this.email,
  });

  final String id;
  final String fullName;
  final String phone;

  /// Cédula de identidad (ej. V-12345678).
  final String documentId;
  final String? email;

  String get firstName => fullName.split(' ').first;

  @override
  List<Object?> get props => [id, fullName, phone, documentId, email];
}
