import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Student: placeholder screen - budgets + analytics added later
    return Scaffold(
      appBar: AppBar(title: const Text('Categories & Budgets')),
      body: const Center(child: Text('Category budgets coming soon...')),
    );
  }
}

