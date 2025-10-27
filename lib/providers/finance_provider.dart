import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/db.dart';
import '../models/transaction.dart';
import '../models/category_budget.dart';
import '../models/goal.dart';

class FinanceProvider extends ChangeNotifier {
  final DBService _dbs = DBService();

  List<PFTransaction> transactions = [];
  Map<String, CategoryBudget> budgets = {};
  List<Goal> goals = [];

  double totalIncome = 0;
  double totalExpenses = 0;
  bool initialized = false;

  Future<void> init() async {
    await _loadAll();
    // Seed starter categories for demo
    if (budgets.isEmpty) {
      await setBudget(CategoryBudget(name: 'Food', monthlyBudget: 300, alertPct: 90));
      await setBudget(CategoryBudget(name: 'Rent', monthlyBudget: 900, alertPct: 100));
      await setBudget(CategoryBudget(name: 'Transport', monthlyBudget: 200, alertPct: 80));
      await _loadBudgets();
    }
    initialized = true;
    notifyListeners();
  }

  Future<void> _loadAll() async {
    await _loadTransactions();
    await _loadBudgets();
    await _loadGoals();
    _recomputeTotals();
  }

  Future<void> _loadTransactions() async {
    final db = await _dbs.db;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    transactions = rows.map((e) => PFTransaction.fromMap(e)).toList();
  }

  Future<void> _loadBudgets() async {
    final db = await _dbs.db;
    final rows = await db.query('categories');
    budgets = {for (final r in rows) (r['name'] as String): CategoryBudget.fromMap(r)};
  }

  Future<void> _loadGoals() async {
    final db = await _dbs.db;
    final rows = await db.query('goals', orderBy: 'id DESC');
    goals = rows.map((e) => Goal.fromMap(e)).toList();
  }

  void _recomputeTotals() {
    totalIncome = transactions.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
    totalExpenses = transactions.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);
  }

  Future<void> addTransaction(PFTransaction t) async {
    final db = await _dbs.db;
    await db.insert('transactions', t.toMap());
    await _loadTransactions();
    _recomputeTotals();
    notifyListeners();
  }

  Future<void> setBudget(CategoryBudget b) async {
    final db = await _dbs.db;
    await db.insert('categories', b.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    budgets[b.name] = b;
    notifyListeners();
  }

  Future<void> addGoal(Goal g) async {
    final db = await _dbs.db;
    await db.insert('goals', g.toMap());
    await _loadGoals();
    notifyListeners();
  }

  Future<void> depositToGoal(Goal g, double amount) async {
    final db = await _dbs.db;
    await db.update('goals', {'saved': g.saved + amount}, where: 'id=?', whereArgs: [g.id]);
    await _loadGoals();
    notifyListeners();
  }

  Future<void> deleteGoal(Goal g) async {
    final db = await _dbs.db;
    await db.delete('goals', where: 'id = ?', whereArgs: [g.id]);
    await _loadGoals();
    notifyListeners();
  }

  Future<bool> shouldAlertFor(String category, String ym) async {
    final db = await _dbs.db;
    final rows = await db.rawQuery('''
      SELECT SUM(amount) AS spent FROM transactions
      WHERE type='expense' AND category=? AND substr(date,1,7)=?
    ''', [category, ym]);
    final spent = (rows.first['spent'] as num?)?.toDouble() ?? 0.0;
    final b = budgets[category];
    if (b == null || b.monthlyBudget <= 0) return false;
    final threshold = b.monthlyBudget * (b.alertPct / 100.0);
    return spent >= threshold;
  }

  Future<String> exportCsv({required String startIso, required String endIso}) async {
    final db = await _dbs.db;
    final rows = await db.rawQuery('''
      SELECT id, type, amount, category, date, notes
      FROM transactions
      WHERE date BETWEEN ? AND ?
      ORDER BY date ASC, id ASC
    ''', [startIso, endIso]);

    const header = 'id,type,amount,category,date,notes';
    final lines = <String>[header];
    for (final r in rows) {
      final notes = (r['notes'] ?? '').toString().replaceAll(',', ';');
      lines.add('${r['id']},${r['type']},${r['amount']},${r['category']},${r['date']},$notes');
    }
    return lines.join('\n');
  }
}
