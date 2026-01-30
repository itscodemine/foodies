import 'package:foodies/models/cart_item_model.dart';
import 'package:foodies/models/menu_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  void add(MenuModel menu) {
    final existingItemIndex =
        _items.indexWhere((item) => item.menu.id == menu.id);
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity++;
    } else {
      _items.add(CartItemModel(menu: menu));
    }
  }

  void remove(CartItemModel item) {
    _items.remove(item);
  }

  void updateQuantity(CartItemModel item, int quantity) {
    item.quantity = quantity;
    if (item.quantity <= 0) {
      remove(item);
    }
  }

  void clear() {
    _items.clear();
  }
}
