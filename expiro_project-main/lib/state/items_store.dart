import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/items.dart';
import '../service/notification_service.dart';



class ItemsStore extends ChangeNotifier {
  List<Item> _items     = [];
  int        _idCounter = 0;
  bool       _isLoading = true;

  List<Item> get items        => List.unmodifiable(_items);
  bool       get isLoading    => _isLoading;
  int        get totalCount   => _items.length;
  int        get expiredCount => _items.where((e) => e.status == ItemStatus.expired).length;
  int        get soonCount    => _items.where((e) => e.status == ItemStatus.soon).length;
  int        get freshCount   => _items.where((e) => e.status == ItemStatus.fresh).length;

  List<Item> filtered(String filter, String query) {
    return _items.where((item) {
      final matchFilter = filter == 'All'
          || (filter == 'Fav'     && item.isFavorite)
          || (filter == 'Expired' && item.status == ItemStatus.expired)
          || (filter == 'Soon'    && item.status == ItemStatus.soon)
          || (filter == 'Fresh'   && item.status == ItemStatus.fresh);
      final matchSearch = query.isEmpty
          || item.name.toLowerCase().contains(query.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  Future<void> load() async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString('items');
      final idCounter = prefs.getInt('idCounter');

      if (itemsJson != null) {
        final decoded = jsonDecode(itemsJson) as List<dynamic>;
        _items     = decoded
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList();
        _idCounter = idCounter ?? _items.length;
      }
    } catch (e) {
      debugPrint('ItemsStore.load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (_items.isNotEmpty) {
      await NotificationService().rescheduleAll(_items);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'items',
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
    await prefs.setInt('idCounter', _idCounter);
  }


  Future<void> addItem(
      String name,
      ProductType type,
      DateTime expiry,
      int qty,
      ) async {
    final item = Item(
      id:         _idCounter++,
      name:       name,
      type:       type,
      expiryDate: expiry,
      quantity:   qty,
    );
    _items.add(item);
    notifyListeners();
    await NotificationService().scheduleItemNotification(item);
    await _save();
  }


  Future<void> updateItem(
      int id,
      String name,
      ProductType type,
      DateTime expiry,
      int qty,
      ) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final updated = _items[idx].copyWith(
      name:       name,
      type:       type,
      expiryDate: expiry,
      quantity:   qty,
    );
    _items[idx] = updated;
    notifyListeners();
    await NotificationService().scheduleItemNotification(updated);
    await _save();
  }

  Future<void> updateQuantity(int id, int delta) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final newQty = (_items[idx].quantity + delta).clamp(1, 999);
    if (newQty == _items[idx].quantity) return;

    _items[idx] = _items[idx].copyWith(quantity: newQty);
    notifyListeners();
    await _save();
  }

  Future<void> toggleFavorite(int id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(isFavorite: !_items[idx].isFavorite);
    notifyListeners();
    await _save();
  }

  Future<({Item item, int index})> deleteItem(int id) async {
    final idx         = _items.indexWhere((e) => e.id == id);
    final deletedItem = _items[idx];

    await NotificationService().cancelItemNotification(id);
    _items.removeAt(idx);
    notifyListeners();
    await _save();

    return (item: deletedItem, index: idx);
  }

  Future<void> undoDelete(Item item, int index) async {
    _items.insert(index.clamp(0, _items.length), item);
    notifyListeners();
    await NotificationService().scheduleItemNotification(item);
    await _save();
  }


  Future<void> clearAll() async {
    await NotificationService().cancelAll();
    _items.clear();
    _idCounter = 0;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('items');
    await prefs.remove('idCounter');
  }
}



class ItemsScope extends InheritedNotifier<ItemsStore> {
  const ItemsScope({
    super.key,
    required ItemsStore store,
    required super.child,
  }) : super(notifier: store);

  static ItemsStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ItemsScope>();
    assert(scope != null, 'ItemsScope مش موجود في الـ widget tree');
    return scope!.notifier!;
  }

  static ItemsStore read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<ItemsScope>()
        ?.widget as ItemsScope?;
    assert(scope != null, 'ItemsScope مش موجود في الـ widget tree');
    return scope!.notifier!;
  }
}