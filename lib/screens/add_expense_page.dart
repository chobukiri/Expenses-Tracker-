import 'package:flutter/material.dart';
import 'package:assignment_2/models/expense.dart';
import 'package:assignment_2/services/database_helper.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:assignment_2/screens/map_page.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class AddExpensesPage extends StatefulWidget {
  final Expense? existingExpense;
  const AddExpensesPage({super.key, this.existingExpense});

  @override
  State<AddExpensesPage> createState() => _AddExpensesPageState();
}

class _AddExpensesPageState extends State<AddExpensesPage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  final player = AudioPlayer();

  String selectedCategory = "Food";
  DateTime _selectedDate = DateTime.now();
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      titleController.text = widget.existingExpense!.title;
      amountController.text = widget.existingExpense!.amount.toString();
      selectedCategory = widget.existingExpense!.category;
      _selectedDate = widget.existingExpense!.date;

      if (widget.existingExpense!.latitude != null &&
          widget.existingExpense!.longitude != null) {
        _pickedLocation = LatLng(
          widget.existingExpense!.latitude!,
          widget.existingExpense!.longitude!,
        );
      }
    }
  }

  @override
  void dispose() {
    player.dispose();
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingExpense != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Expense" : "Add Expense")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _presentDatePicker,
                ),
              ],
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue:
                  selectedCategory, 
              items: const [
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Transport", child: Text("Transport")),
                DropdownMenuItem(value: "Bills", child: Text("Bills")),
                DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
                DropdownMenuItem(
                  value: "Entertainment",
                  child: Text("Entertainment"),
                ),
                DropdownMenuItem(value: "Others", child: Text("Others")),
              ],
              onChanged: (val) => setState(() => selectedCategory = val!),
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 25),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: Text(
                _pickedLocation == null
                    ? "Select Location"
                    : "Location Selected",
                style: TextStyle(
                  color: _pickedLocation == null ? Colors.grey : Colors.black,
                  fontWeight: _pickedLocation == null
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );

                if (result != null && result is LatLng) {
                  setState(() {
                    _pickedLocation = result;
                  });
                }
              },
            ),
            const Divider(),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (amountController.text.isEmpty) return;

                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('currentUserId');

                  if (userId == null) return;

                  try {
                    final player = AudioPlayer();
                    player.play(AssetSource('audios/1.mp3'));
                  } catch (e) {
                    debugPrint("Audio Error: $e");
                  }

                  final expense = Expense(
                    id: widget.existingExpense?.id,
                    userId: userId,
                    title: titleController.text,
                    amount: double.tryParse(amountController.text) ?? 0.0,
                    date: _selectedDate,
                    category: selectedCategory,
                    latitude: _pickedLocation?.latitude,
                    longitude: _pickedLocation?.longitude,
                  );

                  if (isEditing) {
                    await DatabaseHelper.instance.update(expense.toMap());
                  } else {
                    await DatabaseHelper.instance.createExpense(
                      expense.toMap(),
                    );
                  }

                  if (!mounted) return;

                  Navigator.pop(context, true);
                },
                child: Text(isEditing ? "Save Changes" : "Save Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
