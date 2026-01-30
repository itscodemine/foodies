import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodies/models/menu_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isFavorite(String menuId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: user.uid)
          .where('menu_id', isEqualTo: menuId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleFavorite(String menuId, bool isCurrentlyFavorite) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (isCurrentlyFavorite) {
        final snapshot = await _firestore
            .collection('favorites')
            .where('user_id', isEqualTo: user.uid)
            .where('menu_id', isEqualTo: menuId)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference.delete();
        }
      } else {
        await _firestore.collection('favorites').add({
          'user_id': user.uid,
          'menu_id': menuId,
          'favorited_at': Timestamp.now(),
        });
      }
    } catch (e) {}
  }

  Future<List<MenuModel>> getFavoriteMenus() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final favoriteSnapshot = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: user.uid)
          .get();

      if (favoriteSnapshot.docs.isEmpty) {
        return [];
      }

      final menuIds = favoriteSnapshot.docs
          .map((doc) => doc['menu_id'] as String)
          .toList();

      if (menuIds.isEmpty) return [];

      final menuQuerySnapshot = await _firestore
          .collection('menus')
          .where(FieldPath.documentId, whereIn: menuIds)
          .get();

      return menuQuerySnapshot.docs
          .map((doc) => MenuModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
