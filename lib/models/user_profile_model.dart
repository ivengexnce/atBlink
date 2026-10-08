import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String photoUrl;
  final String bio;
  final String authMethod; // 'google', 'email', 'guest'
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = 'Flat 402, Green Park Heights, Cyber City',
    this.photoUrl = '',
    this.bio = 'Shopping on atBlink ⚡',
    this.authMethod = 'google',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? photoUrl,
    String? bio,
    String? authMethod,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      authMethod: authMethod ?? this.authMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
      'bio': bio,
      'authMethod': authMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? 'atBlink User',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? 'Flat 402, Green Park Heights, Cyber City',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? 'Shopping on atBlink ⚡',
      authMethod: map['authMethod'] ?? 'google',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
