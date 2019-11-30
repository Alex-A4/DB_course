abstract class NavigationState {}

class EmptyState extends NavigationState {}

class AuthState extends NavigationState {
  final String error;

  AuthState({this.error});
}

/// Состояние открытого профиля
class ProfilePage extends NavigationState {}

/// Состояние открытого окна мастеров
class MastersPage extends NavigationState {}

/// Состояние открытого окна категорий
class CategoryPage extends NavigationState {}
