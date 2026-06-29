
import 'package:flutter/material.dart';
import '../services/category_engine.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final amountCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String category = "Misc";

  void save() {
    final auto = CategoryEngine.detect(descCtrl.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saved: $auto")),
    );

    amountCtrl.clear();
    descCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(controller: amountCtrl, decoration: InputDecoration(labelText: "Amount")),
          TextField(controller: descCtrl, decoration: InputDecoration(labelText: "Description")),
          DropdownButton<String>(
            value: category,
            items: ["Food","Transport","Maintenance","Energy","Misc"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => category = v!),
          ),
          ElevatedButton(onPressed: save, child: Text("Save"))
        ],
      ),
    );
  }
}
