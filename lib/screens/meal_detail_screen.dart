import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/meal.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;
  final void Function(Meal meal)? onAddToShoppingList;

  const MealDetailScreen({
    super.key,
    required this.meal,
    this.onAddToShoppingList,
  });

  // ---------- SHARE ----------

  void _shareMeal() {
    final buffer = StringBuffer();

    // Название
    buffer.writeln(meal.name);

    // Категория / регион
    if (meal.category != null || meal.area != null) {
      buffer.writeln(
        [
          if (meal.category != null) meal.category,
          if (meal.area != null) meal.area,
        ].whereType<String>().join(' • '),
      );
    }

    // Ингредиенты
    if (meal.ingredients.isNotEmpty) {
      buffer.writeln('\nIngredients:');
      for (final ing in meal.ingredients) {
        buffer.writeln('• $ing');
      }
    }

    // Инструкции
    final instructions = meal.instructions ?? '';
    if (instructions.trim().isNotEmpty) {
      buffer.writeln('\nInstructions:');
      final text = instructions;
      buffer.writeln(text.length > 600 ? '${text.substring(0, 600)}…' : text);
    }

    Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final instructions = meal.instructions ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareMeal),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Картинка
              if (meal.thumbnailUrl != null && meal.thumbnailUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    meal.thumbnailUrl!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              if (meal.thumbnailUrl != null && meal.thumbnailUrl!.isNotEmpty)
                const SizedBox(height: 16),

              // Категория / регион
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (meal.category != null && meal.category!.isNotEmpty)
                    Chip(
                      label: Text(meal.category!),
                      backgroundColor: cs.primaryContainer,
                      labelStyle: TextStyle(color: cs.onPrimaryContainer),
                    ),
                  if (meal.area != null && meal.area!.isNotEmpty)
                    Chip(
                      label: Text(meal.area!),
                      backgroundColor: cs.secondaryContainer,
                      labelStyle: TextStyle(color: cs.onSecondaryContainer),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Ингредиенты
              Text(
                'Ingredients',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              if (meal.ingredients.isEmpty)
                const Text('No ingredients information.')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: meal.ingredients
                      .map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(line)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),

              const SizedBox(height: 24),

              // Инструкции
              Text(
                'Instructions',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                instructions.trim().isNotEmpty
                    ? instructions
                    : 'No instructions available.',
              ),

              const SizedBox(height: 24),

              // Кнопка "добавить в список покупок"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Add ingredients to shopping list'),
                  onPressed: onAddToShoppingList == null
                      ? null
                      : () {
                          onAddToShoppingList!(meal);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ingredients added to shopping list',
                              ),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
