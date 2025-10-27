// main.dart
// Student: Root of Personal Finance Manager App
// ----------------------------------------------
// • Provides main app entry point
// • Injects FinanceProvider (state management)
// • Defines routes for all active screens
// • Settings/Export route removed (now done via Reports screen)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// === Local imports ===
import 'providers/finance_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/category_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/reports_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FinanceProvider()..init(), // initialize DB + state
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // === Routes ===
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
