import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:assignment_2/user_model.dart'; // Ensure correct path

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE expenses ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      userId INTEGER NOT NULL,
      amount REAL NOT NULL,
      title TEXT NOT NULL,
      date TEXT NOT NULL,
      category TEXT,
      latitude REAL,
      longitude REAL,
      FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');
  }


  Future<int> registerUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<User?> getUser(int id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<int> updateProfile(int id, String name) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePassword(int id, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateEmail(int id, String newEmail) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'email': newEmail},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createExpense(Map<String, dynamic> expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense);
  }

  Future<List<Map<String, dynamic>>> readExpensesForUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      'expenses',
      where: 'userId = ?',
      orderBy: 'date DESC',
      whereArgs: [userId],
    );
  }

  Future<int> update(Map<String, dynamic> expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
