// goals_screen.dart
// Student: Manage Savings Goals
// ------------------------------
// • Add new savings goals
// • Deposit to existing goals
// • Delete goals
// • Display progress bars for each goal
// • Syncs with SQLite via FinanceProvider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/goal.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final nameCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  final depositCtrls = <int, TextEditingController>{};

  @override
  void dispose() {
    nameCtrl.dispose();
    targetCtrl.dispose();
    for (final ctrl in depositCtrls.values) {
      ctrl.dispose();
    }
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
            // === Add a New Goal ===
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Goal name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: targetCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Target amount'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final target = double.tryParse(targetCtrl.text.trim());
                    if (name.isEmpty || target == null || target <= 0) return;

                    await context
                        .read<FinanceProvider>()
                        .addGoal(Goal(name: name, target: target));

                    nameCtrl.clear();
                    targetCtrl.clear();
                  },
                  child: const Text('Add Goal'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // === Display All Goals ===
            Expanded(
              child: ListView.builder(
                itemCount: finance.goals.length,
                itemBuilder: (context, i) {
                  final g = finance.goals[i];
                  depositCtrls[g.id ?? i] ??= TextEditingController();
                  final depositCtrl = depositCtrls[g.id ?? i]!;

                  final pct = (g.saved / (g.target == 0 ? 1 : g.target))
                      .clamp(0.0, 1.0)
                      .toDouble();

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Goal Title & Delete Button ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                g.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                tooltip: 'Delete goal',
                                onPressed: () async {
                                  await context
                                      .read<FinanceProvider>()
                                      .deleteGoal(g);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Text(
                            'Saved: \$${g.saved.toStringAsFixed(2)} / \$${g.target.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(value: pct),
                          const SizedBox(height: 10),

                          // --- Deposit Section ---
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: depositCtrl,
                                  decoration: const InputDecoration(
                                      hintText: 'Deposit amount'),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final amt = double.tryParse(
                                      depositCtrl.text.trim());
                                  if (amt == null || amt <= 0) return;
                                  await context
                                      .read<FinanceProvider>()
                                      .depositToGoal(g, amt);
                                  depositCtrl.clear();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
