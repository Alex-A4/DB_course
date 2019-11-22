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

  User(this.id, this.role, this.phone, this.name, this.lastName, this.city,
      this.priceCoef);

  factory User.fromData(Map<String, dynamic> data) {
    return User(
      data['user_id'],
      Roles.values[data['role']],
      data['phone_number'],
      data['first_name'],
      data['last_name'],
      data['city'],
      data['price_coef'],
    );
  }
}
