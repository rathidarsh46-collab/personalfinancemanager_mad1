// category_screen.dart
// Student: Category budgets + monthly analytics
// ---------------------------------------------
// • Add/Edit budgets
// • Month selector defaults to current month
// • Dropdown to select category
// • Lists all transactions for chosen category + month
// • Shows a single "Total:" for that category/month

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/category_budget.dart';
import '../models/transaction.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final nameCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  final alertCtrl = TextEditingController(text: '90');

  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String? selectedCategory;

  String _monthLabel(DateTime d) => DateFormat('MMMM yyyy').format(d);
  String _monthKey(DateTime d) => DateFormat('yyyy-MM').format(d);

  List<PFTransaction> _transactionsFor(
      List<PFTransaction> all, String category, DateTime month) {
    final ym = _monthKey(month);
    return all
        .where((t) => t.category == category && t.date.startsWith(ym))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final allCategories = finance.budgets.keys.toList();

    // Default selection
    if (selectedCategory == null && allCategories.isNotEmpty) {
      selectedCategory = allCategories.first;
    }

    final txs = (selectedCategory != null)
        ? _transactionsFor(finance.transactions, selectedCategory!, selectedMonth)
        : <PFTransaction>[];

    final totalForCategory =
        txs.fold<double>(0.0, (sum, t) => sum + t.amount); // single total
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories & Budgets')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          // === Budget Creation Row ===
          Row(children: [
            Expanded(
                child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Category Name'))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: budgetCtrl,
                    decoration: const InputDecoration(labelText: 'Monthly Budget'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true))),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: TextField(
                controller: alertCtrl,
                decoration: const InputDecoration(labelText: 'Alert %'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final budget = double.tryParse(budgetCtrl.text.trim()) ?? 0;
                  final pct = int.tryParse(alertCtrl.text.trim()) ?? 100;
                  if (name.isEmpty) return;
                  await context.read<FinanceProvider>().setBudget(CategoryBudget(
                        name: name,
                        monthlyBudget: budget,
                        alertPct: pct,
                      ));
                  nameCtrl.clear();
                  budgetCtrl.clear();
                },
                child: const Text('Save')),
          ]),
          const SizedBox(height: 12),

          // === Budgets List ===
          Expanded(
            child: ListView(
              children: finance.budgets.values.map((b) {
                return ListTile(
                  title: Text(b.name),
                  subtitle: Text(
                      'Budget: \$${b.monthlyBudget.toStringAsFixed(2)} • Alert at ${b.alertPct}%'),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 24, thickness: 1.2),

          // === Month selector + Category dropdown ===
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              IconButton(
                onPressed: () => setState(() {
                  selectedMonth =
                      DateTime(selectedMonth.year, selectedMonth.month - 1);
                }),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(_monthLabel(selectedMonth),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                onPressed: () => setState(() {
                  selectedMonth =
                      DateTime(selectedMonth.year, selectedMonth.month + 1);
                }),
                icon: const Icon(Icons.chevron_right),
              ),
            ]),
            DropdownButton<String>(
              value: selectedCategory,
              hint: const Text('Select Category'),
              items: allCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
            ),
          ]),
          const SizedBox(height: 8),

          // === Transactions Summary + List ===
          if (selectedCategory != null)
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(children: [
                      Text('${selectedCategory!} — ${_monthLabel(selectedMonth)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      Text('Total: ${currency.format(totalForCategory)}'),
                      const SizedBox(height: 10),
                      const Text('Transactions:'),
                      const SizedBox(height: 6),
                      SizedBox(
                          height: 160,
                          child: txs.isEmpty
                              ? const Center(
                                  child: Text(
                                      'No transactions for this category in selected month.'))
                              : ListView.builder(
                                  itemCount: txs.length,
                                  itemBuilder: (context, i) {
                                    final t = txs[i];
                                    return ListTile(
                                      dense: true,
                                      leading: Icon(
                                          t.type == 'income'
                                              ? Icons.call_received
                                              : Icons.call_made,
                                          color: t.type == 'income'
                                              ? Colors.teal
                                              : Colors.redAccent),
                                      title: Text(
                                          '${currency.format(t.amount)} — ${t.category}'),
                                      subtitle: Text(
                                          '${t.date}${t.notes?.isNotEmpty == true ? " • ${t.notes}" : ""}'),
                                    );
                                  },
                                ))
                    ]))),
        ]),
      ),
    );
  }
}
