import 'dart:convert';

/// Базовый конроллер
abstract class Controller {
  final codec = JsonCodec();
}
