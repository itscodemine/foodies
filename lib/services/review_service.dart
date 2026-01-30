import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodies/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addReviewAndUpdateMenu({
    required String menuId,
    required String orderId,
    required double rating,
    required String? comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return false;
    final userName = userDoc.data()!['name'];
    final userImageUrl = userDoc.data()!['image_url'];

    final menuRef = _firestore.collection('menus').doc(menuId);
    // Change: Use top-level collection for the new review
    final reviewRef = _firestore.collection('menu_reviews').doc();

    final review = ReviewModel(
      userId: user.uid,
      userName: userName,
      userImageUrl: userImageUrl,
      orderId: orderId,
      menuId: menuId,
      createdAt: Timestamp.now(),
      rating: rating,
      comment: comment,
    );

    try {
      await _firestore.runTransaction((transaction) async {
        final menuDoc = await transaction.get(menuRef);
        if (!menuDoc.exists) {
          throw Exception("Menu does not exist!");
        }

        final currentRatingCount = menuDoc.data()!['rating_count'] as int;
        final currentAverageRating =
            (menuDoc.data()!['average_rating'] as num).toDouble();

        final newRatingCount = currentRatingCount + 1;
        final newAverageRating =
            ((currentAverageRating * currentRatingCount) + rating) /
                newRatingCount;

        transaction.set(reviewRef, review.toFirestore());
        transaction.update(menuRef, {
          'rating_count': newRatingCount,
          'average_rating': newAverageRating,
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfReviewed({
    required String menuId,
    required String orderId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Change: Query the top-level collection
    final snapshot = await _firestore
        .collection('menu_reviews')
        .where('user_id', isEqualTo: user.uid)
        .where('order_id', isEqualTo: orderId)
        .where('menu_id', isEqualTo: menuId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<List<ReviewModel>> getReviewsForMenu(String menuId) async {
    try {
      // Change: Query the top-level collection
      final snapshot = await _firestore
          .collection('menu_reviews')
          .where('menu_id', isEqualTo: menuId)
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}

