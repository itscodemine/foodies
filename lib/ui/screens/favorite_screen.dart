import 'package:flutter/material.dart';
import 'package:foodies/models/menu_model.dart';
import 'package:foodies/services/favorite_service.dart';
import 'package:foodies/ui/screens/detail_menu_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  List<MenuModel> _favoriteMenus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  void _fetchFavorites() async {
    final menus = await _favoriteService.getFavoriteMenus();
    if (mounted) {
      setState(() {
        _favoriteMenus = menus;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteMenus.isEmpty
              ? const Center(child: Text('You have no favorite menus yet.'))
              : ListView.builder(
                  itemCount: _favoriteMenus.length,
                  itemBuilder: (context, index) {
                    final menu = _favoriteMenus[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          menu.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        title: Text(menu.name),
                        subtitle: Text(
                          '\$${menu.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green[800]),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailMenuScreen(menu: menu),
                            ),
                          );
                          // Refresh favorites in case one was removed on the detail page
                          _fetchFavorites();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
