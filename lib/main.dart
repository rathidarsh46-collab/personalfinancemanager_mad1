// main.dart
// Student note: Root of app + routes; Provider injected at the top.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/finance_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/category_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/reports_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FinanceProvider()..init(), // load DB + seed
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/add': (_) => const AddTransactionScreen(),
        '/categories': (_) => const CategoryScreen(),
        '/goals': (_) => const GoalsScreen(),
        '/reports': (_) => const ReportsScreen(),
      },
    );
  }
}
