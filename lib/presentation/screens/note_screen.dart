import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/presentation/notes_provider.dart';

class NoteScreen extends ConsumerStatefulWidget {
  final Note note;

  const NoteScreen({super.key, required this.note});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late Color? _selectedColor;
  late List<NoteImage> _images;
  Reminder? _reminder;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
    _selectedColor = widget.note.color;
    _images = widget.note.images;
    _reminder = widget.note.reminder;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() {
    final updatedNote = widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      color: _selectedColor,
      images: _images,
      reminder: _reminder,
      updatedAt: DateTime.now(),
    );

    final notesNotifier = ref.read(notesProvider.notifier);
    // .updateNote(updatedNote);
    if (updatedNote.title.isEmpty && updatedNote.content.isEmpty) {
      notesNotifier.deleteNoteById(updatedNote.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          content: Text('Empty note discarded'),
          margin: EdgeInsets.only(bottom: 10),
        ),
      );
      return;
    }
    notesNotifier.updateNote(updatedNote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: widget.note.color,
        leading: IconButton(
          tooltip: 'Navigate back',
          icon: Icon(
            Icons.arrow_back,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            _updateNote();
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Add reminder',
            icon: Icon(
              Icons.add_alert_outlined,
              size: 20,
            ),
            onPressed: () {
              // Add reminder action here
            },
          ),
        ],
      ),
      body: Container(
        // Add padding to the container
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.note.color,
        ),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 20),
              showCursor: MediaQuery.of(context).viewInsets.bottom != 0,
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                showCursor: MediaQuery.of(context).viewInsets.bottom != 0,
                decoration: InputDecoration(
                  hintText: 'Note',
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => debugPaintSizeEnabled = !debugPaintSizeEnabled,
      //   child: Icon(Icons.save),
      // ),
      bottomNavigationBar: BottomAppBar(
        color: widget.note.color,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.color_lens, size: 20),
                onPressed: () {
                  // Color picker action here
                },
              ),
              Spacer(),
              Text(
                'Edited ${DateFormat('MMM d, yyyy').format(widget.note.updatedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Spacer(),
              PopupMenuButton<String>(
                onSelected: (String result) {
                  switch (result) {
                    case 'delete':
                      // Delete note then navigate back, snackbar?
                      ref
                          .read(notesProvider.notifier)
                          .deleteNoteById(widget.note.id);
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                              content: Text('Note deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  ref.read(notesProvider.notifier).createNote(
                                        widget.note.title,
                                        widget.note.content,
                                        color: widget.note.color,
                                        images: widget.note.images,
                                        reminder: widget.note.reminder,
                                        labels: widget.note.labels,
                                      );
                                },
                              )),
                        );
                      break;
                    case 'copy':
                      // Copy note action here
                      break;
                    case 'send':
                      // Send note action here
                      break;
                    case 'collaborator':
                      // Add collaborator action here
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'copy',
                    child: ListTile(
                      leading: Icon(Icons.copy),
                      title: Text('Make a copy'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'send',
                    child: ListTile(
                      leading: Icon(Icons.send),
                      title: Text('Send'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'collaborator',
                    child: ListTile(
                      leading: Icon(Icons.person_add),
                      title: Text('Collaborator'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
