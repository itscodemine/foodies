import 'package:flutter/material.dart';
import 'package:foodies/models/order_model.dart';
import 'package:foodies/services/review_service.dart';
import 'package:foodies/ui/screens/add_review_screen.dart';
import 'package:intl/intl.dart';

class OrderHistoryDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderHistoryDetailScreen({super.key, required this.order});

  @override
  State<OrderHistoryDetailScreen> createState() =>
      _OrderHistoryDetailScreenState();
}

class _OrderHistoryDetailScreenState extends State<OrderHistoryDetailScreen> {
  final ReviewService _reviewService = ReviewService();
  Map<String, bool> _reviewedStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkReviewedStatus();
  }

  void _checkReviewedStatus() async {
    if (widget.order.status != 'completed') {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    Map<String, bool> status = {};
    for (var item in widget.order.items) {
      status[item.menuId] = await _reviewService.checkIfReviewed(
        menuId: item.menuId,
        orderId: widget.order.id!,
      );
    }
    setState(() {
      _reviewedStatus = status;
      _isLoading = false;
    });
  }

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
            _buildInfoRow('Order ID:', widget.order.id!),
            _buildInfoRow('Date:',
                DateFormat.yMMMd().add_jm().format(widget.order.createdAt.toDate())),
            _buildInfoRow('Status:', widget.order.status.toUpperCase()),
            _buildInfoRow(
                'Total:', '\$${widget.order.pricing.total.toStringAsFixed(2)}'),
            const Divider(height: 32),
            _buildSectionTitle('Items'),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: widget.order.items.map((item) {
                      final bool isReviewed = _reviewedStatus[item.menuId] ?? false;
                      return ListTile(
                        leading: Image.network(item.imageUrl,
                            width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(item.name),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing:
                            (widget.order.status == 'completed')
                                ? ElevatedButton(
                                    onPressed: isReviewed
                                        ? null
                                        : () async {
                                            final result =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddReviewScreen(
                                                  orderItem: item,
                                                  orderId: widget.order.id!,
                                                ),
                                              ),
                                            );
                                            if (result == true) {
                                              _checkReviewedStatus();
                                            }
                                          },
                                    child: Text(isReviewed ? 'Reviewed' : 'Review'),
                                  )
                                : null,
                      );
                    }).toList(),
                  ),
            const Divider(height: 32),
            _buildSectionTitle('Delivery'),
            _buildInfoRow('Type:', widget.order.orderType.toUpperCase()),
            if (widget.order.orderType == 'delivery' &&
                widget.order.deliveryAddress != null)
              _buildInfoRow('Address:',
                  '${widget.order.deliveryAddress!.fullAddress}, ${widget.order.deliveryAddress!.city} ${widget.order.deliveryAddress!.postalCode}'),
            const Divider(height: 32),
            _buildSectionTitle('Payment'),
            _buildInfoRow('Method:', widget.order.payment.method),
            _buildInfoRow(
                'Payment Status:', widget.order.payment.status.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child:
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
