import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodies/models/address_model.dart';
import 'package:foodies/models/order_model.dart';
import 'package:foodies/services/address_service.dart';
import 'package:foodies/services/cart_service.dart';
import 'package:foodies/services/order_service.dart';
import 'package:foodies/ui/screens/add_edit_address_screen.dart';
import 'package:foodies/ui/screens/order_success_screen.dart';

enum OrderType { pickup, delivery }

enum PaymentMethod { cash }

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final CartService _cartService = CartService();
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();

  OrderType _orderType = OrderType.delivery;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  AddressModel? _selectedAddress;
  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  final double _deliveryFee = 5.0;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  void _fetchAddresses() async {
    final addresses = await _addressService.getAddresses();
    setState(() {
      _addresses = addresses;
      if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.first;
      }
      _isLoading = false;
    });
  }

  void _placeOrder() async {
    if (_orderType == OrderType.delivery && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    final subtotal = _cartService.subtotal;
    final deliveryFee = _orderType == OrderType.delivery ? _deliveryFee : 0.0;
    final total = subtotal + deliveryFee;

    final order = OrderModel(
      userId: FirebaseAuth.instance.currentUser!.uid,
      status: 'processing',
      createdAt: Timestamp.now(),
      items: _cartService.items.map((e) => OrderItem.fromCartItem(e)).toList(),
      pricing: Pricing(subtotal: subtotal, deliveryFee: deliveryFee, total: total),
      payment: Payment(method: 'Cash', status: 'pending'),
      orderType: _orderType.name,
      deliveryAddress: _selectedAddress,
    );

    final orderId = await _orderService.createOrder(order);

    setState(() {
      _isPlacingOrder = false;
    });

    if (orderId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Type
                  const Text('Order Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  RadioListTile<OrderType>(
                    title: const Text('Delivery'),
                    value: OrderType.delivery,
                    groupValue: _orderType,
                    onChanged: (value) => setState(() => _orderType = value!),
                  ),
                  RadioListTile<OrderType>(
                    title: const Text('Pickup'),
                    value: OrderType.pickup,
                    groupValue: _orderType,
                    onChanged: (value) => setState(() => _orderType = value!),
                  ),

                  // Delivery Address
                  if (_orderType == OrderType.delivery) ...[
                    const SizedBox(height: 16),
                    const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _addresses.isEmpty
                        ? Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditAddressScreen()));
                                if (result == true) _fetchAddresses();
                              },
                              child: const Text('Add New Address'),
                            ),
                          )
                        : DropdownButtonFormField<AddressModel>(
                            value: _selectedAddress,
                            items: _addresses.map((address) {
                              return DropdownMenuItem(
                                value: address,
                                child: Text(address.label),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedAddress = value),
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                          ),
                  ],

                  // Payment Method
                  const SizedBox(height: 16),
                  const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  RadioListTile<PaymentMethod>(
                    title: const Text('Cash on Delivery'),
                    value: PaymentMethod.cash,
                    groupValue: _paymentMethod,
                    onChanged: (value) => setState(() => _paymentMethod = value!),
                  ),
                  const Divider(height: 32),

                  // Order Summary
                  const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ..._cartService.items.map((item) => ListTile(
                        title: Text('${item.menu.name} (x${item.quantity})'),
                        trailing: Text('\$${(item.totalPrice).toStringAsFixed(2)}'),
                      )),
                  const Divider(),
                  ListTile(
                    title: const Text('Subtotal'),
                    trailing: Text('\$${_cartService.subtotal.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: const Text('Delivery Fee'),
                    trailing: Text('\$${(_orderType == OrderType.delivery ? _deliveryFee : 0.0).toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '\$${(_cartService.subtotal + (_orderType == OrderType.delivery ? _deliveryFee : 0.0)).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isPlacingOrder
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Place Order'),
              ),
      ),
    );
  }
}
