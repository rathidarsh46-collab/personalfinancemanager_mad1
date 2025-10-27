import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

// Home: balance + quick nav; NO sample chart (requirement)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final balance = finance.totalIncome - finance.totalExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Finance Manager')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Summary Card ===
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _stat('Balance', balance),
                    _stat('Income', finance.totalIncome),
                    _stat('Expenses', finance.totalExpenses),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // === Quick Actions ===
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Pop the Add button visually
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Transaction'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/categories'),
                  icon: const Icon(Icons.category),
                  label: const Text('Categories'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/goals'),
                  icon: const Icon(Icons.flag),
                  label: const Text('Goals'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/reports'),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Reports'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text('Recent Transactions'),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: finance.transactions.length,
                itemBuilder: (context, i) {
                  final t = finance.transactions[i];
                  return ListTile(
                    leading: Icon(
                      t.type == 'income' ? Icons.call_received : Icons.call_made,
                      color: t.type == 'income' ? Colors.teal : Colors.redAccent,
                    ),
                    title: Text('${t.type.toUpperCase()}  \$${t.amount.toStringAsFixed(2)}'),
                    subtitle: Text('${t.category} • ${t.date}${t.notes?.isNotEmpty == true ? " • ${t.notes}" : ""}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('\$${value.toStringAsFixed(2)}'),
      ],
    );
  }
}
