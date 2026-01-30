class MenuModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final double price;
  final double averageRating;
  final int ratingCount;

  MenuModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.averageRating,
    required this.ratingCount,
  });

  factory MenuModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MenuModel(
      id: id,
      name: data['name'],
      category: data['category'],
      description: data['description'],
      imageUrl: data['image_url'],
      price: (data['price'] as num).toDouble(),
      averageRating: (data['average_rating'] as num).toDouble(),
      ratingCount: data['rating_count'],
    );
  }
}
