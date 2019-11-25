/// Модель записи клиента к мастеру
class Entry {
  final int id;
  final int masterId;
  final int clientId;
  final int subcategoryId;
  final DateTime date;

  Entry(this.id, this.masterId, this.clientId, this.subcategoryId, int date)
      : this.date = DateTime.fromMillisecondsSinceEpoch(date);

  factory Entry.fromData(Map<String, dynamic> data) {
    return Entry(
      data['entry_id'],
      data['master_id'],
      data['client_id'],
      data['subcategory_id'],
      data['entry_date'],
    );
  }

  @override
  String toString() => '$id $masterId $clientId $subcategoryId $date';
}
