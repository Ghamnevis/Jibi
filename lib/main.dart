import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const App());
}

class Expense {
  String title;
  double amount;
  String type;
  String category;
  String date;
  String weekday;

  Expense({
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.weekday,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "amount": amount,
        "type": type,
        "category": category,
        "date": date,
        "weekday": weekday,
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      title: json["title"],
      amount: json["amount"],
      type: json["type"],
      category: json["category"],
      date: json["date"],
      weekday: json["weekday"],
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Expense> expenses = [];

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  String selectedType = "personal";

  final categories = {
    "personal": ["خوراک", "حمل‌ونقل", "خانه", "تفریح"],
    "business": ["تولید", "اداری", "تعمیرات", "مواد اولیه"]
  };

  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    load();
  }

  String getDate() {
    final now = DateTime.now();
    const weekdays = [
      "یکشنبه",
      "دوشنبه",
      "سه‌شنبه",
      "چهارشنبه",
      "پنجشنبه",
      "جمعه",
      "شنبه"
    ];
    return "${now.year}/${now.month}/${now.day} - ${weekdays[now.weekday % 7]}";
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      "data",
      jsonEncode(expenses.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("data");

    if (data != null) {
      final decoded = jsonDecode(data);
      setState(() {
        expenses =
            decoded.map<Expense>((e) => Expense.fromJson(e)).toList();
      });
    }
  }

  void addExpense() {
    if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;

    final exp = Expense(
      title: titleCtrl.text,
      amount: double.parse(amountCtrl.text),
      type: selectedType,
      category: selectedCategory ?? "سایر",
      date: getDate(),
      weekday: "",
    );

    setState(() {
      expenses.insert(0, exp);
    });

    save();

    titleCtrl.clear();
    amountCtrl.clear();
  }

  double get total =>
      expenses.fold(0, (sum, e) => sum + e.amount);

  void openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "ثبت هزینه جدید",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "شرح هزینه"),
              ),

              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "مبلغ"),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  ChoiceChip(
                    label: const Text("شخصی"),
                    selected: selectedType == "personal",
                    onSelected: (_) {
                      setState(() => selectedType = "personal");
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("کاری"),
                    selected: selectedType == "business",
                    onSelected: (_) {
                      setState(() => selectedType = "business");
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                children: categories[selectedType]!
                    .map(
                      (c) => ChoiceChip(
                        label: Text(c),
                        selected: selectedCategory == c,
                        onSelected: (_) {
                          setState(() => selectedCategory = c);
                        },
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  addExpense();
                  Navigator.pop(context);
                },
                child: const Text("ثبت"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openAddSheet,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER DASHBOARD
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.blue],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "دستیار هزینه‌ها",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "مجموع هزینه: $total تومان",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // LIST
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (c, i) {
                  final e = expenses[i];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(e.title),
                      subtitle: Text("${e.category} | ${e.date}"),
                      trailing: Text(
                        "${e.amount} تومان",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
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