// reports_screen.dart
// Student: Reports screen showing summary visuals and export.
// ------------------------------------------------------------
// • Displays Income vs Expenses in bar chart
// • Shows "Net Income" line (Income - Expenses)
// • Toggle between viewing expense/income transactions
// • Export to CSV available directly from this page

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

enum TxFilter { none, expenses, incomes }

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime start = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime end = DateTime.now();
  TxFilter filter = TxFilter.none;

  final DateFormat _iso = DateFormat('yyyy-MM-dd');

  // --- Helper: Check if date within selected range ---
  bool _inRange(String isoDate) {
    final d = _iso.parse(isoDate);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  // --- Helper: Compute totals ---
  (double income, double expenses) _totalsInRange(List<PFTransaction> all) {
    double inc = 0, exp = 0;
    for (final t in all) {
      if (_inRange(t.date)) {
        if (t.type == 'income') inc += t.amount;
        if (t.type == 'expense') exp += t.amount;
      }
    }
    return (inc, exp);
  }

  // --- Filter for viewing list ---
  List<PFTransaction> _filteredTx(List<PFTransaction> all, TxFilter f) {
    if (f == TxFilter.none) return const [];
    final type = (f == TxFilter.incomes) ? 'income' : 'expense';
    final items = all.where((t) => t.type == type && _inRange(t.date)).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final (incomeInRange, expensesInRange) = _totalsInRange(finance.transactions);
    final netIncome = incomeInRange - expensesInRange;
    final maxVal = math.max(1.0, math.max(incomeInRange, expensesInRange));
    final list = _filteredTx(finance.transactions, filter);
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // === Date Range Picker ===
          Row(children: [
            Text('From: ${_iso.format(start)}'),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: start,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => start = picked);
              },
              child: const Text('Pick'),
            ),
            const SizedBox(width: 12),
            Text('To: ${_iso.format(end)}'),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: end,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => end = picked);
              },
              child: const Text('Pick'),
            ),
          ]),
          const SizedBox(height: 12),

          // === Bar Chart Section ===
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Income vs Expenses',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Range: ${_iso.format(start)} → ${_iso.format(end)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),

                    // Bars
                    SizedBox(
                      height: 160,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _barColumn(
                              label: 'Income',
                              value: incomeInRange,
                              maxVal: maxVal,
                              color: Colors.teal,
                              currency: currency),
                          const SizedBox(width: 18),
                          _barColumn(
                              label: 'Expenses',
                              value: expensesInRange,
                              maxVal: maxVal,
                              color: Colors.orange,
                              currency: currency),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Totals — Income: ${currency.format(incomeInRange)} • Expenses: ${currency.format(expensesInRange)}',
                      style: const TextStyle(fontSize: 13),
                    ),

                    // === Net Income line ===
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(
                        'Net Income: ${currency.format(netIncome)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: netIncome >= 0 ? Colors.teal : Colors.redAccent,
                        ),
                      ),
                    ]),
                  ]),
            ),
          ),
          const SizedBox(height: 10),

          // === Toggle + Export Row ===
          Row(children: [
            _toggleButton(
              label: 'Expenses',
              selected: filter == TxFilter.expenses,
              onTap: () => setState(() =>
                  filter = (filter == TxFilter.expenses)
                      ? TxFilter.none
                      : TxFilter.expenses),
            ),
            const SizedBox(width: 8),
            _toggleButton(
              label: 'Incomes',
              selected: filter == TxFilter.incomes,
              onTap: () => setState(() =>
                  filter = (filter == TxFilter.incomes)
                      ? TxFilter.none
                      : TxFilter.incomes),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                final csv = await context.read<FinanceProvider>().exportCsv(
                    startIso: _iso.format(start), endIso: _iso.format(end));
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('CSV Preview'),
                    content: SingleChildScrollView(
                        child: Text(csv.split('\n').take(15).join('\n'))),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close')),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Export CSV'),
            ),
          ]),
          const SizedBox(height: 8),

          // === Filtered Transaction List ===
          if (filter != TxFilter.none)
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final t = list[i];
                  return ListTile(
                    leading: Icon(
                        t.type == 'income'
                            ? Icons.call_received
                            : Icons.call_made,
                        color: t.type == 'income'
                            ? Colors.teal
                            : Colors.redAccent),
                    title: Text('${t.category} — ${currency.format(t.amount)}'),
                    subtitle: Text(
                        '${t.date}${t.notes?.isNotEmpty == true ? " • ${t.notes}" : ""}'),
                  );
                },
              ),
            )
          else
            const Expanded(child: SizedBox()),
        ]),
      ),
    );
  }

  // --- Helper for drawing bars ---
  Widget _barColumn({
    required String label,
    required double value,
    required double maxVal,
    required Color color,
    required NumberFormat currency,
  }) {
    final pct = (value / maxVal).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(currency.format(value),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                width: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: pct,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 34,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  // --- Toggle Buttons for "Expenses" / "Incomes" ---
  Widget _toggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return selected
        ? ElevatedButton(onPressed: onTap, child: Text(label))
        : OutlinedButton(onPressed: onTap, child: Text(label));
  }
}