import 'package:db_course_mobile/src/database/tables/authrization_table.dart';
import 'package:db_course_mobile/src/database/tables/category_table.dart';
import 'package:db_course_mobile/src/database/tables/competence_table.dart';
import 'package:db_course_mobile/src/database/tables/entry_table.dart';
import 'package:db_course_mobile/src/database/tables/feedback_table.dart';
import 'package:db_course_mobile/src/database/tables/subcategory_table.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:db_course_mobile/src/models/subcategory.dart';
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
  Future<User> signUpUser(Roles role, String phone, String name,
      String lastName, String passwordHash,
      [String city, double priceCoefficient]) async {
    assert(role != Roles.Admin);
    assert(role == Roles.Client ||
        role == Roles.Master && city != null && priceCoefficient != null);
    final user = await _userTable.signUpUser(await database, role, phone, name,
        lastName, passwordHash, city, priceCoefficient);
    return user;
  }

  /// Авторизация пользователя.
  /// Если всё окей, вернёт токен, иначе выбросит ошибку
  Future<User> logInUser(String phone, String passwordHash) async {
    assert(passwordHash != null && phone != null);
    final user =
        await _userTable.logInUser(await database, phone, passwordHash);
    return user;
  }

  /// Добавление категории в БД
  Future<void> addCategory(String name) async {
    assert(name != null);
    await _categoryTable.addCategory(await database, name);
  }

  /// Добавляем подкатегорию в БД
  Future<void> addSubcategory(
      String name, int categoryId, double price, int time) async {
    assert(name != null && categoryId != null);
    await _subcategoryTable.addSubcategory(
        await database, name, categoryId, price, time, _categoryTable);
  }

  /// Добавление компетенции мастеру
  Future<void> addMasterCompetence(int userId, int subcategoryId) async {
    await _competenceTable.addCompetenceToMaster(
        await database, userId, subcategoryId, _userTable, _subcategoryTable);
  }

  /// Верификация пользователя по токену
  /// Если верификация не пройдена, то будет возвращен false, иначе true
  Future<bool> verifyUser(String token) async {
    return await _userTable.verifyUser(await database, token, _authTable);
  }

  /// Получаем список компетенций мастера, которые он может выполнить.
  Future<List<Subcategory>> getMasterCompetences(int masterId) async {
    return await _competenceTable.getMasterCompetence(
        await database, masterId, _userTable, _subcategoryTable);
  }

  /// Получаем список мастеров
  Future<List<User>> getMasters() async {
    return await _userTable.getMasters(await database);
  }

  /// Получаем список мастеров по городу
  Future<List<User>> getMastersByCity(String city) async {
    return await _userTable.getMastersByCity(await database, city);
  }

  /// Получаем список мастеров по компетенции
  Future<List<User>> getMastersByCompetence(int subcategoryId) async {
    return await _userTable.getMastersByCompetence(
        await database, subcategoryId, _competenceTable);
  }

  /// Закрытие БД
  void close() => _database?.close();
}
