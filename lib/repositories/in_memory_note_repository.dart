import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/models/notes/note_repository.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:uuid/uuid.dart';

class InMemoryNoteRepository implements NoteRepository {
  List<Note> _notes = generateRandomNotes(10);

  @override
  Future<List<Note>> getNotes() async {
    return _notes;
  }

  @override
  Future<Note?> getNoteById(String id) async {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Note> createNote(Note note, {int? position}) async {
    final newNote = note.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (position != null) {
      _notes.insert(position, newNote);
    } else {
      _notes.insert(0, newNote);
    }
    return newNote;
  }

  Future<Note> createNoteWithDetails(String title, String content,
      {Color? color,
      List<NoteImage>? images,
      Reminder? reminder,
      List<String>? labels,
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

    if (position != null) {
      _notes.insert(position, newNote);
    } else {
      _notes.insert(0, newNote);
    }

    return newNote;
  }

  @override
  Future<void> updateNote(Note note) async {
    _notes = [
      for (final n in _notes)
        if (n.id == note.id) note else n
    ];
  }

  @override
  Future<void> deleteNoteById(String id) async {
    _notes = _notes.where((note) => note.id != id).toList();
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    return _notes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

const _uuid = Uuid();

Color _getNoteColor(int index) {
  return colors.values.elementAt(index % colors.length);
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
