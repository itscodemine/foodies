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
    if (mounted) {
      setState(() {
        _reviewedStatus = status;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'processing':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildItemsCard(),
            const SizedBox(height: 16),
            _buildLogisticsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Order ID', '#${widget.order.id!.substring(0, 8)}'),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Date',
              DateFormat(
                'MMM d, yyyy HH:mm',
              ).format(widget.order.createdAt.toDate()),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 120,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      widget.order.status,
                    ).withAlpha((255 * 0.15).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(widget.order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Total',
              '\$${widget.order.pricing.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Items',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.order.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.order.items[index];
                      return _buildOrderItem(item);
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    final bool isReviewed = _reviewedStatus[item.menuId] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity}',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  'Price: \$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          if (widget.order.status == 'completed')
            ElevatedButton(
              onPressed: isReviewed
                  ? null
                  : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReviewScreen(
                            orderItem: item,
                            orderId: widget.order.id!,
                          ),
                        ),
                      );
                      if (result == true) {
                        _checkReviewedStatus();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isReviewed ? Colors.grey : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                isReviewed ? 'REVIEWED' : 'REVIEW',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogisticsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Delivery & Payment',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Order Type', widget.order.orderType.toUpperCase()),
            if (widget.order.orderType == 'delivery' &&
                widget.order.deliveryAddress != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Address',
                '${widget.order.deliveryAddress!.fullAddress}, ${widget.order.deliveryAddress!.city} ${widget.order.deliveryAddress!.postalCode}',
              ),
            ],
            const Divider(height: 24),
            _buildInfoRow('Payment Method', widget.order.payment.method),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Payment Status',
              widget.order.payment.status.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isTotal ? Colors.black : Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 20 : 15,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
