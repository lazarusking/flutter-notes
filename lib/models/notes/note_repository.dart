import 'package:notes/models/notes/note.dart';

// abstract class NoteRepository {
//   Future<List<Note>> getNotes();
//   Future<Note?> getNoteById(String id);
//   Future<Note> createNote(Note note, {int? position});
//   Future<void> updateNote(Note note);
//   Future<void> deleteNoteById(String id);
//   Future<List<Note>> searchNotes(String query);
// }

abstract class NoteRepository {
  Future<List<Note>> getNotes();

  Future<Note?> getNoteById(String id);

  Future<Note> createNote(Note note, {int? position});

  Future<void> updateNote(Note note);

  Future<void> deleteNoteById(String id);

  Future<List<Note>> searchNotes(String query);

  //===========Label=================
  Future<List<Label>> getLabels();

  Future<Label?> getLabelByName(String name);

  Future<Label?> getLabelById(String id);

  Future<void> createLabel(Label label); // Added
  Future<void> updateLabel(Label label);

  Future<void> deleteLabelById(String id);
}
