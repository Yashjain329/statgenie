import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dataset.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _db;

  Future<void> initialize() async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'statgenie.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            created_at TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE datasets (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            file_url TEXT,
            file_size INTEGER,
            row_count INTEGER,
            column_count INTEGER,
            created_at TEXT NOT NULL,
            pending_sync INTEGER NOT NULL DEFAULT 1
          );
        ''');
      },
    );
  }

  Future<void> insertDataset(Dataset d) async {
    await _db!.insert('datasets', d.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Dataset>> getDatasets() async {
    final rows = await _db!.query('datasets', orderBy: 'created_at DESC');
    return rows.map((e) => Dataset.fromJson(e)).toList();
  }

  Future<List<Dataset>> getPendingDatasets() async {
    final rows = await _db!.query('datasets', where: 'pending_sync = 1', orderBy: 'created_at DESC');
    return rows.map((e) => Dataset.fromJson(e)).toList();
  }

  Future<int> getPendingSyncCount() async {
    final res = await _db!.rawQuery('SELECT COUNT(*) AS c FROM datasets WHERE pending_sync = 1');
    return (res.first['c'] as int?) ?? 0;
  }

  Future<void> markAsSynced(String id) async {
    await _db!.update('datasets', {'pending_sync': 0}, where: 'id = ?', whereArgs: [id]);
  }
}