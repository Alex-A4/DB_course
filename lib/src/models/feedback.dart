/// Модель отзыва клиента о записи
class Feedback {
  final int id;
  final int entryId;
  final DateTime feedbackDate;
  final String text;

  Feedback(this.id, this.entryId, date, this.text)
      : this.feedbackDate = DateTime.fromMillisecondsSinceEpoch(date);
}
