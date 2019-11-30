import 'package:db_course_mobile/src/ui/auth/auth_screen.dart';
import 'package:db_course_mobile/src/ui/category/category_screen.dart';
import 'package:db_course_mobile/src/ui/loading_screen.dart';
import 'package:db_course_mobile/src/ui/masters/masters_screen.dart';
import 'package:db_course_mobile/src/ui/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc/navigation_bloc/navigation.dart';

class App extends StatelessWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return StreamBuilder<NavigationState>(
      stream: bloc.state,
      builder: (_, snap) {
        final state = snap.data;

        if (state is EmptyState) return LoadingScreen();
        if (state is AuthState) return AuthScreen(error: state.error);
        if (state is ProfilePage) return ProfileScreen();
        if (state is MastersPage) return MastersScreen();
        if (state is CategoryPage) return CategoryScreen();

        return Container();
      },
    );
  }
}

/// Экраны:
/// 1) Авторизация/Вход. Должна предусматривать вход на несколько аккаунтов
/// 2) Просмотр мастеров
/// 3) Просмотр категорий/подкатегорий
/// 4) Запись к мастеру
/// 5) Просмотр записей/отзывов
/// 6) Для админа окно для добавления категорий/подкатегорий
/// 7) Для мастера окно редактирования компетенции
