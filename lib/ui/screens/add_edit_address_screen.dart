import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodies/models/address_model.dart';
import 'package:foodies/services/address_service.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();

  late String _recipient;
  late String _phone;
  late String _city;
  late String _postalCode;
  late String _fullAddress;
  late String _label;

  @override
  void initState() {
    super.initState();
    _recipient = widget.address?.recipient ?? '';
    _phone = widget.address?.phone ?? '';
    _city = widget.address?.city ?? '';
    _postalCode = widget.address?.postalCode ?? '';
    _fullAddress = widget.address?.fullAddress ?? '';
    _label = widget.address?.label ?? '';
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final newAddress = AddressModel(
        id: widget.address?.id,
        userId: userId,
        recipient: _recipient,
        phone: _phone,
        city: _city,
        postalCode: _postalCode,
        fullAddress: _fullAddress,
        label: _label,
      );

      if (widget.address == null) {
        await _addressService.addAddress(newAddress);
      } else {
        await _addressService.updateAddress(newAddress);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _recipient,
                  decoration: const InputDecoration(labelText: 'Recipient Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  onSaved: (value) => _recipient = value!,
                ),
                TextFormField(
                  initialValue: _phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
                  onSaved: (value) => _phone = value!,
                ),
                TextFormField(
                  initialValue: _fullAddress,
                  decoration: const InputDecoration(labelText: 'Full Address'),
                  validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
                  onSaved: (value) => _fullAddress = value!,
                ),
                TextFormField(
                  initialValue: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (value) => value!.isEmpty ? 'Please enter a city' : null,
                  onSaved: (value) => _city = value!,
                ),
                TextFormField(
                  initialValue: _postalCode,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                  validator: (value) => value!.isEmpty ? 'Please enter a postal code' : null,
                  onSaved: (value) => _postalCode = value!,
                ),
                TextFormField(
                  initialValue: _label,
                  decoration: const InputDecoration(labelText: 'Label (e.g., Home, Office)'),
                  validator: (value) => value!.isEmpty ? 'Please enter a label' : null,
                  onSaved: (value) => _label = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Save Address'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
