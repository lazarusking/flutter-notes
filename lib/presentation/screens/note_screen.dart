import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/presentation/notes_provider.dart';
import 'package:notes/widgets/color_picker.dart';

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
  late final List<String>? _labels;

  final DateFormat _dateFormat = DateFormat('MMM d, yyyy', Intl.defaultLocale);

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
    _selectedColor = widget.note.color;
    _images = widget.note.images;
    _reminder = widget.note.reminder;
    _labels = widget.note.labels;
    timeDilation = 1.2; // 1.0 means normal animation speed.
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _selectedColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero),
      ),
      builder: (BuildContext context) {
        return ColorPicker(
          selectedColor: _selectedColor!,
          onColorSelected: (color) {
            // setNewState(() {
            //   _selectedColor = color;
            // });
            setState(() {
              _selectedColor = color;
            });
          },
        );
      },
    );
  }

  void _showBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero),
      ),
      context: context,
      backgroundColor: _selectedColor,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  if (!mounted) return;

                  final copiedNote = widget.note.copyWith();
                  ref
                      .read(notesProvider.notifier)
                      .deleteNoteById(widget.note.id);
                  //pop twice to leave the bottomdrawer then note screen
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(copiedNote);
                  }
                  //ref gets disposed so it doesn't work
                  // ScaffoldMessenger.of(context)
                  //   ..removeCurrentSnackBar()
                  //   ..showSnackBar(
                  //     SnackBar(
                  //       content: Text('Note deleted'),
                  //       action: SnackBarAction(
                  //         label: 'Undo',
                  //         onPressed: () {
                  //           if (!mounted) return;

                  //           ref.read(notesProvider.notifier).createNote(
                  //                 copiedNote.title,
                  //                 copiedNote.content,
                  //                 color: copiedNote.color,
                  //                 images: copiedNote.images,
                  //                 reminder: copiedNote.reminder,
                  //                 labels: copiedNote.labels,
                  //               );
                  //         },
                  //       ),
                  //     ),
                  //   );
                },
              ),
              ListTile(
                leading: Icon(Icons.copy),
                title: Text('Make a copy'),
                onTap: () {
                  // Copy note action here
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.send),
                title: Text('Send'),
                onTap: () {
                  // Send note action here
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.label_outline),
                title: Text('Labels'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.person_add),
                title: Text('Collaborator'),
                onTap: () {
                  // Add collaborator action here
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addLabel(String label) {
    setState(() {
      if (_labels!.contains(label)) {
        _labels.add(label);
      }
    });
  }

  /// Updates an existing note or saves a new note if it doesn't exist.
  void _saveOrUpdateNote() {
    final updatedNote = widget.note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        images: _images,
        reminder: _reminder,
        updatedAt: DateTime.now(),
        labels: _labels);

    final notesNotifier = ref.read(notesProvider.notifier);
    if (updatedNote.title.isEmpty && updatedNote.content.isEmpty) {
      notesNotifier.deleteNoteById(updatedNote.id);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            content: Text('Empty note discarded'),
            margin: EdgeInsets.only(bottom: 10),
          ),
        );
      return;
    }
    if (updatedNote.id.isEmpty) {
      notesNotifier.createNote(updatedNote.title, updatedNote.content,
          color: updatedNote.color,
          images: updatedNote.images,
          reminder: updatedNote.reminder,
          labels: updatedNote.labels);
    } else {
      notesNotifier.updateNote(updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveOrUpdateNote();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: _selectedColor,
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
              // _saveOrUpdateNote();
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Add reminder',
              icon: Icon(
                Icons.add_alert_outlined,
                size: 20,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedColor,
            ),
            child: Hero(
              tag: widget.note.id,
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      showCursor: MediaQuery.of(context).viewInsets.bottom != 0,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        showCursor:
                            MediaQuery.of(context).viewInsets.bottom != 0,
                        decoration: InputDecoration(
                          hintText: 'Note',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                    ),
                    if (_labels!.isNotEmpty) NoteLabels(labels: _labels),
                  ],
                ),
              ),
            )),
        floatingActionButton: kDebugMode
            ? FloatingActionButton(
                onPressed: () {
                  debugPaintSizeEnabled = !debugPaintSizeEnabled;
                },
                child: Icon(Icons.bug_report),
              )
            : null,
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: BottomAppBar(
            color: _selectedColor,
            // height: kBottomNavigationBarHeight +
            //     MediaQuery.of(context).viewInsets.bottom,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 1, vertical: 0),
              margin: const EdgeInsets.all(0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.color_lens),
                    onPressed: () => _showColorPicker(),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 1.8,
                    child: Text(
                      'Edited ${_dateFormat.format(widget.note.updatedAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      _showBottomDrawer(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//a widget that displays the labels of a note
class NoteLabels extends StatelessWidget {
  final List<String> labels;

  const NoteLabels({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.all(2),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final label in labels)
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  // color: Colors.grey[400],
                  borderRadius: SmoothBorderRadius(cornerRadius: 8),
                ),
                // decoration: ShapeDecoration(
                //     color: const Color.fromARGB(255, 115, 115, 114),
                //     shape: SmoothRectangleBorder(
                //         side: BorderSide(color: Colors.grey.shade400),
                //         borderRadius: SmoothBorderRadius(cornerRadius: 10))),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                    ),
                    // SizedBox(width: 4),
                    // GestureDetector(
                    //   onTap: () {
                    //     // Remove label action here
                    //   },
                    //   child: Icon(
                    //     Icons.close,
                    //     size: 16,
                    //     color: Colors.grey.shade200,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
