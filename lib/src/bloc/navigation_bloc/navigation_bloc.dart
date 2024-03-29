import 'dart:collection';

import 'package:db_course_mobile/src/controllers/user_controller.dart';
import 'package:db_course_mobile/src/database/salon_db.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:db_course_mobile/src/models/subcategory.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'navigation.dart';

import 'package:db_course_mobile/src/bloc/bloc_base.dart';

/// Блок перемещений, отвечает за хранение пользовательских данных,
/// перемещение между страницами
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  Map<String, List<Subcategory>> masterCompetence;

  /// Контроллер для выборки и сортировки мастеров
  BehaviorSubject<List<User>> _masterSubject;

  /// Метод для получения потока мастеров, если контроллер [_masterSubject] не
  /// был инициализирован ранее, то он инициализируется и вызывается метод для
  /// отборки мастеров без фильтров.
  Stream<List<User>> get masters {
    if (_masterSubject == null) {
      _masterSubject = BehaviorSubject();
      filterMasters(database.getMasters(0));
    }

    return _masterSubject.stream;
  }

  /// Дожидаемся выполнения запроса и отправляем результат в поток
  Future<void> filterMasters(Future<List<User>> request) async {
    final masters = await request;
    if (_masterSubject == null) {
      _masterSubject = BehaviorSubject();
    }
    _masterSubject.add(masters);
  }

  final controller = UserController();

  /// Список "запомненных" пользователей
  final _users = LinkedHashSet<User>();

  List<User> get users => _users.toList();

  /// Текущий пользователь сессии
  User _currentUser;

  User get user => _currentUser;

  SalonDB database;

  @override
  NavigationState get initialState => EmptyState();

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    /// Инициализация БД и пользователей
    if (event is InitEvent) {
      final dir = await getApplicationDocumentsDirectory();
      print(dir.path);
      database = SalonDB(dir.path);
      _users.addAll(await database.getDefaultUsers());
      _users.addAll(await controller.read());

      yield AuthState();
    }

    /// Отктырие страниц по запросу
    if (event is MastersEvent) yield MastersPage();
    if (event is ProfileEvent) yield ProfilePage();
    if (event is CategoryEvent) yield CategoryPage();

    /// Авторизация пользователя
    if (event is LogInUser) {
      try {
        print('LOGGING');
        _currentUser = await database.logInUser(event.phone, event.password);
        _users.add(_currentUser);
        controller.save(_users.toList());
        if (_currentUser.role == Roles.Master) {
          masterCompetence =
              await database.getMasterCompetences(_currentUser.id);
        }

        yield ProfilePage();
      } on FormatException catch (_) {
        yield AuthState(error: 'Неверный номер телефона или пароль');
      } on Exception catch (_) {
        yield AuthState(
            error: 'Пользователь с таким номером телефона не существует');
      }
    }

    /// Регистрация нового пользователя
    if (event is SignUpUser) {
      try {
        _currentUser = await database.signUpUser(
            event.role,
            event.phone,
            event.name,
            event.lastName,
            event.password,
            event.city,
            event.priceCoef);
        _users.add(_currentUser);
        controller.save(_users.toList());
        if (_currentUser.role == Roles.Master) {
          masterCompetence =
              await database.getMasterCompetences(_currentUser.id);
        }

        yield ProfilePage();
      } on Exception catch (_) {
        yield AuthState(error: 'Пользователь с таким телефоном уже существует');
      }
    }

    /// Выход пользователя
    if (event is LogOut) {
      _currentUser = null;
      yield AuthState();
    }

    /// Вход запомненного пользователя
    if (event is LogInRemembered) {
      _currentUser = event.user;
      if (_currentUser.role == Roles.Master) {
        masterCompetence = await database.getMasterCompetences(_currentUser.id);
      }
      yield ProfilePage();
    }

    /// Удаление пользователя из памяти
    if (event is ForgetUser) {
      _currentUser = null;
      _users.remove(event.user);
      controller.save(_users.toList());

      yield AuthState();
    }
  }

  @override
  void dispose() {
    _users.clear();
    _masterSubject?.close();
    _currentUser = null;
    super.dispose();
  }
}
