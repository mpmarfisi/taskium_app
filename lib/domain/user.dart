import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String name;
  final String email;
  final String password;
  final String? imageUrl;
  final String bornDate;

  User({
    required this.username,
    required this.name,
    required this.email,
    required this.password,
    required this.bornDate,
    this.imageUrl,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'imageUrl': imageUrl,
      'bornDate': bornDate,
    };
  }

  static User fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return User(
      username: data?['username'] ?? snapshot.id,
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
      password: data?['password'] ?? '',
      imageUrl: data?['imageUrl'],
      bornDate: data?['bornDate'] ?? '',
    );
  }

  User copyWith({
    String? username,
    String? name,
    String? email,
    String? password,
    String? imageUrl,
    String? bornDate,
  }) {
    return User(
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
      bornDate: bornDate ?? this.bornDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.username == username &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.imageUrl == imageUrl &&
        other.bornDate == bornDate;
  }

  @override
  int get hashCode {
    return username.hashCode ^
        name.hashCode ^
        email.hashCode ^
        password.hashCode ^
        imageUrl.hashCode ^
        bornDate.hashCode;
  }

  @override
  String toString() {
    return 'User{username: $username, name: $name, email: $email, password: $password}';
  }
}
