import 'package:db_course_mobile/src/database/tables/authrization_table.dart';
import 'package:db_course_mobile/src/database/tables/category_table.dart';
import 'package:db_course_mobile/src/database/tables/competence_table.dart';
import 'package:db_course_mobile/src/database/tables/entry_table.dart';
import 'package:db_course_mobile/src/database/tables/feedback_table.dart';
import 'package:db_course_mobile/src/database/tables/subcategory_table.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:db_course_mobile/src/models/category.dart';
import 'package:db_course_mobile/src/models/entry.dart';
import 'package:db_course_mobile/src/models/feedback.dart';
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

      await _userTable.createDefault(db);
      await _categoryTable.createDefault(db);
      await _subcategoryTable.createDefault(db);
      await _competenceTable.createDefault(db, _userTable, _subcategoryTable);
      await _entryTable.createDefault(db);
      await _feedbackTable.createDefault(db);
    });
  }

  /// Внесение в БД информации о новом пользователе.
  /// Если пользователь уже зарегистрирован, то будет выброшено исклчючение.
  /// Если всё окей, вернёт токен.
  Future<User> signUpUser(Roles role, String phone, String name,
      String lastName, String passwordHash,
      [String city, double priceCoefficient]) async {
    assert(role == Roles.Master && city != null && priceCoefficient != null ||
        true);
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
  Future<Category> addCategory(String token, String name) async {
    assert(name != null);
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Admin)
      throw Exception('Wrong access level');
    return await _categoryTable.addCategory(await database, name);
  }

  /// Добавляем подкатегорию в БД
  Future<Subcategory> addSubcategory(
      String token, String name, int categoryId, double price, int time) async {
    assert(name != null && categoryId != null);
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Admin)
      throw Exception('Wrong access level');

    return await _subcategoryTable.addSubcategory(
        await database, name, categoryId, price, time, _categoryTable);
  }

  /// Получаем список подкатегорий, сгруппированный по категориям
  Future<List<Subcategory>> getSubcategories() async {
    return await _subcategoryTable.getSubcategories(
        await database, _categoryTable);
  }

  /// Добавление компетенции мастеру
  Future<void> addMasterCompetence(
      String token, int userId, int subcategoryId) async {
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Master || user.role != Roles.Admin)
      throw Exception('Wrong access level');
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
    return await _competenceTable.getMasterCompetence(await database, masterId,
        _userTable, _subcategoryTable, _categoryTable);
  }

  /// Получаем список мастеров
  Future<List<User>> getMasters(int offset) async {
    return await _userTable.getMasters(await database, offset);
  }

  /// Получаем список мастеров по городу
  Future<List<User>> getMastersByCity(String city, int offset) async {
    return await _userTable.getMastersByCity(await database, city, offset);
  }

  /// Получаем список мастеров по общей категории
  Future<List<User>> getMastersByCategory(int categoryId, int offset) async {
    return await _userTable.getMastersByCategory(await database, categoryId,
        offset, _subcategoryTable, _competenceTable);
  }

  /// Получаем список мастеров по компетенции
  Future<List<User>> getMastersByCompetence(
      int subcategoryId, int offset) async {
    return await _userTable.getMastersByCompetence(
        await database, subcategoryId, _competenceTable, offset);
  }

  /// Создаём запись клиента к мастеру
  Future<Entry> createEntry(String token, int clientId, int masterId,
      int subcategoryId, DateTime date) async {
    final user = await verifyUser(token);
    if (user == null || user.id != clientId || user.role != Roles.Client)
      throw Exception('Wrong access level');
    return await _entryTable.createEntry(
        await database, clientId, masterId, subcategoryId, date);
  }

  /// Поулчение записи по ID, включает в себя отзыв
  Future<Entry> getEntryById(int entryId) async {
    return await _entryTable.getEntryById(
        await database, entryId, _feedbackTable);
  }

  /// Добавляем отзыв о записи к мастеру
  Future<Feedback> addFeedback(String token, int clientId, int entryId,
      String text, DateTime date) async {
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Client || user.id != clientId)
      throw Exception('Wrong access level');

    final oldFeedback =
        await _feedbackTable.getFeedback(await database, entryId);
    if (oldFeedback != null) throw Exception('Feedback already exists');

    return await _feedbackTable.addFeedback(
        await database, entryId, text, date);
  }

  /// Обновление текста отзыва
  Future<Feedback> updateFeedback(
      String token, int clientId, int entryId, String newText) async {
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Client || user.id != clientId)
      throw Exception('Wrong access level');

    final oldFeedback =
        await _feedbackTable.getFeedback(await database, entryId);
    if (oldFeedback == null) throw Exception("Feedback doesn't exists");

    return _feedbackTable.updateFeedback(await database, entryId, newText);
  }

  /// Возвращает список отзывов о мастере
  Future<List<Feedback>> getFeedbackAboutMaster(int masterId) async {
    return await _feedbackTable.getMasterFeedback(
        await database, masterId, _entryTable, _subcategoryTable);
  }

  /// Получение записей к мастеру для просмотра
  /// Должен выполнять мастер
  Future<List<Entry>> getMasterEntries(String token, int masterId) async {
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Master || user.id != masterId)
      throw Exception('Wrong access level');

    return await _entryTable.getMasterEntries(
        await database, masterId, _feedbackTable);
  }

  /// Получение записей к мастеру для просмотра
  Future<List<Entry>> getClientEntries(String token, int clientId) async {
    final user = await verifyUser(token);
    if (user == null || user.role != Roles.Client || user.id != clientId)
      throw Exception('Wrong access level');

    return await _entryTable.getClientEntries(
        await database, clientId, _feedbackTable);
  }

  /// Закрытие БД
  void close() => _database?.close();
}
