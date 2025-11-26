import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Ищет блюда по ключевому слову, например 'pasta'.
  /// Возвращает список объектов из поля "meals" (как dynamic)
  Future<List<Meal>> searchMeals(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return <Meal>[];
    }

    final url = Uri.parse('$_baseUrl/search.php?s=$trimmed');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load meals (code ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final mealsJson = data['meals'] as List<dynamic>?;

    if (mealsJson == null) {
      return <Meal>[];
    }

    // превращаем список map-ов из JSON в список Meal
    return mealsJson
        .map((item) => Meal.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
