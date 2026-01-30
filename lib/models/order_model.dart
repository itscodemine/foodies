import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodies/models/address_model.dart';
import 'package:foodies/models/cart_item_model.dart';

class OrderModel {
  final String? id;
  final String userId;
  final String status;
  final Timestamp createdAt;
  final List<OrderItem> items;
  final Pricing pricing;
  final Payment payment;
  final String orderType;
  final AddressModel? deliveryAddress;

  OrderModel({
    this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.items,
    required this.pricing,
    required this.payment,
    required this.orderType,
    this.deliveryAddress,
  });

  factory OrderModel.fromFirestore(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      userId: data['user_id'],
      status: data['status'],
      createdAt: data['created_at'],
      items: (data['items'] as List)
          .map((item) => OrderItem.fromFirestore(item))
          .toList(),
      pricing: Pricing.fromFirestore(data['pricing']),
      payment: Payment.fromFirestore(data['payment']),
      orderType: data['order_type'],
      deliveryAddress: data['delivery_address'] != null
          ? AddressModel.fromFirestore(
              '', data['delivery_address']) // ID is not needed here
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'status': status,
      'created_at': createdAt,
      'items': items.map((item) => item.toFirestore()).toList(),
      'pricing': pricing.toFirestore(),
      'payment': payment.toFirestore(),
      'order_type': orderType,
      'delivery_address': deliveryAddress?.toFirestore(),
    };
  }
}

class OrderItem {
  final String menuId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  OrderItem({
    required this.menuId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory OrderItem.fromCartItem(CartItemModel cartItem) {
    return OrderItem(
      menuId: cartItem.menu.id,
      name: cartItem.menu.name,
      price: cartItem.menu.price,
      imageUrl: cartItem.menu.imageUrl,
      quantity: cartItem.quantity,
    );
  }

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      menuId: data['menu_id'],
      name: data['name'],
      price: (data['price'] as num).toDouble(),
      imageUrl: data['image_url'],
      quantity: data['quantity'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'menu_id': menuId,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'quantity': quantity,
    };
  }
}

class Pricing {
  final double subtotal;
  final double deliveryFee;
  final double total;

  Pricing({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  factory Pricing.fromFirestore(Map<String, dynamic> data) {
    return Pricing(
      subtotal: (data['subtotal'] as num).toDouble(),
      deliveryFee: (data['delivery_fee'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'subtotal': subtotal, 'delivery_fee': deliveryFee, 'total': total};
  }
}

class Payment {
  final String method;
  final String status;

  Payment({required this.method, required this.status});

  factory Payment.fromFirestore(Map<String, dynamic> data) {
    return Payment(
      method: data['method'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'method': method, 'status': status};
  }
}

