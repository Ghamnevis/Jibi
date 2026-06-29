import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Factory Expense PRO',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Expense {
  final String title;
  final double amount;
  final String category;

  Expense(this.title, this.amount, this.category);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> expenses = [];

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String category = "Food";

  void addExpense() {
    setState(() {
      expenses.add(
        Expense(
          titleCtrl.text,
          double.tryParse(amountCtrl.text) ?? 0,
          category,
        ),
      );
    });

    titleCtrl.clear();
    amountCtrl.clear();
  }

  double get total =>
      expenses.fold(0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Factory Expense PRO"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            DropdownButton<String>(
              value: category,
              items: ["Food", "Transport", "Repair", "Energy"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  category = v!;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addExpense,
              child: const Text("Add Expense"),
            ),
            const SizedBox(height: 20),
            Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final e = expenses[index];
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text(e.category),
                    trailing: Text("\$${e.amount}"),
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