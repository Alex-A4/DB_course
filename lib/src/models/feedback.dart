/// Модель отзыва клиента о записи к мастеру
class Feedback {
  final int id;
  final int entryId;
  final String subcategoryName;
  final DateTime feedbackTime;
  final String text;

  Feedback(this.id, this.entryId, date, this.text, this.subcategoryName)
      : this.feedbackTime = DateTime.fromMillisecondsSinceEpoch(date);

  factory Feedback.fromData(Map<String, dynamic> data) {
    if (data['feedback_id'] == null) return null;
    return Feedback(
      data['feedback_id'],
      data['entry_id'],
      data['feedback_time'],
      data['feedback_text'],
      null,
    );
  }

  factory Feedback.withSubcategory(Map<String, dynamic> data) {
    if (data['feedback_id'] == null) return null;

    return Feedback(
      data['feedback_id'],
      data['entry_id'],
      data['feedback_time'],
      data['feedback_text'],
      data['subcategory_id'],
    );
  }

  @override
  String toString() =>
      'Feedback: id=$id, entry=$entryId, subcat=$subcategoryName, '
      '$feedbackTime text=$text';
}
