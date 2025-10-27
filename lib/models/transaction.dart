// transaction.dart
// Student: Defines the Transaction model
// --------------------------------------
// • Represents income or expense entries
// • Used by FinanceProvider + all UI screens
// • Provides map conversion helpers for SQLite

class PFTransaction {
  final int? id;
  final String type;      // 'income' or 'expense'
  final String category;  // e.g. Food, Rent, Salary, etc.
  final double amount;
  final String date;      // stored in ISO yyyy-MM-dd format
  final String? notes;    // optional memo field

  PFTransaction({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
  });

  // --- Convert this object to a map for SQLite ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'notes': notes,
    };
  }

  // --- Construct from map (reading from DB) ---
  factory PFTransaction.fromMap(Map<String, dynamic> map) {
    return PFTransaction(
      id: map['id'] as int?,
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'] ?? '',
      notes: map['notes'],
    );
  }
}
