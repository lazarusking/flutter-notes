import 'package:notes/models/notes/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<Note?> getNoteById(String id);
  Future<Note> createNote(Note note, {int? position});
  Future<void> updateNote(Note note);
  Future<void> deleteNoteById(String id);
  Future<List<Note>> searchNotes(String query);
}
