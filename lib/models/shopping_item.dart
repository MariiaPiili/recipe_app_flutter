class ShoppingItem {
  final String name;
  final bool isDone;

  const ShoppingItem({required this.name, this.isDone = false});

  ShoppingItem copyWith({String? name, bool? isDone}) {
    return ShoppingItem(name: name ?? this.name, isDone: isDone ?? this.isDone);
  }

  /// Для сохранения в локальное хранилище.
  Map<String, dynamic> toJson() {
    return {'name': name, 'isDone': isDone};
  }

  /// Для восстановления из локального хранилища.
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  /// Для Firestore можем просто использовать те же данные.
  Map<String, dynamic> toFirestore() => toJson();

  factory ShoppingItem.fromFirestore(Map<String, dynamic> map) =>
      ShoppingItem.fromJson(map);
}
