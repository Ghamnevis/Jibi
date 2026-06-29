import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const SmartAssistant());
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

class SmartAssistant extends StatefulWidget {
  const SmartAssistant({super.key});

  @override
  State<SmartAssistant> createState() => _SmartAssistantState();
}

class _SmartAssistantState extends State<SmartAssistant> {
  final controller = TextEditingController();

  List<Expense> expenses = [];

  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    loadData();
  }

  // 🧠 دسته‌بندی هوشمند
  String categorize(String text) {
    final t = text.toLowerCase();

    if (t.contains("food") ||
        t.contains("ناهار") ||
        t.contains("غذا")) {
      return "Food 🍽";
    }

    if (t.contains("fuel") ||
        t.contains("بنزین") ||
        t.contains("diesel") ||
        t.contains("gas")) {
      return "Transport 🚚";
    }

    if (t.contains("repair") ||
        t.contains("تعمیر") ||
        t.contains("machine")) {
      return "Maintenance 🔧";
    }

    return "Other 📦";
  }

  // 🎯 استخراج عدد از جمله (B MODE improved)
  double extractAmount(String text) {
    final regex = RegExp(r'(\d+(\.\d+)?)');
    final match = regex.firstMatch(text);
    return match != null ? double.parse(match.group(0)!) : 0;
  }

  // 💾 ذخیره
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString("expenses", data);
  }

  // 📥 لود
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

  // ➕ افزودن (چه صوتی چه تایپی)
  void addExpense(String input) {
    final amount = extractAmount(input);
    if (amount == 0) return;

    setState(() {
      expenses.add(
        Expense(input, amount, categorize(input)),
      );
    });

    saveData();
    controller.clear();
  }

  // 🎤 Voice (B mode improved stability)
  Future<void> toggleVoice() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );

      if (available) {
        setState(() => isListening = true);

        speech.listen(
          localeId: "en_US",
          listenMode: stt.ListenMode.confirmation,
          onResult: (val) {
            setState(() {
              controller.text = val.recognizedWords;
            });

            // auto-stop if sentence seems complete
            if (val.finalResult) {
              addExpense(val.recognizedWords);
              speech.stop();
              setState(() => isListening = false);
            }
          },
        );
      }
    } else {
      speech.stop();
      setState(() => isListening = false);
    }
  }

  // 📊 analytics
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
        title: const Text("Smart Assistant PRO Lite+"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Type or Speak: e.g. ناهار 120",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                  onPressed: toggleVoice,
                )
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => addExpense(controller.text),
              child: const Text("ثبت"),
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