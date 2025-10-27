import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/category_budget.dart';

// Categories: create/edit per-category monthly budget + alert %
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final nameCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  final alertCtrl = TextEditingController(text: '90');

  @override
  void dispose() {
    nameCtrl.dispose();
    budgetCtrl.dispose();
    alertCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories & Budgets')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // === Create/Update Budget Row ===
            Row(
              children: [
                Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Category Name'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: budgetCtrl, decoration: const InputDecoration(labelText: 'Monthly Budget'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: TextField(controller: alertCtrl, decoration: const InputDecoration(labelText: 'Alert %'), keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final budget = double.tryParse(budgetCtrl.text.trim()) ?? 0;
                    final pct = int.tryParse(alertCtrl.text.trim()) ?? 100;
                    if (name.isEmpty) return;
                    await context.read<FinanceProvider>().setBudget(
                        CategoryBudget(name: name, monthlyBudget: budget, alertPct: pct));
                    nameCtrl.clear(); budgetCtrl.clear();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // === List Budgets ===
            Expanded(
              child: ListView(
                children: finance.budgets.values.map((b) {
                  return ListTile(
                    title: Text(b.name),
                    subtitle: Text('Budget: \$${b.monthlyBudget.toStringAsFixed(2)} • Alert at ${b.alertPct}%'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
