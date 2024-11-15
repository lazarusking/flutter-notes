import 'package:notes/models/notes/note.dart';

abstract class NoteRepository {
  List<Note> getNotes();
  Note? getNoteById(String id);
  Note createNote(Note note);
  void updateNote(Note note);
  void deleteNoteById(String id);
  List<Note> searchNotes(String query);
}
