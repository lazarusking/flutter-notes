import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/notes/note.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

const colors = {
  'coral': Color(0xFF77172E),
  'peach': Color(0xFF692B17),
  'sand': Color(0xFF7C4A03),
  'mint': Color(0xFF264D3B),
  'sage': Color(0xFF0C625D),
  'fog': Color(0xFF256377),
  'storm': Color(0xFF284255),
  'dusk': Color(0xFF472E5B),
  'blossom': Color(0xFF6C394F),
  'clay': Color(0xFF4B443A),
  'chalk': Color(0xFF232427)
};
final defaultColor = Color(0xFF202124);

String getColorName(Color color) {
  return colors.entries
      .firstWhere((entry) => entry.value == color,
          orElse: () => MapEntry('unknown', Colors.transparent))
      .key;
}

Color _getNoteColor(int index) {
  // final colors = [
  //   Colors.orange[100],
  //   Colors.yellow[100],
  //   Colors.green[100],
  //   Colors.blue[100],
  //   Colors.purple[100],
  //   Colors.pink[100]
  // ];

  return colors.values.elementAt(index % colors.length);
}

final _uuid = Uuid();
// final labelProvider = FutureProvider((ref) async {
//   return ref.read(labelsProvider.notifier);
// });
final labelsProvider =
    NotifierProvider<LabelsNotifier, List<Label>>(LabelsNotifier.new);

class LabelsNotifier extends Notifier<List<Label>> {
  @override
  List<Label> build() {
    return [];
  }

  /// Adds a new label with the given [name].
  ///
  /// If a label with the specified name does not exist, it creates a new label.
  /// If a label with the specified name already exists, it returns the existing label.
  ///
  /// Returns the created or existing [Label].
  Label addLabel(String name) {
    // Check if label already exists by name
    final existingLabel = state.firstWhere(
      (label) => label.name == name,
      orElse: () => Label(id: null, name: ""),
    );

    if (existingLabel.id == null) {
      // Create a new label if it doesn't exist
      final newLabel = Label(id: state.length + 1, name: name);
      state = [...state, newLabel];
      return newLabel;
    }
    return existingLabel;
  }

  void updateLabel(Label updatedLabel) {
    state = [
      for (final label in state)
        if (label.id == updatedLabel.id) updatedLabel else label
    ];
  }

  void deleteLabelById(int id) {
    state = state.where((label) => label.id != id).toList();
  }

  Label? getLabelById(int id) {
    try {
      return state.firstWhere((label) => label.id == id);
    } catch (e) {
      return null;
    }
  }
}

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

  Note? getNoteById(String id) {
    try {
      return state.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Note createNote(String title, String content,
      {Color? color,
      List<NoteImage>? images,
      Reminder? reminder,
      List<String>? labels,
      int? position}) {
    final labelIds = labels
            ?.map(
                (name) => ref.read(labelsProvider.notifier).addLabel(name).name)
            .toList() ??
        [];

    final newNote = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      color: color ?? Colors.transparent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: images ?? [],
      reminder: reminder,
      labels: labelIds,
    );
    if (position != null) {
      final newState = List<Note>.from(state);
      newState.insert(
          position, newNote); // Insert the note at the original position
      state = newState;
    } else {
      state = [
        newNote,
        ...state
      ]; // Add the note at the end if no position is specified
    }
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

  List<Note> searchNotes(String query) {
    final results = state
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return results;
  }

  List<Label> getLabelsForNote(Note note) {
    return note.labels
        .map((label) =>
            ref.read(labelsProvider.notifier).getLabelById(int.parse(label)))
        .whereType<Label>()
        .toList();
  }

  void initializeLabels() {
    final labelsNotifier = ref.read(labelsProvider.notifier);
    for (final name in labelNames) {
      labelsNotifier.addLabel(name);
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

      // Assign unique random labels to the note
      final noteLabels = (labelNames.toList()..shuffle(random))
          .take(random.nextInt(3) + 1)
          .toList();

      notes.add(Note(
        id: _uuid.v4(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: _getNoteColor(random.nextInt(colors.length)),
        images: [],
        reminder: null,
        labels: noteLabels,
      ));
    }

    return notes;
  }
}

final labelNames = [
  'work',
  'personal',
  'urgent',
  'shopping',
  'ideas',
  'travel',
  'fitness',
  'reading',
  'chores',
  'miscellaneous'
];

// void addRandomNotes() {
//   state = generateRandomNotes(7);
// }