class UserModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final DateTime? joinAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    this.joinAt,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'],
      email: json['email'],
      imageUrl: json['image_url'],
      joinAt: json['join_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['join_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image_url': imageUrl,
      'join_at': joinAt?.millisecondsSinceEpoch,
    };
  }
}
