import 'package:flutter/material.dart';
import 'package:foodies/models/menu_model.dart';
import 'package:foodies/services/favorite_service.dart';
import 'package:foodies/ui/widgets/favorite_menu_item.dart';

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

  Future<void> _fetchFavorites() async {
    final menus = await _favoriteService.getFavoriteMenus();
    if (mounted) {
      setState(() {
        _favoriteMenus = menus;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(String menuId) async {
    await _favoriteService.removeFavorite(menuId);
    _fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteMenus.isEmpty
              ? const Center(
                  child: Text(
                    'You have no favorite menus yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _favoriteMenus.length,
                  itemBuilder: (context, index) {
                    final menu = _favoriteMenus[index];
                    return FavoriteMenuItem(
                      menu: menu,
                      onRemove: () => _removeFromFavorites(menu.id),
                    );
                  },
                ),
    );
  }
}
