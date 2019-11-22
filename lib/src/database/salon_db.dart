import 'package:db_course_mobile/src/database/tables/authrization_table.dart';
import 'package:db_course_mobile/src/database/tables/category_table.dart';
import 'package:db_course_mobile/src/database/tables/competence_table.dart';
import 'package:db_course_mobile/src/database/tables/entry_table.dart';
import 'package:db_course_mobile/src/database/tables/feedback_table.dart';
import 'package:db_course_mobile/src/database/tables/subcategory_table.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// База данных салона, которая содержит всё необходимую информацию о таблицах,
/// позволяет совершать запросы, вставки и пр.
class SalonDB {
  /// Путь к базе данных на диске
  final String path;

  /// Конструктор
  SalonDB(this.path);

  /// Список таблиц пользователя
  final _userTable = UserTable();
  final _authTable = AuthorizationTable();

  /// Список таблиц разделов и услуг
  final _categoryTable = CategoryTable();
  final _subcategoryTable = SubcategoryTable();
  final _competenceTable = MasterCompetenceTable();

  /// Список таблиц записи и отзывов
  final _entryTable = EntryTable();
  final _feedbackTable = FeedbackTable();

  Database _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await getDBInstance();
    }

    return _database;
  }

  /// Получение объекта БД, а также создание её, если не существовало.
  Future<Database> getDBInstance() async {
    final dbPath = join(path, 'salon.db');

    return await openDatabase(dbPath, version: 1,
        onCreate: (db, version) async {
      /// Пользователь
      await db.execute(_userTable.createTable);
      await db.execute(_authTable.createTable);

      /// Разделы
      await db.execute(_categoryTable.createTable);
      await db.execute(_subcategoryTable.createTable);
      await db.execute(_competenceTable.createTable);

      /// Записи
      await db.execute(_entryTable.createTable);
      await db.execute(_feedbackTable.createTable);
    });
  }

  /// Внесение в БД информации о новом пользователе.
  /// Если пользователь уже зарегистрирован, то будет выброшено исклчючение.
  /// Если всё окей, вернёт токен.
  Future<String> signUpUser(Roles role, String phone, String name,
      String lastName, String passwordHash,
      [String city, double priceCoefficient]) async {
    assert(role != Roles.Admin);
    assert(role == Roles.Client ||
        role == Roles.Master && city != null && priceCoefficient != null);
    final token = await _userTable.signUpUser(await database, role, phone, name,
        lastName, passwordHash, city, priceCoefficient);
    return token;
  }

  /// Авторизация пользователя.
  /// Если всё окей, вернёт токен, иначе выбросит ошибку
  Future<String> logInUser(String phone, String passwordHash) async {
    assert(passwordHash != null && phone != null);
    final token =
        await _userTable.logInUser(await database, phone, passwordHash);
    return token;
  }

  /// Добавление категории в БД
  Future<void> addCategory(String name) async {
    assert(name != null);
    await _categoryTable.addCategory(await database, name);
  }

  /// Добавляем подкатегорию в БД
  Future<void> addSubcategory(
      String name, String categoryName, double price, int time) async {
    assert(name != null && categoryName != null);
    await _subcategoryTable.addSubcategory(
        await database, name, categoryName, price, time, _categoryTable);
  }

  /// Добавление компетенции мастеру
  Future<void> addMasterCompetence(String phone, String subcategoryName) async {
    await _competenceTable.addCompetenceToMaster(
        await database, phone, subcategoryName, _subcategoryTable, _userTable);
  }

  /// Верификация пользователя по токену
  /// Если пользователь существует, то будет возвращен его объект, иначе
  /// будет брошена ошибка.
  Future<User> verifyUser(String token) async {
    return await _userTable.verifyUser(await database, token, _authTable);
  }

  /// Закрытие БД
  void close() => _database?.close();
}
