import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.documentId,
    super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    phone: json['phone'] as String,
    documentId: json['document_id'] as String,
    email: json['email'] as String?,
  );
}

class AuthSessionModel {
  const AuthSessionModel({required this.accessToken, required this.user});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        accessToken: json['access_token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );

  final String accessToken;
  final UserModel user;
}
