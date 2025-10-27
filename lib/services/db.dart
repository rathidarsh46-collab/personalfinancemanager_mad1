// SQLite setup (sqflite). Student note: keep schema simple and explicit.
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'pfm.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT CHECK(type IN ('income','expense')) NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          date TEXT NOT NULL,
          notes TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE categories(
          name TEXT PRIMARY KEY,
          monthly_budget REAL,
          alert_pct INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE goals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          target REAL,
          saved REAL DEFAULT 0,
          due_date TEXT
        )
        ''');
      },
    );
  }
}
