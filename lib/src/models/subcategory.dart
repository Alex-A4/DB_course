/// Модель подкатегорий
class Subcategory {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final int executionTime;

  Subcategory(
      this.id, this.categoryId, this.name, this.price, this.executionTime);

  factory Subcategory.fromData(Map<String, dynamic> data) {
    return Subcategory(
      data['subcategory_id'],
      data['category_id'],
      data['name'],
      data['base_price'],
      data['execution_time'],
    );
  }

  @override
  String toString() => '$id $categoryId $name $price $executionTime';
}
