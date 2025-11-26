class Meal {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? category;
  final String? area;

  /// Полный текст инструкции по приготовлению
  final String? instructions;

  /// Список строк вида "2 cups flour", "1 tsp salt"
  final List<String> ingredients;

  const Meal({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.category,
    this.area,
    this.instructions,
    this.ingredients = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // для ответа API
    // Собираем ингредиенты и меры из полей strIngredient1..20 и strMeasure1..20
    final ingredients = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = (json['strIngredient$i'] as String?)?.trim();
      final measure = (json['strMeasure$i'] as String?)?.trim();

      if (ingredient != null && ingredient.isNotEmpty) {
        if (measure != null && measure.isNotEmpty) {
          ingredients.add('$measure $ingredient');
        } else {
          ingredients.add(ingredient);
        }
      }
    }

    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnailUrl: json['strMealThumb'] as String?,
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      ingredients: ingredients,
    );
  }

  /// Используется для чтения из ЛОКАЛЬНОГО хранилища (shared_preferences и т.п.). для локального восстановления
  factory Meal.fromStorageJson(Map<String, dynamic> json) {
    final ingredientsJson = json['ingredients'] as List<dynamic>? ?? const [];
    final ingredients = ingredientsJson.map((e) => e as String).toList();

    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      category: json['category'] as String?,
      area: json['area'] as String?,
      instructions: json['instructions'] as String?,
      ingredients: ingredients,
    );
  }

  /// Превращаем Meal в простой Map<String, dynamic>, удобный для хранения. для сохранения в локальный storage.
  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'name': name,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'area': area,
      'instructions': instructions,
      'ingredients': ingredients,
    };
  }

    Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'area': area,
      'instructions': instructions,
      'ingredients': ingredients,
    };
  }

  factory Meal.fromFirestore(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String,
      name: map['name'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      category: map['category'] as String?,
      area: map['area'] as String?,
      instructions: map['instructions'] as String? ?? '',
      ingredients: (map['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

}
