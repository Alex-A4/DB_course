import 'package:db_course_mobile/src/database/tables/authrization_table.dart';
import 'package:db_course_mobile/src/database/tables/category_table.dart';
import 'package:db_course_mobile/src/database/tables/competence_table.dart';
import 'package:db_course_mobile/src/database/tables/entry_table.dart';
import 'package:db_course_mobile/src/database/tables/feedback_table.dart';
import 'package:db_course_mobile/src/database/tables/subcategory_table.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:db_course_mobile/src/models/entry.dart';
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
      await signUpUser(
          Roles.Admin, '89605387240', 'Alex', 'Adrianov', '12345qwer');

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
  Future<void> addCategory(String token, String name) async {
    assert(name != null);
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Admin)
      throw Exception('Wrong access level');
    await _categoryTable.addCategory(await database, name);
  }

  /// Добавляем подкатегорию в БД
  Future<void> addSubcategory(
      String token, String name, int categoryId, double price, int time) async {
    assert(name != null && categoryId != null);
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Admin)
      throw Exception('Wrong access level');

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
  Future<User> verifyUser(String token) async {
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

  /// Создаём запись клиента к мастеру
  Future<Entry> createEntry(String token, int clientId, int masterId,
      int subcategoryId, DateTime date) async {
    final user = await verifyUser(token);
    if (user == null || user.id != clientId || user.role != Roles.Client)
      throw Exception('Wrong token or id');
    return await _entryTable.createEntry(
        await database, clientId, masterId, subcategoryId, date);
  }

  /// Получение записей к мастеру для просмотра
  Future<List<Entry>> getMasterEntries(String token, int masterId) async {
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Master || user.id != masterId)
      throw Exception('Wrong token, id or role');

    return await _entryTable.getMasterEntries(await database, masterId);
  }

  /// Получение записей к мастеру для просмотра
  Future<List<Entry>> getClientEntries(String token, int clientId) async {
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Client || user.id != clientId)
      throw Exception('Wrong token, id or role');

    return await _entryTable.getClientEntries(await database, clientId);
  }

  /// Закрытие БД
  void close() => _database?.close();
}
