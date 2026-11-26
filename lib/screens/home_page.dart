import 'package:flutter/material.dart';
import 'package:assignment_2/models/expense.dart';
import 'package:assignment_2/widgets/expense_tile.dart';
import 'package:assignment_2/screens/add_expense_page.dart';
import 'package:assignment_2/services/database_helper.dart';
import 'package:assignment_2/screens/all_expenses_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Expense> currentMonthExpenses = [];

  List<Expense> recentExpenses = [];
  bool isLoading = true;

  DateTime selectedMonth = DateTime.now();

  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserAndExpenses();
  }

  Future _loadUserAndExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('currentUserId');
    });

    if (currentUserId != null) {
      refreshExpenses();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future refreshExpenses() async {
    if (currentUserId == null) return;

    setState(() => isLoading = true);

    try {
      final List<Map<String, dynamic>> data = await DatabaseHelper.instance
          .readExpensesForUser(currentUserId!);

      final List<Expense> allData = data
          .map((e) => Expense.fromMap(e))
          .toList();

      final monthData = allData.where((e) {
        return e.date.year == selectedMonth.year &&
            e.date.month == selectedMonth.month;
      }).toList();

      monthData.sort((a, b) => b.date.compareTo(a.date));

      List<Expense> recentOnly = [];
      if (monthData.isNotEmpty) {
        final latestDate = monthData.first.date;
        final sevenDaysAgo = latestDate.subtract(const Duration(days: 7));

        recentOnly = monthData.where((e) {
          return e.date.isAfter(sevenDaysAgo) ||
              e.date.isAtSameMomentAs(sevenDaysAgo);
        }).toList();
      }

      if (mounted) {
        setState(() {
          currentMonthExpenses = monthData;
          recentExpenses = recentOnly;
        });
      }
    } catch (e) {
      debugPrint("Database Error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: "Select Month",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null && mounted) {
      setState(() {
        selectedMonth = picked;
      });
      refreshExpenses();
    }
  }

  String _getMonthYearString(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  String _getFullMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    double totalCashFlow = currentMonthExpenses.fold(
      0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SpendWise",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: _selectMonth,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.2,
                  ), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getMonthYearString(selectedMonth),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpensesPage()),
          );
          if (result == true) refreshExpenses();
        },
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "RM ${totalCashFlow.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Cash Flow (${_getFullMonthName(selectedMonth)})",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllExpensesPage(targetMonth: selectedMonth),
                      ),
                    );
                    refreshExpenses();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Spending Overview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Current Week Activities",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : recentExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 50,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No recent activities in ${_getFullMonthName(selectedMonth)}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: recentExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = recentExpenses[index];

                          return Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) async {
                              await DatabaseHelper.instance.delete(expense.id!);

                              if (!mounted) return;

                              setState(() {
                                currentMonthExpenses.removeWhere(
                                  (e) => e.id == expense.id,
                                );
                                recentExpenses.removeAt(index);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${expense.title} deleted"),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ExpenseTile(
                                expense: expense,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddExpensesPage(
                                        existingExpense: expense,
                                      ),
                                    ),
                                  );
                                  if (result == true) refreshExpenses();
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
