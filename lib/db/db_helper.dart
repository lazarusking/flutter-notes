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
    await db.execute('''
      CREATE TABLE labels (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE note_labels (
        note_id TEXT,
        label_id TEXT,
        FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
        FOREIGN KEY (label_id) REFERENCES labels(id) ON DELETE CASCADE,
        PRIMARY KEY (note_id, label_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE reminders (
        note_id TEXT PRIMARY KEY,
        reminder_time TEXT,
        recurrence TEXT,
        FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE images (
        id TEXT PRIMARY KEY,
        note_id TEXT,
        image_data BLOB,
        FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
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

  Future<void> insertLabel(Label label) async {
    Database db = await database;
    await db.insert(
      'labels',
      label.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Label>> queryAllLabels() async {
    Database db = await database;
    final result = await db.query('labels');
    return result.map((json) => Label.fromJson(json)).toList();
  }

  Future<void> insertNoteLabel(String noteId, String labelId) async {
    Database db = await database;
    await db.insert(
      'note_labels',
      {'note_id': noteId, 'label_id': labelId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertReminder(Reminder reminder, String noteId) async {
    Database db = await database;
    await db.insert(
      'reminders',
      {
        'note_id': noteId,
        'reminder_time': reminder.time.toIso8601String(),
        'recurrence': reminder.recurrence,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertImage(NoteImage image, String noteId) async {
    Database db = await database;
    await db.insert(
      'images',
      {
        'id': image.id,
        'note_id': noteId,
        'image_data': image.imageData,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertNoteWithRelations(Note note) async {
    Database db = await database;
    await db.transaction((txn) async {
      // Insert the note
      await txn.insert(
        'notes',
        note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert related images
      for (var image in note.images) {
        await txn.insert(
          'images',
          {
            'id': image.id,
            'note_id': note.id,
            'image_data': image.imageData,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Insert reminder if it exists
      if (note.reminder != null) {
        await txn.insert(
          'reminders',
          {
            'note_id': note.id,
            'reminder_time': note.reminder!.time.toIso8601String(),
            'recurrence': note.reminder!.recurrence,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Insert labels
      for (var label in note.labels) {
        await txn.insert(
          'note_labels',
          {
            'note_id': note.id,
            'label_id': label,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
