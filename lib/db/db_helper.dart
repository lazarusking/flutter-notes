import 'package:notes/models/notes/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  static Database? _database;
  static const int _version = 1;
  static const String tablename = 'notes';

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        color TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        content TEXT
      )
    ''');
  }

  Future<Note> insert(Note note) async {
    Database db = await database;
    await db.insert(
      tablename,
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return note;
  }

  Future<List<Note>> queryAllRows() async {
    Database db = await database;
    final result = await db.query(tablename, orderBy: "updatedAt DESC");
    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> update(Note note) async {
    Database db = await database;
    return await db.update(
      tablename,
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(String id) async {
    Database db = await database;
    return await db.delete(
      tablename,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
