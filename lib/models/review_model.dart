import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String? id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String orderId;
  final String menuId;
  final Timestamp createdAt;
  final double rating;
  final String? comment;

  ReviewModel({
    this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.orderId,
    required this.menuId,
    required this.createdAt,
    required this.rating,
    this.comment,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: data['user_id'],
      userName: data['user_name'],
      userImageUrl: data['user_image_url'],
      orderId: data['order_id'],
      menuId: data['menu_id'],
      createdAt: data['created_at'],
      rating: (data['rating'] as num).toDouble(),
      comment: data['comment'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'order_id': orderId,
      'menu_id': menuId,
      'created_at': createdAt,
      'rating': rating,
      'comment': comment,
    };
  }
}
