/// Модель категории
class Category {
  final int id;
  final String name;

  Category(this.id, this.name);

  factory Category.fromData(Map<String, dynamic> data) {
    return Category(data['category_id'], data['category_name']);
  }
}
