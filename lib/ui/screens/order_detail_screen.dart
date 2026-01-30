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
      pricing: Pricing(
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
      ),
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
      appBar: AppBar(title: const Text('Confirm Order')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: 'Order Type',
                    child: Column(
                      children: [
                        RadioListTile<OrderType>(
                          title: const Text('Delivery'),
                          value: OrderType.delivery,
                          groupValue: _orderType,
                          onChanged: (value) =>
                              setState(() => _orderType = value!),
                          activeColor: Colors.green,
                        ),
                        RadioListTile<OrderType>(
                          title: const Text('Pickup'),
                          value: OrderType.pickup,
                          groupValue: _orderType,
                          onChanged: (value) =>
                              setState(() => _orderType = value!),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_orderType == OrderType.delivery) ...[
                    _buildSectionCard(
                      title: 'Delivery Address',
                      child: _addresses.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddEditAddressScreen(),
                                      ),
                                    );
                                    if (result == true) _fetchAddresses();
                                  },
                                  child: const Text('Add New Address'),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: DropdownButtonFormField<AddressModel>(
                                value: _selectedAddress,
                                items: _addresses.map((address) {
                                  return DropdownMenuItem(
                                    value: address,
                                    child: Text(address.label),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    setState(() => _selectedAddress = value),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildSectionCard(
                    title: 'Payment Method',
                    child: RadioListTile<PaymentMethod>(
                      title: const Text('Cash on Delivery'),
                      value: PaymentMethod.cash,
                      groupValue: _paymentMethod,
                      onChanged: (value) =>
                          setState(() => _paymentMethod = value!),
                      activeColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Order Summary',
                    child: Column(
                      children: [
                        ..._cartService.items.map(
                          (item) => ListTile(
                            title: Text(
                              '${item.menu.name} (x${item.quantity})',
                            ),
                            trailing: Text(
                              '\$${(item.totalPrice).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Subtotal'),
                          trailing: Text(
                            '\$${_cartService.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ListTile(
                          title: const Text('Delivery Fee'),
                          trailing: Text(
                            '\$${(_orderType == OrderType.delivery ? _deliveryFee : 0.0).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Text(
                            '\$${(_cartService.subtotal + (_orderType == OrderType.delivery ? _deliveryFee : 0.0)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: _isPlacingOrder
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Checkout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.check, color: Colors.white),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
