import 'package:flutter/material.dart';
import 'package:foodies/models/order_model.dart';
import 'package:foodies/services/order_service.dart';
import 'package:foodies/ui/screens/order_history_detail_screen.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() async {
    final orders = await _orderService.getOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('You have no past orders.'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Order #${order.id}', overflow: TextOverflow.ellipsis,),
                        subtitle: Text(DateFormat.yMMMd().format(order.createdAt.toDate())),
                        trailing: Text(
                          '\$${order.pricing.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderHistoryDetailScreen(order: order),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
