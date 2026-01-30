import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodies/models/menu_model.dart';
import 'package:foodies/models/user_model.dart';
import 'package:foodies/services/auth_services.dart';
import 'package:foodies/services/menu_services.dart';
import 'package:foodies/ui/screens/address_screen.dart';
import 'package:foodies/ui/screens/cart_screen.dart';
import 'package:foodies/ui/screens/favorite_screen.dart';
import 'package:foodies/ui/screens/login_screen.dart';
import 'package:foodies/ui/screens/order_history_screen.dart';
import 'package:foodies/ui/screens/profile_screen.dart';
import 'package:foodies/ui/widgets/menu_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  List<MenuModel> _popularMenus = [];
  bool _isLoading = true;
  final _categories = [
    'Main Course',
    'Snack',
    'Dessert',
    'Beverages',
    'Noodles',
    'Seafood'
  ];
  String _selectedCategory = 'Main Course';
  List<MenuModel> _categoryMenus = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchPopularMenus();
    _fetchMenusByCategory(_selectedCategory);
  }

  Future<void> _fetchUserData() async {
    final user =
        await AuthServices().getUser(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _user = user;
    });
  }

  Future<void> _fetchMenusByCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });
    final menus = await MenuServices().getMenusByCategory(category);
    setState(() {
      _categoryMenus = menus;
      _isLoading = false;
    });
  }

  Future<void> _fetchPopularMenus() async {
    final menus = await MenuServices().getPopularMenus();
    setState(() {
      _popularMenus = menus;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _user != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello,',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    _user!.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              )
            : null,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: _user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${_user!.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _user!.email,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.black),
              title: const Text('Favorites', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black),
              title: const Text('Profile', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: Colors.black),
              title: const Text('My Addresses', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined, color: Colors.black),
              title: const Text('Order History', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.black),
              title: const Text('About Us', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined, color: Colors.black),
              title: const Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () async {
                await AuthServices().signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for menus...',
                        prefixIcon: const Icon(Icons.search, color: Colors.green),
                        fillColor: Colors.green[50],
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.green[100]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.green[700]!),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Popular Menus',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: _popularMenus.length,
                      itemBuilder: (context, index) {
                        final menu = _popularMenus[index];
                        return SizedBox(
                          width: 160,
                          child: MenuCard(menu: menu),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Categories',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            label: Text(
                              category,
                              style: TextStyle(
                                color: _selectedCategory == category
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: _selectedCategory == category,
                            backgroundColor: Colors.green[100],
                            selectedColor: Colors.green,
                            showCheckmark: false,
                            pressElevation: 0.0,
                            onSelected: (selected) {
                              if (selected) {
                                _fetchMenusByCategory(category);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Menus',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _categoryMenus.isEmpty
                          ? const Center(
                              child: Text('No menus in this category'))
                          : GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: _categoryMenus.length,
                              itemBuilder: (context, index) {
                                final menu = _categoryMenus[index];
                                return MenuCard(menu: menu);
                              },
                            )
                ],
              ),
            ),
    );
  }
}
