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
  bool _isSaving = false;

  late TextEditingController _recipientController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _fullAddressController;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _recipientController = TextEditingController(text: widget.address?.recipient);
    _phoneController = TextEditingController(text: widget.address?.phone);
    _cityController = TextEditingController(text: widget.address?.city);
    _postalCodeController =
        TextEditingController(text: widget.address?.postalCode);
    _fullAddressController =
        TextEditingController(text: widget.address?.fullAddress);
    _labelController = TextEditingController(text: widget.address?.label);
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _fullAddressController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final newAddress = AddressModel(
        id: widget.address?.id,
        userId: userId,
        recipient: _recipientController.text,
        phone: _phoneController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        fullAddress: _fullAddressController.text,
        label: _labelController.text,
      );

      if (widget.address == null) {
        await _addressService.addAddress(newAddress);
      } else {
        await _addressService.updateAddress(newAddress);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Label (e.g., Home, Office)',
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a label' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _recipientController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Recipient Name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullAddressController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Full Address',
                  prefixIcon: const Icon(Icons.signpost_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: inputDecoration.copyWith(
                  labelText: 'City',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a city' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postalCodeController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Postal Code',
                  prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a postal code' : null,
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveAddress,
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Save Address'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
