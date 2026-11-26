import 'package:flutter/material.dart';
import 'package:assignment_2/models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseTile({super.key, required this.expense, this.onTap});

  String _iconForCategory() {
    switch (expense.category) {
      case "Food":
        return "assets/images/food.png";
      case "Transport":
        return "assets/images/transport.png";
      case "Bills":
        return "assets/images/bills.jpg";
      case "Shopping":
        return "assets/images/shopping.png";
      case "Entertainment":
        return "assets/images/entertainment.png";
      default:
        return "assets/images/others.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        "${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}";

    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          _iconForCategory(),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(expense.title.isNotEmpty ? expense.title : expense.category),

      subtitle: Text("$formattedDate  |  ${expense.category}"),

      trailing: Text(
        "RM ${expense.amount.toStringAsFixed(2)}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}
