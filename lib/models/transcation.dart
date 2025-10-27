// Simple transaction model
class PFTransaction {
  final int? id;
  final String type; // 'income' or 'expense'
  final double amount;
  final String category;
  final String date; // ISO yyyy-MM-dd
  final String? notes;

  PFTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'amount': amount,
        'category': category,
        'date': date,
        'notes': notes,
      };

  factory PFTransaction.fromMap(Map<String, dynamic> m) => PFTransaction(
        id: m['id'] as int?,
        type: m['type'] as String,
        amount: (m['amount'] as num).toDouble(),
        category: m['category'] as String,
        date: m['date'] as String,
        notes: m['notes'] as String?,
      );
}
