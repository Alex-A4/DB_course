import 'package:db_course_mobile/src/controllers/user_controller.dart';
import 'package:db_course_mobile/src/database/salon_db.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:path_provider/path_provider.dart';

import 'navigation.dart';

import 'package:db_course_mobile/src/bloc/bloc_base.dart';

/// Блок перемещений, отвечает за хранение пользовательских данных,
/// перемещение между страницами
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final controller = UserController();

  /// Список "запомненных" пользователей
  final _users = <User>[];

  List<User> get users => _users;

  /// Текущий пользователь сессии
  User _currentUser;

  User get user => _currentUser;

  SalonDB _database;

  @override
  NavigationState get initialState => EmptyState();

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    /// Инициализация БД и пользователей
    if (event is InitEvent) {
      final dir = await getApplicationDocumentsDirectory();
      _database = SalonDB(dir.path);
      _users.addAll(await _database.getDefaultUsers());
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
        _currentUser = await _database.logInUser(event.phone, event.password);
        _users.add(_currentUser);
        controller.save(_users);

        yield ProfilePage();
      } on FormatException catch (e) {
        yield AuthState(error: 'Неверный номер телефона или пароль');
      } on Exception catch (_) {
        yield AuthState(error: 'Пользователь с таким телефоном не существует');
      }
    }

    /// Регистрация нового пользователя
    if (event is SignUpUser) {
      try {
        _currentUser = await _database.signUpUser(event.role, event.phone,
            event.name, event.lastName, event.password);
        _users.add(_currentUser);
        controller.save(_users);

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
      yield ProfilePage();
    }

    /// Удаление пользователя из памяти
    if (event is ForgetUser) {
      _currentUser = null;
      _users.remove(event.user);
      controller.save(_users);

      yield AuthState();
    }
  }

  @override
  void dispose() {
    _users.clear();
    _currentUser = null;
    super.dispose();
  }
}
