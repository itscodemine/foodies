class UserModel {
  final String id;
  final String name;
  final String email;
  final String? image;
  final DateTime joinAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.joinAt,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'],
      email: json['email'],
      image: json['image'],
      joinAt: DateTime.fromMillisecondsSinceEpoch(json['join_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'join_at': joinAt.millisecondsSinceEpoch,
    };
  }
}
