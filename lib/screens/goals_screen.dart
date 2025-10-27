import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/goal.dart';

// Goals: create goals + deposit to goal
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final nameCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  final depositCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    targetCtrl.dispose();
    depositCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Goal name'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: targetCtrl, decoration: const InputDecoration(labelText: 'Target Amount'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final target = double.tryParse(targetCtrl.text.trim());
                    if (name.isEmpty || target == null || target <= 0) return;
                    await context.read<FinanceProvider>().addGoal(Goal(name: name, target: target));
                    nameCtrl.clear(); targetCtrl.clear();
                  },
                  child: const Text('Add Goal'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: finance.goals.length,
                itemBuilder: (context, i) {
                  final g = finance.goals[i];
                  final pct = (g.saved / (g.target == 0 ? 1 : g.target)).clamp(0.0, 1.0).toDouble();
                  return Card(
                    child: ListTile(
                      title: Text(g.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saved: \$${g.saved.toStringAsFixed(2)} / \$${g.target.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(value: pct),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 140,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: depositCtrl,
                                decoration: const InputDecoration(hintText: '\$'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final amt = double.tryParse(depositCtrl.text.trim());
                                if (amt == null || amt <= 0) return;
                                await context.read<FinanceProvider>().depositToGoal(g, amt);
                                depositCtrl.clear();
                              },
                              icon: const Icon(Icons.add),
                              tooltip: 'Add to goal',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
