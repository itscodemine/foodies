class AddressModel {
  final String? id;
  final String userId;
  final String recipient;
  final String phone;
  final String city;
  final String postalCode;
  final String fullAddress;
  final String label;

  AddressModel({
    this.id,
    required this.userId,
    required this.recipient,
    required this.phone,
    required this.city,
    required this.postalCode,
    required this.fullAddress,
    required this.label,
  });

  factory AddressModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AddressModel(
      id: id,
      userId: data['user_id'],
      recipient: data['recipient'],
      phone: data['phone'],
      city: data['city'],
      postalCode: data['postal_code'],
      fullAddress: data['full_address'],
      label: data['label'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'recipient': recipient,
      'phone': phone,
      'city': city,
      'postal_code': postalCode,
      'full_address': fullAddress,
      'label': label,
    };
  }
}
