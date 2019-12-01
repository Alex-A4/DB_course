import 'package:db_course_mobile/src/models/feedback.dart';

/// Модель записи клиента к мастеру
class Entry {
  final int id;
  final int masterId;
  final int clientId;
  final int subcategoryId;
  final DateTime date;

  Feedback feedback;
  final String subcategoryName;
  final String clientOrMasterName;
  final String clientOrMasterPhone;

  Entry(
      this.id,
      this.masterId,
      this.clientId,
      this.subcategoryId,
      int date,
      this.feedback,
      this.subcategoryName,
      this.clientOrMasterName,
      this.clientOrMasterPhone)
      : this.date = DateTime.fromMillisecondsSinceEpoch(date);

  factory Entry.fromData(Map<String, dynamic> data) {
    return Entry(
      data['entry_id'],
      data['master_id'],
      data['client_id'],
      data['subcategory_id'],
      data['entry_date'],
      null,
      data['name'],
      data['first_name'],
      data['phone_number'],
    );
  }

  factory Entry.withFeedback(Map<String, dynamic> data) {
    return Entry(
      data['entry_id'],
      data['master_id'],
      data['client_id'],
      data['subcategory_id'],
      data['entry_date'],
      Feedback.fromData(data),
      data['name'],
      data['first_name'],
      data['phone_number'],
    );
  }

  @override
  String toString() => 'Entry: id=$id master=$masterId, client=$clientId, '
      '$clientOrMasterName&$clientOrMasterPhone,'
      'subcategory=$subcategoryId|$subcategoryName, $date, $feedback\n';
}
