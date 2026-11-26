class Expense {
  final int? id;
  final int userId; 
  final double amount;
  final String title;
  final DateTime date;
  final String category;
  final double? latitude;
  final double? longitude;

  Expense({
    this.id,
    required this.userId, 
    required this.amount,
    required this.title,
    required this.date,
    required this.category,
    this.latitude,
    this.longitude,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      userId: map['userId'], 
      amount: map['amount'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      category: map['category'] ?? 'General',
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, 
      'amount': amount,
      'title': title,
      'date': date.toIso8601String(),
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
