import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/models/notes/note_repository.dart';
import 'package:notes/providers/theme_provider.dart';
import 'package:notes/repositories/in_memory_note_repository.dart';
import 'package:uuid/uuid.dart';

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
const darkColors = {
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

const lightColors = {
  'coral': Color(0xFFFAAFAF),
  'peach': Color(0xFFFDCFE9),
  'sand': Color(0xFFE6C9A8),
  'mint': Color(0xFFE2F6D3),
  'sage': Color(0xFFB4DDD3),
  'fog': Color(0xFFD4E4ED),
  'storm': Color(0xFFAECBFA),
  'dusk': Color(0xFFD7AEFB),
  'blossom': Color(0xFFF6E5EB),
  'clay': Color(0xFFE8EAED),
  'chalk': Color(0xFFFFFFFF)
};

const transparent = Colors.transparent;
// END OF UTIL FUNCTIONS
//========================================================
const _uuid = Uuid();

// Generate colorPairs from the maps
// Dark mode : Light mode
//   const Color(0xFF77172E): const Color(0xFFFAAFAF), // coral
final colorPairs = Map.fromEntries(
  darkColors.entries.map(
    (entry) => MapEntry(
      entry.value,
      lightColors[entry.key]!,
    ),
  ),
);

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

String getColorName(Color color) {
  return colors.entries
      .firstWhere((entry) => entry.value == color,
          orElse: () => const MapEntry('unknown', Colors.transparent))
      .key;
}

Color getThemeAwareColor(Color? color, Brightness brightness) {
  if (color == null || color == Colors.transparent) {
    return Colors.transparent;
  }

  return brightness == Brightness.dark
      ? color // If dark theme, keep original color
      : colorPairs[color] ??
          Colors.transparent; // If light theme, get light variant
}

Color _getNoteColor(int index) {
  return colors.values.elementAt(index % colors.length);
}

// final labelProvider = FutureProvider((ref) async {
//   return ref.read(labelsProvider.notifier);
// });
final labelsProvider =
    NotifierProvider<LabelsNotifier, List<Label>>(LabelsNotifier.new);

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

final notesRepositoryProvider = Provider<NoteRepository>((ref) {
  return InMemoryNoteRepository();
});
final searchQueryProvider = StateProvider<String>((ref) => '');

class LabelsNotifier extends Notifier<List<Label>> {
  late final NoteRepository _repository;

  /// Adds a new label with the given [name].
  ///
  /// If a label with the specified name does not exist, it creates a new label.
  /// If a label with the specified name already exists, it returns the existing label.
  ///
  /// Returns the created or existing [Label].
  Future<Label> addLabel(String name) async {
    // Check if label already exists by name
    final existingLabel = await _repository.getLabelByName(name);

    if (existingLabel == null) {
      // Create a new label if it doesn't exist
      final newLabel = Label(id: (state.length + 1).toString(), name: name);
      state = [...state, newLabel];
      await _repository.createLabel(newLabel);
      return newLabel;
    }
    return existingLabel;
  }

  @override
  List<Label> build() {
    _repository = ref.read(notesRepositoryProvider);
    return [];
    return [
      Label(id: '1', name: 'work'),
      Label(id: '2', name: 'personal'),
      Label(id: '3', name: 'urgent'),
      Label(id: '4', name: 'shopping'),
      Label(id: '5', name: 'ideas'),
      Label(id: '6', name: 'travel'),
      Label(id: '7', name: 'fitness'),
      Label(id: '8', name: 'reading'),
      Label(id: '9', name: 'chores'),
      Label(id: '10', name: 'miscellaneous')
    ];
  }

  Future<void> deleteLabelById(String id) async {
    state = state.where((label) => label.id != id).toList();
    await _repository.deleteLabelById(id);
  }

  Future<Label?> getLabelById(String id) async {
    return await _repository.getLabelById(id);
  }

  Future<List<Label>> getLabels() async {
    return await _repository.getLabels();
  }

  Future<void> updateLabel(Label updatedLabel) async {
    state = [
      for (final label in state)
        if (label.id == updatedLabel.id) updatedLabel else label
    ];
    await _repository.updateLabel(updatedLabel);
  }
}

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late final NoteRepository _repository;

  @override
  @override
  Future<List<Note>> build() async {
    _repository = ref.read(notesRepositoryProvider);
    // return generateRandomNotes(10);
    // _initializeNotes();
    state = const AsyncValue.data([]);
    await _initializeNotes();
    // state = AsyncValue.data(await _repository.getNotes());
    // state = await AsyncValue.guard(() => _repository.getNotes());

    // return await _repository.getNotes();
    return [];
  }

  Future<Note> createNote(Note note, {int? position}) async {
    initializeLabels();
    final labelIds = await Future.wait(note.labels.map((noteLabel) async {
      final label =
          await ref.read(labelsProvider.notifier).addLabel(noteLabel.name);
      return label;
    }).toList());
    final updatedNote = note.copyWith(labels: labelIds);
    final newNote =
        await _repository.createNote(updatedNote, position: position);
    if (position != null) {
      final newState = List<Note>.from(state.value!);
      newState.insert(position, newNote);
      state = AsyncValue.data(newState);
      print(state);
    } else {
      state = AsyncValue.data([newNote, ...state.value!]);
    }
    // state = await _repository.getNotes();
    // state = await AsyncValue.guard(() => _repository.getNotes());

    return newNote;
  }

  Future<void> deleteNoteById(String id) async {
    // state = state.where((note) => note.id != id).toList();
    // await _repository.deleteNoteById(id);
    // Optimistically update the state
    state =
        AsyncValue.data(state.value!.where((note) => note.id != id).toList());

    // Perform the backend deletion
    try {
      await _repository.deleteNoteById(id);
    } catch (e) {
      // If the backend deletion fails, revert the state
      state = await AsyncValue.guard(() => _repository.getNotes());
    }
  }

  Future<List<Note>> generateRandomNotes(int count) async {
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

      // Save labels to the label notifier
      final labelIds = await Future.wait(noteLabels
          .map((name) async =>
              (await ref.read(labelsProvider.notifier).addLabel(name)))
          .toList());
      print(title);
      notes.add(Note(
        id: _uuid.v4(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: _getNoteColor(random.nextInt(colors.length)),
        images: [],
        reminder: null,
        labels: labelIds,
      ));
    }

    return notes;
  }

  List<Label> getLabelsForNote(Note note) {
    return note.labels
        .map((label) => label.id != null
            ? ref.read(labelsProvider.notifier).getLabelById(label.id!)
            : null)
        .whereType<Label>()
        .toList();
  }

  Future<Note?> getNoteById(String id) async {
    // try {
    //   print('${state.value?.firstWhere((note) => note.id == id).color} color');
    //   print("getting note by id");
    //   return state.value?.firstWhere((note) => note.id == id);
    // } catch (e) {
    //   return null;
    // }
    return await _repository.getNoteById(id);
  }

  // NoteRepository(this.repository);

  Future<List<Note>> getNotes() async {
    state = AsyncValue.data(await _repository.getNotes());
    return state.value ?? [];
  }

  void initializeLabels() {
    final labelsNotifier = ref.read(labelsProvider.notifier);
    for (final name in labelNames) {
      labelsNotifier.addLabel(name);
    }
  }

  List<Note> searchNotes(String query) {
    final results = state.value!
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return results;
  }

  Future<void> updateNote(Note updatedNote) async {
    // Optimistically update the state
    state = AsyncValue.data([
      for (final note in state.value!)
        if (note.id == updatedNote.id) updatedNote else note
    ]);

    // Perform the backend update
    try {
      await _repository.updateNote(updatedNote);
    } catch (e) {
      // If the backend update fails, revert the state
      state = await AsyncValue.guard(() => _repository.getNotes());
    }
  }

  Future<void> _initializeNotes() async {
    state = const AsyncLoading();
    // state = AsyncValue.data(await _repository.getNotes());
    state = await AsyncValue.guard(() => _repository.getNotes());
  }
}

// Create Color extension
extension ThemeAwareColor on Color {
  Color getThemeAwareColor(WidgetRef ref) {
    if (this == Colors.transparent) return Colors.transparent;

    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    return isDark ? this : colorPairs[this] ?? Colors.transparent;
  }
}

// void addRandomNotes() {
//   state = generateRandomNotes(7);
// }