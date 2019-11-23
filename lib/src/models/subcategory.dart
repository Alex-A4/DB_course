/// Модель подкатегорий
class Subcategory {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final int executionTime;

  Subcategory(
      this.id, this.categoryId, this.name, this.price, this.executionTime);
}
