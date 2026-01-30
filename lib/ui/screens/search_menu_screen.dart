import 'package:flutter/material.dart';
import 'package:foodies/models/menu_model.dart';
import 'package:foodies/services/menu_services.dart';
import 'package:foodies/ui/widgets/menu_card.dart';

class SearchMenuScreen extends StatefulWidget {
  const SearchMenuScreen({super.key});

  @override
  State<SearchMenuScreen> createState() => _SearchMenuScreenState();
}

class _SearchMenuScreenState extends State<SearchMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MenuModel> _searchedMenus = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _searchMenus() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    final menus = await MenuServices().searchMenus(_searchController.text);
    setState(() {
      _searchedMenus = menus;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Menu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _searchMenus(),
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
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchedMenus.clear();
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched && _searchedMenus.isEmpty
                ? const Center(child: Text('No menus found for your search.'))
                : !_hasSearched
                ? const Center(child: Text('Start searching for menus...'))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _searchedMenus.length,
                    itemBuilder: (context, index) {
                      final menu = _searchedMenus[index];
                      return MenuCard(menu: menu);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
