class CategoryBudget {
  final String name; // primary key
  final double monthlyBudget;
  final int alertPct;

  CategoryBudget({
    required this.name,
    required this.monthlyBudget,
    required this.alertPct,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'monthly_budget': monthlyBudget,
        'alert_pct': alertPct,
      };

  factory CategoryBudget.fromMap(Map<String, dynamic> m) => CategoryBudget(
        name: m['name'] as String,
        monthlyBudget: (m['monthly_budget'] as num?)?.toDouble() ?? 0,
        alertPct: (m['alert_pct'] as num?)?.toInt() ?? 100,
      );
}
