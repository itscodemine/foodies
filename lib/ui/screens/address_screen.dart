import 'package:flutter/material.dart';
import 'package:foodies/models/address_model.dart';
import 'package:foodies/services/address_service.dart';
import 'package:foodies/ui/screens/add_edit_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final AddressService _addressService = AddressService();
  List<AddressModel> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  void _fetchAddresses() async {
    setState(() {
      _isLoading = true;
    });
    final addresses = await _addressService.getAddresses();
    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  void _deleteAddress(String addressId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this address?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _addressService.deleteAddress(addressId);
                _fetchAddresses();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result == true) {
      _fetchAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return _AddressCard(
                      address: address,
                      onDelete: () => _deleteAddress(address.id!),
                      onEdit: () => _navigateAndRefresh(
                          AddEditAddressScreen(address: address)),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(const AddEditAddressScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Addresses Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add an address to get started.',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard(
      {required this.address, required this.onEdit, required this.onDelete});

  IconData _getAddressIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getAddressIcon(address.label), color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      address.label,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 22),
                      onPressed: onEdit,
                      tooltip: 'Edit Address',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 22),
                      onPressed: onDelete,
                      tooltip: 'Delete Address',
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(
                icon: Icons.person_outline,
                text: address.recipient,
                context: context),
            const SizedBox(height: 12),
            _InfoRow(
                icon: Icons.signpost_outlined,
                text:
                    '${address.fullAddress}, ${address.city} ${address.postalCode}',
                context: context),
            const SizedBox(height: 12),
            _InfoRow(
                icon: Icons.phone_outlined,
                text: address.phone,
                context: context),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final BuildContext context;

  const _InfoRow(
      {required this.icon, required this.text, required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
