import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/notes/note.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

final colors = [
  Color(0xFF77172E), // Coral
  Color(0xFF692B17), // Peach
  Color(0xFF9AA0A6), // Sand
  Color(0xFF264D3B), // Mint
  Color(0xFF0C625D), // Sage
  Color(0xFF256377), // Fog
  Color(0xFF284255), // Storm
  Color(0xFF472E5B), // Dusk
  Color(0xFF6C394F), // Blossom
  Color(0xFF4B443A), // Clay
];
Color _getNoteColor(int index) {
  // final colors = [
  //   Colors.orange[100],
  //   Colors.yellow[100],
  //   Colors.green[100],
  //   Colors.blue[100],
  //   Colors.purple[100],
  //   Colors.pink[100]
  // ];

  return colors[index % colors.length];
}

final _uuid = Uuid();

final notesProvider =
    NotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);
final searchQueryProvider = StateProvider<String>((ref) => '');

class NotesNotifier extends Notifier<List<Note>> {
  // final NoteRepository repository;

  // NoteRepository(this.repository);
  @override
  List<Note> build() {
    // return [];
    return generateRandomNotes(10);
  }

  List<Note> getNotes() => state;

  Note createNote(String title, String content,
      {Color? color,
      List<NoteImage>? images,
      Reminder? reminder,
      List<String>? labels}) {
    final newNote = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: images ?? [],
      reminder: reminder,
      labels: labels,
    );
    state = [...state, newNote];
    return newNote;
  }

  void updateNote(Note updatedNote) {
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note
    ];
  }

  void deleteNoteById(String id) {
    state = state.where((note) => note.id != id).toList();
  }

  void searchNotes(String query) {
    state = state.where((note) => note.title.contains(query)).toList();
  }
}

List<Note> generateRandomNotes(int count) {
  final random = Random();
  final notes = <Note>[];
  final titles = [
    'Meeting Notes',
    'Grocery List',
    'Project Ideas',
    'Daily Journal',
    'Workout Plan',
    'Recipe',
    'Travel Itinerary',
    'Book Summary',
    'To-Do List',
    'Brainstorming Session'
  ];

  final contents = [
    'Discuss project milestones and deadlines.',
    'Buy milk, eggs, bread, and cheese.',
    'Idea for a new mobile app to track fitness goals.',
    'Today was a productive day. I managed to complete all my tasks.',
    'Morning run, afternoon gym session, and evening yoga.',
    'Ingredients: 2 cups of flour, 1 cup of sugar, 1/2 cup of butter.',
    'Flight at 10 AM, hotel check-in at 2 PM, dinner reservation at 7 PM.',
    'Summary of "The Great Gatsby": A story about the mysterious Jay Gatsby.',
    '1. Finish the report. 2. Call the client. 3. Schedule a meeting.',
    'Brainstorming ideas for the new marketing campaign.',
    'This is a very long note content that is meant to test the application\'s ability to handle large amounts of text. It includes multiple sentences and goes on for quite a while to ensure that everything is displayed correctly and no data is lost in the process.',
    'Another example of a long note content. This one is also quite extensive and includes various details about a hypothetical scenario. The goal is to make sure that the note-taking application can manage and display long texts without any issues or performance problems.'
  ];

  for (int i = 0; i < count; i++) {
    final title = titles[random.nextInt(titles.length)];

    final content = contents[random.nextInt(contents.length)];
    notes.add(Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: _getNoteColor(random.nextInt(colors.length)),
      images: [],
      reminder: null,
      labels: [],
    ));
  }
  // for (int i = 0; i < count; i++) {
  //   final isLong = random.nextBool();
  //   final content = isLong ? 'This is a very long note. ' * 7 : 'Short note.';
  //   notes.add(Note(
  //     id: _uuid.v4(),
  //     content: content,
  //     title: 'Note $i',
  //     createdAt: DateTime.now(),
  //     color: _getNoteColor(random.nextInt(colors.length)),
  //     updatedAt: DateTime.now(),
  //   ));
  // }

  return notes;
}

// void addRandomNotes() {
//   state = generateRandomNotes(7);
// }