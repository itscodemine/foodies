import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodies/models/menu_model.dart';

class MenuServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MenuModel>> getPopularMenus() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('menus')
          .orderBy('rating_count', descending: true)
          .limit(10)
          .get();

      List<MenuModel> menus = snapshot.docs.map((doc) {
        return MenuModel.fromFirestore(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      return menus;
    } catch (e) {
      return [];
    }
  }
}
