import 'package:db_course_mobile/src/database/tables/authrization_table.dart';
import 'package:db_course_mobile/src/database/tables/competence_table.dart';
import 'package:db_course_mobile/src/database/tables/subcategory_table.dart';
import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Таблица пользователя, является хранилищем информации о пользователе.
class UserTable extends TableDb {
  /// Создаёт таблицу с информацией о пользователе.
  /// user_id - главный ключ, идентификатор
  /// role - роль пользователя, индекс одного из [Roles], обязательна для всех
  /// phone_number - номер телефона (аналог почты), обязательна для всех
  /// first_name - имя пользователя, обязательна для всех
  /// last_name - фамилия пользователя, обязательна для всех
  /// password_hash - хэш пароля пользователя, обязателен для всех
  /// city - город, обязателен только для мастера
  /// price_coef - коэффициент стоимости, обязателен только для мастеров, нужен
  /// для определения итоговой стоимости, которая вычисляется как базовая * коэффициент.
  ///
  /// Роль администратора позволяет выполнять некоторые сложные запросы, например
  /// редактирование категорий
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    user_id        INTEGER PRIMARY KEY NOT NULL,
    role           INTEGER NOT NULL,
    phone_number   VARCHAR(20) NOT NULL,
    first_name     VARCHAR(20) NOT NULL,
    last_name      VARCHAR(20) NOT NULL,
    password_hash  TEXT NOT NULL,
    city           TEXT,
    price_coef     REAL
  )''';

  @override
  String get tableName => 'User';

  @override
  String get tableColumns => '''
  role, phone_number, first_name, last_name, password_hash, city, price_coef
  ''';

  /// Создание стандартных записей
  Future<void> createDefault(Database db) async {
    await signUpUser(db, Roles.Admin, '89605387240', 'Alex', 'Adrianov',
        '12345qwer', null, null);

    await signUpUser(db, Roles.Master, '8-950-324-12-01', 'Вика', 'Васина',
        '123456', 'Moscow', 1.4);
    await signUpUser(db, Roles.Master, '8-950-324-12-02', 'Мила', 'Кручина',
        '123456', 'Moscow', 0.9);
    await signUpUser(db, Roles.Master, '8-950-324-12-03', 'Кира', 'Весенина',
        '123456', 'Yaroslavl', 1.0);

    await signUpUser(db, Roles.Client, '8-950-324-10-01', 'Власин', 'Власович',
        '123456', null, null);
    await signUpUser(db, Roles.Client, '8-950-324-10-02', 'Каштан', 'Туманович',
        '123456', null, null);
  }

  /// Регистрация нового пользователя.
  /// Если пользователь уже зарегистрирован, то будет выброшено исклчючение.
  /// Если всё окей, вернёт токен.
  Future<User> signUpUser(
      Database db,
      Roles role,
      String phone,
      String name,
      String lastName,
      String passwordHash,
      String city,
      double priceCoefficient) async {
    final oldUser = await db.rawQuery('''
    SELECT * from $tableName WHERE phone_number = $phone;
    ''');

    if (oldUser.isNotEmpty) throw Exception('User already exists');

    final auth = AuthorizationTable();

    final id = await db.rawInsert('''
    INSERT INTO $tableName ($tableColumns)
    VALUES (${role.index}, "$phone", "$name", "$lastName", "$passwordHash", 
    ${'"$city"' ?? 'NULL'}, ${'"$priceCoefficient"' ?? 'NULL'});
    ''');

    await db.rawInsert('''
    INSERT INTO ${auth.tableName} (${auth.tableColumns})
    VALUES ((SELECT MAX(user_id) from $tableName ), "${Uuid().v4()}");
    ''');

    final data = await db.rawQuery('''
    SELECT a.user_id, $tableColumns, a.token FROM $tableName
      INNER JOIN ${auth.tableName} as a ON
        $tableName.user_id = a.user_id
      WHERE a.user_id = $id
    ''');

    return User.fromData(data.first);
  }

  /// Авторизация пользователя в системе
  /// Если пароль или номер неправильные, будет выброшено исключение.
  /// Если всё окей, то вернёт токен.
  Future<User> logInUser(Database db, String phone, String password) async {
    final oldUser = await db.rawQuery('''
    SELECT * FROM $tableName WHERE phone_number = "$phone";
    ''');

    if (oldUser.isEmpty) throw Exception('User not exists');
    if (oldUser.first['password_hash'] != password)
      throw Exception('Wrong password');

    final token = Uuid().v4();
    final auth = AuthorizationTable();

    await db.rawInsert('''
    UPDATE ${auth.tableName}
    SET token = "$token"
    WHERE user_id == ${oldUser.first['user_id']};
    ''');

    final data = await db.rawQuery('''
    SELECT a.user_id, $tableColumns, a.token FROM $tableName
      INNER JOIN ${auth.tableName} as a ON
        a.user_id = $tableName.user_id
      WHERE a.token = "$token";
    ''');

    return User.fromData(data.first);
  }

  /// Верификация пользователя по токену.
  /// Если пользователь не существует или токен не верный, то вернёт false,
  /// иначе true
  Future<User> verifyUser(
      Database db, String token, AuthorizationTable auth) async {
    final userData = await db.rawQuery('''
    SELECT u.user_id, $tableColumns, a.token FROM $tableName as u
      INNER JOIN ${auth.tableName} as a ON
        u.user_id = a.user_id 
      WHERE a.token = "$token";
    ''');
    if (userData.isEmpty) return null;
    return User.fromData(userData.first);
  }

  /// Получаем список мастеров
  Future<List<User>> getMasters(Database db, int offset) async {
    final users = await db.rawQuery('''
    SELECT DISTINCT * FROM $tableName WHERE role = 0
    GROUP BY city
    ORDER BY first_name ASC, last_name ASC
    LIMIT 20 OFFSET $offset;
    ''');

    return users.map((u) => User.fromData(u)).cast<User>().toList();
  }

  /// Получаем список мастеров в указанном городе
  Future<List<User>> getMastersByCity(
      Database db, String city, int offset) async {
    final users = await db.rawQuery('''
    SELECT DISTINCT * FROM $tableName WHERE role = 0 AND city = "$city";
    ORDER BY first_name ASC, last_name ASC
    LIMIT 20 OFFSET $offset;
    ''');

    return users.map((u) => User.fromData(u)).cast<User>().toList();
  }

  /// Получаем список мастеров по общей категории
  Future<List<User>> getMastersByCategory(
      Database db,
      int categoryId,
      int offset,
      SubcategoryTable subcategory,
      MasterCompetenceTable competence) async {
    final users = await db.rawQuery('''
    SELECT DISTINCT $tableName.user_id, $tableColumns FROM $tableName
      INNER JOIN ${competence.tableName} as com ON
        com.user_id = $tableName.user_id AND com.subcategory_id = sub.subcategory_id
      INNER JOIN ${subcategory.tableName} as sub ON
        sub.category_id = $categoryId
      GROUP BY city
      ORDER BY first_name ASC, last_name ASC
      LIMIT 20 OFFSET $offset;
    ''');
    return users.map((u) => User.fromData(u)).cast<User>().toList();
  }

  /// Получаем список мастеров с указанной компетенцией.
  Future<List<User>> getMastersByCompetence(Database db, int subcategoryId,
      MasterCompetenceTable competence, int offset) async {
    final users = await db.rawQuery('''
    SELECT DISTINCT * FROM $tableName 
      INNER JOIN ${competence.tableName} as c ON
        c.user_id = $tableName.user_id AND c.subcategory_id = $subcategoryId
    WHERE role = 0
    GROUP BY city
    ORDER BY first_name ASC, last_name ASC
    LIMIT 20 OFFSET $offset;
    ''');

    return users.map((u) => User.fromData(u)).cast<User>().toList();
  }
}

/// Роли, которые распределяются среди пользователей
/// [Roles.Master] - роль мастера, который принимает заказы
/// [Roles.Client] - клиент, который ходит на приёмы
/// [Roles.Admin] - администратор, который можешь редактировать БД
enum Roles { Master, Client, Admin }
