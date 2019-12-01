import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Кастомная версия нижнего бара навигации
class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({Key key}) : super(key: key);

  final eventIndexes = [MastersEvent(), CategoryEvent(), ProfileEvent()];

  final items = [
    BottomNavigationBarItem(icon: Icon(Icons.group), title: Text('Мастера')),
    BottomNavigationBarItem(
        icon: Icon(Icons.category), title: Text('Категории')),
    BottomNavigationBarItem(
        icon: Icon(Icons.account_circle), title: Text('Профиль')),
  ];

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);
    return StreamBuilder<NavigationState>(
      stream: bloc.state,
      builder: (_, snap) {
        final state = snap.data;

        /// Страница мастеров на 0 индексе
        int cur = 0;
        if (state is CategoryPage) cur = 1;
        if (state is ProfilePage) cur = 2;

        return BottomNavigationBar(
          currentIndex: cur,
          items: items,
          onTap: (index) => bloc.dispatch(eventIndexes[index]),
        );
      },
    );
  }
}
