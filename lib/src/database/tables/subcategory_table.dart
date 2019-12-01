import 'package:db_course_mobile/src/database/tables/category_table.dart';
import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:db_course_mobile/src/models/subcategory.dart';
import 'package:sqflite/sqlite_api.dart';

/// Таблица подкатегорий, является нижним уровнем в иерархии категорий,
/// описывает конкретные процедуры и их параметры.
class SubcategoryTable extends TableDb {
  /// Создаёт таблицу с названием подкатегории, которая описывает
  /// конкретную процедуру.
  /// subcategory_id - идентификатор процедуры
  /// category_id - идентификатор раздела
  /// name - название процедуры
  /// base_price - базовая цена за процедуру, от которой рассчитывается итоговая
  /// стоимость.
  /// execution_time - время выполнения в минутах
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    subcategory_id    INTEGER PRIMARY KEY NOT NULL,
    category_id       INTEGER   NOT NULL,
    name              TEXT NOT NULL,
    base_price        REAL NOT NULL,
    execution_time    INTEGER NOT NULL,
    
    FOREIGN KEY (category_id)
        REFERENCES Category(category_id)
          ON UPDATE RESTRICT
          ON DELETE CASCADE
  )''';

  @override
  String get tableName => 'Subcategory';

  @override
  String get tableColumns => 'category_id, name, base_price, execution_time';

  /// Создание записей по умолчанию
  Future<void> createDefault(Database db) async {
    await db.rawInsert('''
    INSERT INTO $tableName ($tableColumns)
    VALUES (1, "Классический маникюр", 200.0, 40),
           (1, "Маникюр без покрытия", 200.0, 40),
           (1, "Макинюр с покрытием", 350.0, 60),
           (1, "Аппаратный маникюр", 400.0, 50),
           (1, "Комбинированный маникюр", 500.0, 70),
           
           (2, "Классическое оформление", 300.0, 20),
           (2, "Оформление воском", 400.0, 30),
           (2, "Окрашивание хной", 600.0, 50),
           (2, "Окрашиваение краской", 550.0, 40),
           
           (3, "Расслабляющий", 300.0, 30),
           (3, "Лечебный", 400.0, 30),
           (3, "По зонам", 400.0, 30);
    ''');
  }

  /// Добавляем подкатегорию в БД
  Future<Subcategory> addSubcategory(Database db, String name, int categoryId,
      double price, int time, CategoryTable category) async {
    final id = await db.rawInsert('''
    INSERT INTO $tableName (category_id, name, base_price, execution_time)
    VALUES ($categoryId, "$name", $price, $time);
    ''');

    final subData = await db.rawQuery('''
    SELECT * FROM $tableName WHERE subcategory_id = $id;
    ''');

    return Subcategory.fromData(subData.first);
  }

  /// Получаем список всех категорий и подкатегорий
  Future<Map<String, List<Subcategory>>> getSubcategories(
      Database db, CategoryTable category) async {
    final data = await db.rawQuery('''
    SELECT $tableName.category_id, $tableName.subcategory_id, $tableName.name, 
    $tableName.base_price, $tableName.execution_time, cat.category_name
    FROM $tableName
      LEFT JOIN ${category.tableName} as cat ON
        $tableName.category_id = cat.category_id;
    ORDER BY cat.category_id ASC, $tableName.subcategory_id ASC;
    ''');

    final subs =
        data.map((s) => Subcategory.fromData(s)).cast<Subcategory>().toList();

    final result = <String, List<Subcategory>>{};
    subs.forEach((s) {
      if (result[s.categoryName] == null)
        result[s.categoryName] = [s];
      else
        result[s.categoryName].add(s);
    });

    return result;
  }
}
