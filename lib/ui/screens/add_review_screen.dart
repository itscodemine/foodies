import 'package:flutter/material.dart';
import 'package:foodies/models/order_model.dart';
import 'package:foodies/services/review_service.dart';

class AddReviewScreen extends StatefulWidget {
  final OrderItem orderItem;
  final String orderId;

  const AddReviewScreen(
      {super.key, required this.orderItem, required this.orderId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final _commentController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  void _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a star rating.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await _reviewService.addReviewAndUpdateMenu(
      menuId: widget.orderItem.menuId,
      orderId: widget.orderId,
      rating: _rating,
      comment: _commentController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to submit review. Please try again.'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.orderItem.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('How would you rate it?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _rating > index ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comments (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Submit Review'),
                  ),
          ],
        ),
      ),
    );
  }
}
