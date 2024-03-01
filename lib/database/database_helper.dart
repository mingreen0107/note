import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/memo_data.dart';

class DatabaseHelper{
  static Database? _database;

  Future<void> initDatabase() async {
    if (_database == null) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'memos.db');

      _database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE memos(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content TEXT,
                createAt TEXT
              )
          ''');
          });
    }
  }

  Future<List<MemoData>> getMemos() async {
    await initDatabase();
    List<Map<String, dynamic>> maps = await _database!.query('memos');
    
    return List.generate(maps.length, (index) {
      return MemoData(
          id: maps[index]['id'],
          content: maps[index]['content'],
          createAt: DateTime.parse(maps[index]['createAt']));
    });
  }
  Future<int> insertMemo(MemoData memo) async {
    await initDatabase();
    return await _database!.insert('memos', memo.toMap());
  }

  Future<void> deleteMemo(int id) async {
    await initDatabase();
    await _database!.delete(
        'memos',
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  Future<void> updateMemo(MemoData memo) async {
    await initDatabase();
    await _database!.update(
        'memos',
        memo.toMap(),
        where: 'id = ?',
        whereArgs: [memo.id]
    );
  }
}