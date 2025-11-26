import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal.dart';
import '../models/shopping_item.dart';

class FirestoreService {
  FirestoreService._internal();

  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Сохраняем список избранных рецептов для пользователя [uid]
  Future<void> saveFavorites({
    required String uid,
    required List<Meal> favorites,
  }) async {
    final data = favorites.map((m) => m.toFirestore()).toList();

    await _db.collection('users').doc(uid).set(
      {
        'favorites': data,
      },
      SetOptions(merge: true),
    );
  }

  /// Загружаем список избранных рецептов для пользователя [uid]
  Future<List<Meal>> loadFavorites({required String uid}) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return [];

    final rawList = (data['favorites'] as List<dynamic>?);
    if (rawList == null) return [];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((map) => Meal.fromFirestore(map))
        .toList();
  }

  /// Сохраняем shopping list
  Future<void> saveShoppingList({
    required String uid,
    required List<ShoppingItem> items,
  }) async {
    final data = items.map((i) => i.toFirestore()).toList();

    await _db.collection('users').doc(uid).set(
      {
        'shoppingList': data,
      },
      SetOptions(merge: true),
    );
  }

  /// Загружаем shopping list
  Future<List<ShoppingItem>> loadShoppingList({required String uid}) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return [];

    final rawList = (data['shoppingList'] as List<dynamic>?);
    if (rawList == null) return [];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((map) => ShoppingItem.fromFirestore(map))
        .toList();
  }
}
