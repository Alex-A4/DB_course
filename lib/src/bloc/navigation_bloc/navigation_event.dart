import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:db_course_mobile/src/models/user.dart';

abstract class NavigationEvent {}

/// Событие для инициализации данных
class InitEvent extends NavigationEvent {}

class MastersEvent extends NavigationEvent {}

class ProfileEvent extends NavigationEvent {}

class CategoryEvent extends NavigationEvent {}

/// Событие для авторизации пользователя
class LogInUser extends NavigationEvent {
  final String phone;
  final String password;

  LogInUser(this.phone, this.password);
}

/// Событие для регистрации нового пользователя
class SignUpUser extends NavigationEvent {
  final Roles role;
  final String phone;
  final String name;
  final String lastName;
  final String city;
  final double priceCoef;
  final String password;

  SignUpUser(this.role, this.phone, this.name, this.lastName, this.city,
      this.priceCoef, this.password);
}

/// Событие для выхода из аккаунта
class LogOut extends NavigationEvent {}

/// Авторизация запомненного пользователя
class LogInRemembered extends NavigationEvent {
  final User user;

  LogInRemembered(this.user);
}

/// Событие для полного стирания пользователя из ОЗУ
class ForgetUser extends NavigationEvent {
  final User user;

  ForgetUser(this.user);
}
