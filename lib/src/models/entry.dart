/// Модель записи клиента к мастеру
class Entry {
  final int id;
  final int masterId;
  final int clientId;
  final int subcategoryId;
  final DateTime date;

  Entry(this.id, this.masterId, this.clientId, this.subcategoryId, int date)
      : this.date = DateTime.fromMillisecondsSinceEpoch(date);
}
