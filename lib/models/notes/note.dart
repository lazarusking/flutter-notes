// To parse this JSON data, do
//
//     final note = noteFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/material.dart';

Note noteFromJson(String str) => Note.fromJson(json.decode(str));

String noteToJson(Note data) => json.encode(data.toJson());

class Note {
  String id;
  String title;
  Color? color;
  DateTime createdAt;
  DateTime updatedAt;
  String content = '';
  List<NoteImage> images = [];
  Reminder? reminder;
  List<String> labels;

  Note({
    required this.id,
    required this.title,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.content = '',
    this.images = const [],
    this.reminder,
    this.labels = const [],
  });
  factory Note.empty() => Note(
      id: '',
      title: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: const Color(0xFF202124));
  Note copyWith({
    String? id,
    String? title,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? content,
    List<NoteImage>? images,
    Reminder? reminder,
    List<String>? labels,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        content: content ?? this.content,
        images: images ?? this.images,
        reminder: reminder ?? this.reminder,
        labels: labels ?? this.labels,
      );

  @override
  String toString() {
    return 'Note{id: $id, title: $title, color: $color, createdAt: $createdAt, updatedAt: $updatedAt, images: $images, reminder: $reminder, labels: $labels}';
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json["id"],
        title: json["title"],
        color: json["color"] != null ? Color(int.parse(json["color"])) : null,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        content: json["content"],
        images: List<NoteImage>.from(
            json["images"].map((x) => NoteImage.fromJson(x))),
        reminder: Reminder.fromJson(json["reminder"]),
        labels: List<String>.from(json["labels"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "color": color?.value.toString(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "content": content,
        "images": List<dynamic>.from(images.map((x) => x.toJson())),
        "reminder": reminder?.toJson(),
        "labels": List<dynamic>.from(labels.map((x) => x))
      };
}

class NoteImage {
  String id;
  String noteId;
  List<int> imageData;

  NoteImage({
    required this.id,
    required this.noteId,
    required this.imageData,
  });

  NoteImage copyWith({
    String? id,
    String? noteId,
    List<int>? imageData,
  }) =>
      NoteImage(
        id: id ?? this.id,
        noteId: noteId ?? this.noteId,
        imageData: imageData ?? this.imageData,
      );

  factory NoteImage.fromJson(Map<String, dynamic> json) => NoteImage(
        id: json["id"],
        noteId: json["note_id"],
        imageData: List<int>.from(json["image_data"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "note_id": noteId,
        "image_data": imageData,
      };
}

class Reminder {
  DateTime time;
  String recurrence;

  Reminder({
    required this.time,
    required this.recurrence,
  });

  Reminder copyWith({
    DateTime? time,
    String? recurrence,
  }) =>
      Reminder(
        time: time ?? this.time,
        recurrence: recurrence ?? this.recurrence,
      );

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        time: DateTime.parse(json["time"]),
        recurrence: json["recurrence"],
      );

  Map<String, dynamic> toJson() => {
        "time": time.toIso8601String(),
        "recurrence": recurrence,
      };
}

class Label {
  int? id;
  String name;

  Label({
    required this.id,
    required this.name,
  });

  Label copyWith({
    int? id,
    String? name,
  }) =>
      Label(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory Label.fromJson(Map<String, dynamic> json) => Label(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

// {
//   "id": "550e8400-e29b-41d4-a716-446655440000",
//   "title": "Sample Note",
//   "color": "#FFFFFF",
//   "createdAt": "2023-10-01T12:00:00Z",
//   "updatedAt": "2023-10-01T12:00:00Z",
//   "content": "This is a sample note content.",
//   "images": [
//     {
//       "type": "remote",
//       "url": "https://example.com/image1.jpg"
//     },
//     {
//       "type": "local",
//       "path": "/path/to/local/image.jpg"
//     }
//   ],
//   "reminder": {
//     "time": "2023-10-02T09:00:00Z",
//     "recurrence": "daily"
//   },
//   "labels": ["work", "urgent"]
// }