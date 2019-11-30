/// Модель подкатегорий
class Subcategory {
  final int id;
  final int categoryId;
  final String name;
  final String categoryName;
  final double price;
  final int executionTime;

  Subcategory(this.id, this.categoryId, this.name, this.price,
      this.executionTime, this.categoryName);

  factory Subcategory.fromData(Map<String, dynamic> data) {
    return Subcategory(
      data['subcategory_id'],
      data['category_id'],
      data['name'],
      data['base_price'],
      data['execution_time'],
      data['category_name'],
    );
  }

  @override
  String toString() =>
      '$categoryId $categoryName $id $name $price $executionTime';
}
