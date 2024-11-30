import 'package:flutter/material.dart';
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

  Future<Note?> getNoteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return Note.fromJson(results.first);
    }
    return null;
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> noteMaps = await db.query(
      'notes',
      orderBy: 'updatedAt DESC',
    );

    return Future.wait(noteMaps.map((noteMap) async {
      final List<Map<String, dynamic>> labelMaps = await db.query(
        'labels',
        where: 'noteId = ?',
        whereArgs: [noteMap['id']],
      );

      final List<Map<String, dynamic>> imageMaps = await db.query(
        'images',
        where: 'noteId = ?',
        whereArgs: [noteMap['id']],
      );

      final reminderMap = await db.query(
        'reminders',
        where: 'noteId = ?',
        whereArgs: [noteMap['id']],
      );

      return Note(
        id: noteMap['id'],
        title: noteMap['title'],
        content: noteMap['content'],
        color: Color(int.parse(noteMap['color'])),
        createdAt: DateTime.parse(noteMap['createdAt']),
        updatedAt: DateTime.parse(noteMap['updatedAt']),
        labels: labelMaps.map((m) => Label.fromJson(m)).toList(),
        images: imageMaps
            .map((m) => NoteImage(
                  id: m['id'],
                  noteId: m['noteId'],
                  imageData: m['imageData'],
                ))
            .toList(),
        reminder: reminderMap.isNotEmpty
            ? Reminder(
                time: DateTime.parse(reminderMap.first['time'] as String),
                recurrence: reminderMap.first['recurrence'] as Recurrence,
              )
            : null,
      );
    }).toList());
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
      for (final image in note.images) {
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
      for (final label in note.labels) {
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

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.transaction((txn) async {
      // Update note
      await txn.update(
        'notes',
        {
          'title': note.title,
          'content': note.content,
          'color': note.color!.value.toString(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [note.id],
      );

      // Delete existing relations
      await txn
          .delete('note_labels', where: 'note_id = ?', whereArgs: [note.id]);
      await txn.delete('images', where: 'note_id = ?', whereArgs: [note.id]);
      await txn.delete('reminders', where: 'note_id = ?', whereArgs: [note.id]);

      // Insert new relations
      for (final label in note.labels) {
        await txn.insert('note_labels', {
          'note_id': note.id,
          'label_id': label,
        });
      }

      for (final image in note.images) {
        await txn.insert('images', {
          'id': image.id,
          'note_id': note.id,
          'image_data': image.imageData,
        });
      }

      if (note.reminder != null) {
        await txn.insert('reminders', {
          'note_id': note.id,
          'reminder_time': note.reminder!.time.toIso8601String(),
          'recurrence': note.reminder!.recurrence,
        });
      }
    });
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );

    return results.map((json) => Note.fromJson(json)).toList();
  }

//==========Labels=============================================

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

  Future<void> deleteLabelById(String id) async {
    Database db = await database;
    await db.delete(
      'labels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Label?> getLabelById(String id) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'labels',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return Label.fromJson(results.first);
    }
    return null;
  }

  Future<Label?> getLabelByName(String name) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'labels',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (results.isNotEmpty) {
      return Label.fromJson(results.first);
    }
    return null;
  }

  Future<void> updateLabel(Label label) async {
    Database db = await database;
    await db.update(
      'labels',
      label.toJson(),
      where: 'id = ?',
      whereArgs: [label.id],
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
}
