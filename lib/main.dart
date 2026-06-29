import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ExpenseApp());
}

class Expense {
  final String text;
  final double amount;
  final String category;

  Expense(this.text, this.amount, this.category);

  Map<String, dynamic> toJson() => {
        "text": text,
        "amount": amount,
        "category": category,
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      json["text"],
      json["amount"],
      json["category"],
    );
  }
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Assistant',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  String detectCategory(String text) {
    final t = text.toLowerCase();

    if (t.contains("food") || t.contains("غذا") || t.contains("ناهار")) {
      return "Food 🍽";
    }

    if (t.contains("fuel") || t.contains("بنزین")) {
      return "Transport 🚚";
    }

    if (t.contains("repair") || t.contains("تعمیر")) {
      return "Maintenance 🔧";
    }

    return "Other 📦";
  }

  double extractAmount(String text) {
    final regex = RegExp(r'(\d+(\.\d+)?)');
    final match = regex.firstMatch(text);
    return match != null ? double.parse(match.group(0)!) : 0;
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString("expenses", data);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("expenses");

    if (data != null) {
      final decoded = jsonDecode(data) as List;
      setState(() {
        expenses = decoded.map((e) => Expense.fromJson(e)).toList();
      });
    }
  }

  void addExpense(String text) {
    final amount = extractAmount(text);
    if (amount == 0) return;

    setState(() {
      expenses.add(
        Expense(text, amount, detectCategory(text)),
      );
    });

    saveData();
    controller.clear();
  }

  double get total =>
      expenses.fold(0, (sum, e) => sum + e.amount);

  String topCategory() {
    if (expenses.isEmpty) return "-";

    final map = <String, double>{};

    for (var e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }

    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Assistant PRO Lite"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "مثال: ناهار 120",
              ),
              onSubmitted: addExpense,
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => addExpense(controller.text),
              child: const Text("ثبت هزینه"),
            ),

            const SizedBox(height: 20),

            Text("💰 Total: $total"),
            Text("🏆 Top Category: $topCategory"),

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, i) {
                  final e = expenses[i];
                  return ListTile(
                    title: Text(e.text),
                    subtitle: Text(e.category),
                    trailing: Text("${e.amount}"),
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