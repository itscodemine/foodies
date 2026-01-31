import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodies/models/menu_model.dart';
import 'package:foodies/models/user_model.dart';
import 'package:foodies/services/auth_services.dart';
import 'package:foodies/services/menu_services.dart';
import 'package:foodies/ui/screens/cart_screen.dart';
import 'package:foodies/ui/screens/search_menu_screen.dart';
import 'package:foodies/ui/widgets/app_drawer.dart';
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
    'Seafood',
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
    final user = await AuthServices().getUser(
      FirebaseAuth.instance.currentUser!.uid,
    );
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
                      color: Colors.black,
                    ),
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
      drawer: AppDrawer(user: _user),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchMenuScreen(),
                          ),
                        );
                      },
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Search for menus...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.green,
                          ),
                          fillColor: Colors.green[50],
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          disabledBorder: OutlineInputBorder(
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
                  ),
                  const SizedBox(height: 16.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Popular Menus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: _popularMenus.length,
                      itemBuilder: (context, index) {
                        final menu = _popularMenus[index];
                        return SizedBox(
                          width: 140,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _categoryMenus.isEmpty
                      ? const Center(child: Text('No menus in this category'))
                      : GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3 / 4,
                              ),
                          itemCount: _categoryMenus.length,
                          itemBuilder: (context, index) {
                            final menu = _categoryMenus[index];
                            return MenuCard(menu: menu);
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
