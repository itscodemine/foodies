import 'package:flutter/material.dart';
import 'package:foodies/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderHistoryDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderHistoryDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Order Information'),
            _buildInfoRow('Order ID:', order.id!),
            _buildInfoRow('Date:', DateFormat.yMMMd().add_jm().format(order.createdAt.toDate())),
            _buildInfoRow('Status:', order.status.toUpperCase()),
            _buildInfoRow('Total:', '\$${order.pricing.total.toStringAsFixed(2)}'),
            
            const Divider(height: 32),

            _buildSectionTitle('Items'),
            ...order.items.map((item) => ListTile(
                  leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item.name),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                )),
            
            const Divider(height: 32),

            _buildSectionTitle('Delivery'),
            _buildInfoRow('Type:', order.orderType.toUpperCase()),
            if (order.orderType == 'delivery' && order.deliveryAddress != null)
              _buildInfoRow('Address:',
                  '${order.deliveryAddress!.fullAddress}, ${order.deliveryAddress!.city} ${order.deliveryAddress!.postalCode}'),

            const Divider(height: 32),

            _buildSectionTitle('Payment'),
            _buildInfoRow('Method:', order.payment.method),
            _buildInfoRow('Payment Status:', order.payment.status.toUpperCase()),
            
            if (order.status == 'completed') ...[
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to review screen
                  },
                  child: const Text('Leave a Review'),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
