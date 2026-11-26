import 'package:flutter/material.dart';
import 'package:assignment_2/models/expense.dart';
import 'package:assignment_2/services/database_helper.dart';
import 'package:assignment_2/widgets/expense_tile.dart';
import 'package:assignment_2/screens/add_expense_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AllExpensesPage extends StatefulWidget {
  final String? selectedCategory;
  final DateTime? targetMonth; 

  const AllExpensesPage({
    super.key,
    this.selectedCategory,
    this.targetMonth, 
  });

  @override
  State<AllExpensesPage> createState() => _AllExpensesPageState();
}

class _AllExpensesPageState extends State<AllExpensesPage> {
  List<Expense> expenses = [];
  bool isLoading = true;

  String? currentCategory;
  int? currentUserId;
  late DateTime displayMonth; 

  @override
  void initState() {
    super.initState();
    currentCategory = widget.selectedCategory;
    displayMonth = widget.targetMonth ?? DateTime.now();
    _loadUserAndExpenses();
  }

  Future _loadUserAndExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('currentUserId');
    });

    if (currentUserId != null) {
      _loadExpenses();
    }
  }

  Future _loadExpenses() async {
    if (currentUserId == null) return;

    setState(() => isLoading = true);

    final List<Map<String, dynamic>> rawData = await DatabaseHelper.instance
        .readExpensesForUser(currentUserId!);

    final List<Expense> allData = rawData
        .map((map) => Expense.fromMap(map))
        .toList();

    final List<Expense> monthData = allData.where((e) {
      return e.date.year == displayMonth.year &&
          e.date.month == displayMonth.month;
    }).toList();

    if (currentCategory != null) {
      expenses = monthData.where((e) => e.category == currentCategory).toList();
    } else {
      expenses = monthData;
    }

    expenses.sort((a, b) => b.date.compareTo(a.date));

    setState(() => isLoading = false);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getMonthName() {
    return DateFormat('MMMM yyyy').format(displayMonth); 
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> allExpenses) {
    Map<String, List<Expense>> grouped = {};

    for (var expense in allExpenses) {
      String dateKey = _formatDate(expense.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthName = _getMonthName();

    final String pageTitle = currentCategory != null
        ? "$currentCategory ($currentMonthName)"
        : "$currentMonthName Expenses";

    final groupedExpenses = _groupExpensesByDate(expenses);
    final sortedDates = groupedExpenses.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18, 
          ),
        ),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          if (currentCategory != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: "Show All",
              onPressed: () {
                setState(() {
                  currentCategory = null;
                });
                _loadExpenses();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryBox("Food", "assets/images/food.png"),
                    _buildCategoryBox(
                      "Transport",
                      "assets/images/transport.png",
                    ),
                    _buildCategoryBox("Bills", "assets/images/bills.jpg"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryBox("Shopping", "assets/images/shopping.png"),
                    _buildCategoryBox(
                      "Entertainment",
                      "assets/images/entertainment.png",
                    ),
                    _buildCategoryBox("Others", "assets/images/others.jpg"),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No expenses in $currentMonthName",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateKey = sortedDates[index];
                      final dayExpenses = groupedExpenses[dateKey]!;
                      double dailyTotal = dayExpenses.fold(
                        0,
                        (sum, item) => sum + item.amount,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 0, bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(color: Colors.grey[300]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateKey,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "RM ${dailyTotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...dayExpenses.map((expense) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Dismissible(
                                key: ValueKey(expense.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) async {
                                  await DatabaseHelper.instance.delete(
                                    expense.id!,
                                  );
                                  if (!mounted) return;
                                  setState(() {
                                    expenses.remove(expense);
                                  });
                                  _loadExpenses();
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
                                      if (result == true) {
                                        _loadExpenses();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBox(String title, String imageName) {
    final bool isSelected = currentCategory == title;
    return InkWell(
      onTap: () {
        setState(() {
          currentCategory = (currentCategory == title) ? null : title;
        });
        _loadExpenses();
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.lightBlue.withValues(alpha: 0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.lightBlue, width: 2)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageName,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.lightBlue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
