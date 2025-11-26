import 'package:flutter/material.dart';
import '../services/meal_api_service.dart';
import '../models/meal.dart';
import 'meal_detail_screen.dart';
import '../models/shopping_item.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  final _storage = LocalStorageService();
  final _firestore = FirestoreService();
  final _auth = AuthService();

  final List<Meal> _favoriteMeals = [];
  final List<ShoppingItem> _shoppingItems = [];

  bool _isFavorite(Meal meal) {
    return _favoriteMeals.any((m) => m.id == meal.id);
  }

  void _toggleFavorite(Meal meal) async {
    setState(() {
      final index = _favoriteMeals.indexWhere((m) => m.id == meal.id);
      if (index >= 0) {
        _favoriteMeals.removeAt(index);
      } else {
        _favoriteMeals.add(meal);
      }
    });

    // локальное сохранение
    await _storage.saveFavoriteMeals(_favoriteMeals);

    // облако — если пользователь залогинен
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.saveFavorites(
          uid: user.uid,
          favorites: _favoriteMeals,
        );
      } catch (e) {
        // можно игнорировать, чтобы UI не ломался без сети
      }
    }
  }

  void _toggleShoppingItemDone(ShoppingItem item) async {
    setState(() {
      final index = _shoppingItems.indexWhere((it) => it.name == item.name);
      if (index >= 0) {
        final current = _shoppingItems[index];
        _shoppingItems[index] = current.copyWith(isDone: !current.isDone);
      }
    });

    await _storage.saveShoppingItems(_shoppingItems);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.saveShoppingList(uid: user.uid, items: _shoppingItems);
      } catch (_) {}
    }
  }

  void _removeShoppingItem(ShoppingItem item) async {
    setState(() {
      _shoppingItems.removeWhere((it) => it.name == item.name);
    });

    await _storage.saveShoppingItems(_shoppingItems);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.saveShoppingList(uid: user.uid, items: _shoppingItems);
      } catch (_) {}
    }
  }

  void _clearShoppingList() async {
    setState(() {
      _shoppingItems.clear();
    });

    await _storage.saveShoppingItems(_shoppingItems);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.saveShoppingList(uid: user.uid, items: _shoppingItems);
      } catch (_) {}
    }
  }

  void _addIngredientsFromMeal(Meal meal) async {
    setState(() {
      for (final ing in meal.ingredients) {
        if (!_shoppingItems.any((it) => it.name == ing)) {
          _shoppingItems.add(ShoppingItem(name: ing));
        }
      }
    });

    await _storage.saveShoppingItems(_shoppingItems);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.saveShoppingList(uid: user.uid, items: _shoppingItems);
      } catch (_) {}
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. читаем локальные данные
    final localFavorites = await _storage.loadFavoriteMeals();
    final localShopping = await _storage.loadShoppingItems();

    var effectiveFavorites = localFavorites;
    var effectiveShopping = localShopping;

    // 2. если пользователь залогинен — пробуем подтянуть из Firestore
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final remoteFavorites = await _firestore.loadFavorites(uid: user.uid);
        final remoteShopping = await _firestore.loadShoppingList(uid: user.uid);

        // если в облаке уже что-то есть — используем это
        if (remoteFavorites.isNotEmpty) {
          effectiveFavorites = remoteFavorites;
        } else if (localFavorites.isNotEmpty) {
          // если в облаке пусто, но локально было — зальём локальные в облако
          await _firestore.saveFavorites(
            uid: user.uid,
            favorites: localFavorites,
          );
        }

        if (remoteShopping.isNotEmpty) {
          effectiveShopping = remoteShopping;
        } else if (localShopping.isNotEmpty) {
          await _firestore.saveShoppingList(
            uid: user.uid,
            items: localShopping,
          );
        }
      } catch (e) {
        // если сеть / Firestore упали — просто остаёмся на локальных данных
      }
    }

    // 3. обновляем состояние
    setState(() {
      _favoriteMeals
        ..clear()
        ..addAll(effectiveFavorites);
      _shoppingItems
        ..clear()
        ..addAll(effectiveShopping);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _RecipesPage(
        onToggleFavorite: _toggleFavorite,
        isFavorite: _isFavorite,
        onAddIngredientsToList: _addIngredientsFromMeal,
      ),
      _FavoritesPage(
        favorites: _favoriteMeals,
        onToggleFavorite: _toggleFavorite,
        onAddIngredientsToList: _addIngredientsFromMeal,
      ),
      _ShoppingListPage(
        items: _shoppingItems,
        onToggleDone: _toggleShoppingItemDone,
        onRemoveItem: _removeShoppingItem,
        onClearAll: _clearShoppingList,
      ),
    ];

    final titles = ['Recipes', 'Favorites', 'Shopping list'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_tabIndex]), centerTitle: true),
      body: pages[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'List',
          ),
        ],
      ),
    );
  }
}

