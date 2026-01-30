import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodies/models/order_model.dart';
import 'package:foodies/services/cart_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createOrder(OrderModel order) async {
    try {
      final docRef =
          await _firestore.collection('orders').add(order.toFirestore());
      CartService().clear();
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<List<OrderModel>> getOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print(e); // For debugging
      return [];
    }
  }
}
