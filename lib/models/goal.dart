class Goal {
  final int? id;
  final String name;
  final double target;
  final double saved;
  final String? dueDate;

  Goal({
    this.id,
    required this.name,
    required this.target,
    this.saved = 0,
    this.dueDate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'target': target,
        'saved': saved,
        'due_date': dueDate,
      };

  factory Goal.fromMap(Map<String, dynamic> m) => Goal(
        id: m['id'] as int?,
        name: m['name'] as String,
        target: (m['target'] as num).toDouble(),
        saved: (m['saved'] as num).toDouble(),
        dueDate: m['due_date'] as String?,
      );
}
