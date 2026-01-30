import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodies/models/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<AddressModel>> getAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('addresses')
          .where('user_id', isEqualTo: user.uid)
          .get();
      return snapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      await _firestore.collection('addresses').add(address.toFirestore());
    } catch (e) {}
  }

  Future<void> updateAddress(AddressModel address) async {
    try {
      await _firestore
          .collection('addresses')
          .doc(address.id)
          .update(address.toFirestore());
    } catch (e) {}
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _firestore.collection('addresses').doc(addressId).delete();
    } catch (e) {}
  }
}
