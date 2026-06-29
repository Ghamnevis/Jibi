import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const App());
}

class Expense {
  String title;
  double amount;
  String type; // personal / business
  String category;
  String subCategory;
  String date;
  String weekday;

  Expense({
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.subCategory,
    required this.date,
    required this.weekday,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "amount": amount,
        "type": type,
        "category": category,
        "subCategory": subCategory,
        "date": date,
        "weekday": weekday,
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      title: json["title"],
      amount: json["amount"],
      type: json["type"],
      category: json["category"],
      subCategory: json["subCategory"],
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
        colorSchemeSeed: Colors.blue,
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
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  List<Expense> list = [];

  String selectedType = "personal";

  List<String> personalCats = ["خانه", "خوراک", "حمل‌ونقل"];
  List<String> businessCats = ["تولید", "اداری", "تعمیرات"];

  String? selectedCategory;
  String? selectedSub;

  @override
  void initState() {
    super.initState();
    load();
  }

  String getJalaliDate() {
    final now = DateTime.now();
    final f = DateFormat("yyyy/MM/dd");
    return f.format(now);
  }

  String getWeekday() {
    final now = DateTime.now();
    return [
      "یکشنبه",
      "دوشنبه",
      "سه‌شنبه",
      "چهارشنبه",
      "پنجشنبه",
      "جمعه",
      "شنبه"
    ][now.weekday % 7];
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString("data", data);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("data");

    if (data != null) {
      final decoded = jsonDecode(data);
      setState(() {
        list = decoded.map<Expense>((e) => Expense.fromJson(e)).toList();
      });
    }
  }

  void add() {
    if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;

    final exp = Expense(
      title: titleCtrl.text,
      amount: double.parse(amountCtrl.text),
      type: selectedType,
      category: selectedCategory ?? "سایر",
      subCategory: selectedSub ?? "عمومی",
      date: getJalaliDate(),
      weekday: getWeekday(),
    );

    setState(() {
      list.add(exp);
    });

    save();

    titleCtrl.clear();
    amountCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cats =
        selectedType == "personal" ? personalCats : businessCats;

    return Scaffold(
      appBar: AppBar(
        title: const Text("دستیار هزینه‌ها"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // TYPE SELECT
            Row(
              children: [
                ChoiceChip(
                  label: const Text("شخصی"),
                  selected: selectedType == "personal",
                  onSelected: (_) {
                    setState(() {
                      selectedType = "personal";
                      selectedCategory = null;
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("کاری"),
                  selected: selectedType == "business",
                  onSelected: (_) {
                    setState(() {
                      selectedType = "business";
                      selectedCategory = null;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // CATEGORY
            DropdownButton<String>(
              hint: const Text("انتخاب دسته"),
              value: selectedCategory,
              items: cats
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                setState(() => selectedCategory = v);
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: titleCtrl,
              decoration:
                  const InputDecoration(labelText: "شرح هزینه"),
            ),

            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "مبلغ"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: add,
              child: const Text("ثبت"),
            ),

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (c, i) {
                  final e = list[i];
                  return ListTile(
                    title: Text("${e.title} - ${e.amount}"),
                    subtitle: Text(
                        "${e.type} | ${e.category} | ${e.date} (${e.weekday})"),
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