class _RecipesPage extends StatefulWidget {
  final void Function(Meal meal) onToggleFavorite;
  final bool Function(Meal meal) isFavorite;
  final void Function(Meal meal) onAddIngredientsToList;

  const _RecipesPage({
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.onAddIngredientsToList,
  });

  @override
  State<_RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<_RecipesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _statusText =
      'Type a keyword and tap the search icon to load recipes from API.';
  List<Meal> _meals = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      setState(() {
        _statusText = 'Please enter a search term.';
        _meals = []; // очищаем список
      });
      return;
    }

    setState(() {
      _statusText = 'Loading recipes for "$query"...';
      _meals = []; // пока грузим, очищаем старый результат
    });

    try {
      final service = MealApiService();
      final meals = await service.searchMeals(query); // уже List<Meal>

      setState(() {
        _meals = meals;
        if (_meals.isEmpty) {
          _statusText = 'No meals found for "$query".';
        } else {
          _statusText = 'Found ${_meals.length} meals for "$query".';
        }
      });
    } catch (e) {
      setState(() {
        _meals = [];
        _statusText = 'Error while loading recipes: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search recipes (e.g. pasta, chicken)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _search,
              ),
              filled: true,
              fillColor: cs.surfaceVariant.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _statusText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          // здесь позже будет реальный список рецептов
          Expanded(
            child: _meals.isEmpty
                ? const Center(
                    child: Text(
                      'Recipe list will appear here.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _meals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final meal = _meals[index];
                      final isFav = widget.isFavorite(meal);

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: meal.thumbnailUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    meal.thumbnailUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.restaurant_menu),
                          title: Text(meal.name),
                          subtitle: Text(
                            [
                              if (meal.category != null) meal.category,
                              if (meal.area != null) meal.area,
                            ].whereType<String>().join(' • '),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? cs.primary : null,
                            ),
                            onPressed: () => widget.onToggleFavorite(meal),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MealDetailScreen(
                                  meal: meal,
                                  onAddToShoppingList:
                                      widget.onAddIngredientsToList,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesPage extends StatelessWidget {
  final List<Meal> favorites;
  final void Function(Meal meal) onToggleFavorite;
  final void Function(Meal meal) onAddIngredientsToList;

  const _FavoritesPage({
    required this.favorites,
    required this.onToggleFavorite,
    required this.onAddIngredientsToList,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(child: Text('No favorite recipes yet.'));
    }

    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final meal = favorites[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: meal.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      meal.thumbnailUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.restaurant_menu),
            title: Text(meal.name),
            subtitle: Text(
              [
                if (meal.category != null) meal.category,
                if (meal.area != null) meal.area,
              ].whereType<String>().join(' • '),
            ),
            trailing: IconButton(
              icon: Icon(Icons.favorite, color: cs.primary),
              onPressed: () => onToggleFavorite(meal),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MealDetailScreen(
                    meal: meal,
                    onAddToShoppingList: onAddIngredientsToList,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ShoppingListPage extends StatelessWidget {
  final List<ShoppingItem> items;
  final void Function(ShoppingItem item) onToggleDone;
  final void Function(ShoppingItem item) onRemoveItem;
  final VoidCallback onClearAll;

  const _ShoppingListPage({
    required this.items,
    required this.onToggleDone,
    required this.onRemoveItem,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Кнопка поиска ближайшего магазина
        OutlinedButton.icon(
          icon: const Icon(Icons.location_on_outlined),
          label: const Text('Find nearby grocery store'),
          onPressed: () {
            LocationService.instance.openNearbyGroceryStores(context);
          },
        ),
        const SizedBox(height: 16),

        // Если список пустой — просто текст по центру
        if (items.isEmpty)
          const Expanded(
            child: Center(child: Text('Your shopping list is empty.')),
          ),

        // Если есть элементы — показываем заголовок + список
        if (items.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shopping list',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.name),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => onRemoveItem(item),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: cs.errorContainer,
                    child: Icon(Icons.delete, color: cs.onErrorContainer),
                  ),
                  child: CheckboxListTile(
                    value: item.isDone,
                    onChanged: (_) => onToggleDone(item),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
