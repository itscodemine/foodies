import 'package:flutter/material.dart';
import 'package:foodies/services/cart_service.dart';
import 'package:foodies/ui/screens/order_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  void _updateCart() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.green,
      ),
      body: _cartService.items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView.builder(
              itemCount: _cartService.items.length,
              itemBuilder: (context, index) {
                final item = _cartService.items[index];
                return ListTile(
                  leading: Image.network(item.menu.imageUrl, width: 50, height: 50, fit: BoxFit.cover,),
                  title: Text(item.menu.name),
                  subtitle: Text('\$${item.menu.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _cartService.updateQuantity(item, item.quantity - 1);
                          });
                        },
                      ),
                      Text(item.quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _cartService.updateQuantity(item, item.quantity + 1);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${_cartService.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cartService.items.isEmpty
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrderDetailScreen()),
                      );
                      _updateCart();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
