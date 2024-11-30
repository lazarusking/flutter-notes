import 'package:flutter/material.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/models/notes/note_repository.dart';
import 'package:notes/db/db_helper.dart';
import 'package:uuid/uuid.dart';

class DBNoteRepository implements NoteRepository {
  final DBHelper _dbHelper = DBHelper();
  final _uuid = const Uuid();

  @override
  Future<List<Note>> getNotes() async {
    return await _dbHelper.getNotes();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    return await _dbHelper.getNoteById(id);
  }

  @override
  Future<Note> createNote(Note note, {int? position}) async {
    final newNote = note.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _dbHelper.insertNoteWithRelations(newNote);
    return newNote;
  }

  @override
  Future<void> updateNote(Note note) async {
    await _dbHelper.updateNote(note);
  }

  @override
  Future<void> deleteNoteById(String id) async {
    await _dbHelper.delete(id);
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final notes = await getNotes();
    return notes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<Note> createNoteWithDetails(String title, String content,
      {Color? color,
      List<NoteImage>? images,
      Reminder? reminder,
      List<Label>? labels,
      int? position}) async {
    final newNote = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      color: color ?? Colors.transparent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: images ?? [],
      reminder: reminder,
      labels: labels ?? [],
    );

    await _dbHelper.insertNoteWithRelations(newNote);
    return newNote;
  }

//==========Labels=============================================

  @override
  Future<List<Label>> getLabels() async {
    return await _dbHelper.queryAllLabels();
  }

  @override
  Future<void> createLabel(Label label) async {
    await _dbHelper.insertLabel(label);
  }

  @override
  Future<void> deleteLabelById(String id) async {
    await _dbHelper.deleteLabelById(id);
  }

  @override
  Future<Label?> getLabelById(String id) async {
    return await _dbHelper.getLabelById(id);
  }

  @override
  Future<Label?> getLabelByName(String name) async {
    return await _dbHelper.getLabelByName(name);
  }

  @override
  Future<void> updateLabel(Label label) async {
    await _dbHelper.updateLabel(label);
  }
}
