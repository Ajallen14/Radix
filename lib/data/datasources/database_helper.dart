import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'radix.db');

    return await openDatabase(
      path, 
      version: 3, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, 
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Table for custom routines
    await db.execute('''
      CREATE TABLE routines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        volume TEXT,
        category TEXT
      )
    ''');

    // 2. Table for daily sessions
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        routine_name TEXT NOT NULL
      )
    ''');

    // 3. Table for completed sets
    await db.execute('''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_name TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        completed_at INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');

    // 4. Table for weekly schedule
    await db.execute('''
      CREATE TABLE weekly_schedule(
        day INTEGER PRIMARY KEY,
        focus TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS routines(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          volume TEXT,
          category TEXT
        )
      ''');
    }
    
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS weekly_schedule(
          day INTEGER PRIMARY KEY,
          focus TEXT
        )
      ''');
    }
  }

  Future<int> insertSet(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('sets', row);
  }

  Future<List<Map<String, dynamic>>> getSetsForWorkout(int workoutId) async {
    final db = await database;
    return await db.query(
      'sets',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<int> countSetsForSession(int workoutId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM sets WHERE workout_id = ?', 
      [workoutId]
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
} 