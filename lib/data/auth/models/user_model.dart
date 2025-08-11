import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/auth/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;

  const UserModel({
    required this.uid,
    required this.email,
    this.name,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName,
    );
  }

  UserEntity toEntity() => UserEntity(
    uid: uid,
    email: email,
    name: name,
  );
}
