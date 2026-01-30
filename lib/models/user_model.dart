class UserModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final DateTime joinAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.joinAt,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'],
      email: json['email'],
      imageUrl: json['image_url'],
      joinAt: DateTime.fromMillisecondsSinceEpoch(json['join_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'image_url': imageUrl,
      'join_at': joinAt.millisecondsSinceEpoch,
    };
  }
}
