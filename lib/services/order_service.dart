import 'package:cloud_firestore/cloud_firestore.dart';
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
}
