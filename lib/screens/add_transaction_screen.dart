import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';

// Add Transaction form: expense/income + amount + category + date + notes
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String type = 'expense';
  final amountCtrl = TextEditingController();
  final categoryCtrl = TextEditingController(text: 'Food');
  final notesCtrl = TextEditingController();
  DateTime selected = DateTime.now();

  @override
  void dispose() {
    amountCtrl.dispose();
    categoryCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // === Type toggle ===
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Expense'),
                    value: 'expense',
                    groupValue: type,
                    onChanged: (v) => setState(() => type = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Income'),
                    value: 'income',
                    groupValue: type,
                    onChanged: (v) => setState(() => type = v!),
                  ),
                ),
              ],
            ),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount (e.g., 12.50)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category (e.g., Food)'),
            ),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Date: ${fmt.format(selected)}'),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selected,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => selected = picked);
                  },
                  child: const Text('Pick'),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final amt = double.tryParse(amountCtrl.text.trim());
                    if (amt == null || amt <= 0 || categoryCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount and category')),
                      );
                      return;
                    }
                    final t = PFTransaction(
                      type: type,
                      amount: amt,
                      category: categoryCtrl.text.trim(),
                      date: DateFormat('yyyy-MM-dd').format(selected),
                      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                    );
                    await context.read<FinanceProvider>().addTransaction(t);

                    // Budget alert on expense
                    final ym = DateFormat('yyyy-MM').format(selected);
                    final alert = await context.read<FinanceProvider>()
                                               .shouldAlertFor(t.category, ym);
                    if (alert && type == 'expense') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Heads up: You're at your budget threshold for ${t.category}.")),
                      );
                    }

                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Transaction'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
