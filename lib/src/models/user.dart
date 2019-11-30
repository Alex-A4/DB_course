import 'package:db_course_mobile/src/database/tables/user_table.dart';

/// Модель пользователя
class User {
  final int id;
  final Roles role;
  final String phone;
  final String name;
  final String lastName;
  final String city;
  final double priceCoef;
  final String token;

  User(this.id, this.role, this.phone, this.name, this.lastName, this.city,
      this.priceCoef, this.token);

  /// Создание из Json формата
  factory User.fromData(Map<String, dynamic> data) {
    return User(
      data['user_id'],
      Roles.values[data['role']],
      data['phone_number'],
      data['first_name'],
      data['last_name'],
      data['city'],
      data['price_coef'] == 'null' ? null : data['price_coef'],
      data['token'],
    );
  }

  /// Конвертация в Json формат
  Map<String, dynamic> toData() => {
        'user_id': id,
        'role': role.index,
        'phone_number': phone,
        'first_name': name,
        'last_name': lastName,
        'city': city,
        'price_coef': priceCoef,
        'token': token,
      };

  bool get isAdmin => role == Roles.Admin;

  bool get isMaster => role == Roles.Master;

  bool get isClient => role == Roles.Client;

  @override
  String toString() =>
      'User: id=$id phone=$phone city=$city name=$name last=$lastName '
      'token=$token price=$priceCoef $role';

  @override
  bool operator ==(other) {
    if (other is User && other.id == id) return true;
    return false;
  }

  @override
  int get hashCode => id;
}
