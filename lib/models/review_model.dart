import 'dart:convert';

class ReviewModel {
  final String id;
  final int productId;
  final String userId;
  final String userName;
  final String userPhoto;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ReviewModel(
      id: docId ?? map['id']?.toString() ?? '',
      productId: map['productId'] is int
          ? map['productId']
          : int.tryParse(map['productId']?.toString() ?? '0') ?? 0,
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Verified Shopper',
      userPhoto: map['userPhoto']?.toString() ?? '',
      rating: map['rating'] is num
          ? (map['rating'] as num).toDouble()
          : double.tryParse(map['rating']?.toString() ?? '5.0') ?? 5.0,
      comment: map['comment']?.toString() ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewModel.fromJson(String source) =>
      ReviewModel.fromMap(json.decode(source));
}
