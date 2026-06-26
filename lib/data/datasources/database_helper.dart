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

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table for the overall daily session
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        routine_name TEXT NOT NULL
      )
    ''');

    // Table for the individual completed sets
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
}
