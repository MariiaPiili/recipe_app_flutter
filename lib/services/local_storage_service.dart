import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';
import '../models/shopping_item.dart';

class LocalStorageService {
  LocalStorageService._internal();

  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() => _instance;

  static const String _keyFavoriteMeals = 'favorite_meals';
  static const String _keyShoppingItems = 'shopping_items';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ---------- FAVORITE MEALS ----------

  Future<void> saveFavoriteMeals(List<Meal> meals) async {
    final prefs = await _prefs;

    final list = meals.map((m) => m.toStorageJson()).toList();

    final jsonString = jsonEncode(list);
    await prefs.setString(_keyFavoriteMeals, jsonString);
  }

  Future<List<Meal>> loadFavoriteMeals() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_keyFavoriteMeals);
    if (jsonString == null || jsonString.isEmpty) {
      return <Meal>[];
    }

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => Meal.fromStorageJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // если вдруг формат сломался — лучше вернуть пустой список,
      // чтобы не падало всё приложение
      return <Meal>[];
    }
  }

  // ---------- SHOPPING ITEMS ----------

  Future<void> saveShoppingItems(List<ShoppingItem> items) async {
    final prefs = await _prefs;

    final list = items.map((i) => i.toJson()).toList();

    final jsonString = jsonEncode(list);
    await prefs.setString(_keyShoppingItems, jsonString);
  }

  Future<List<ShoppingItem>> loadShoppingItems() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_keyShoppingItems);
    if (jsonString == null || jsonString.isEmpty) {
      return <ShoppingItem>[];
    }

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <ShoppingItem>[];
    }
  }
}
