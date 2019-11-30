import 'package:db_course_mobile/src/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller_base.dart';

/// Контроллер пользователей, который сохраняет или читает
/// пользователей из хранилища
class UserController with Controller {
  static const USERS_KEY = 'USERS_LIST';

  Future<List<User>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(USERS_KEY);

    if (data != null) {
      return codec
          .decode(data)
          .map((u) => User.fromData(u))
          .cast<User>()
          .toList();
    }

    return [];
  }

  Future<void> save(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final data = users.map((u) => u.toData()).toList();
    await prefs.setString(USERS_KEY, codec.encode(data));
  }
}
