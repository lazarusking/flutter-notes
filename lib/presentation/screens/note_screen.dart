import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/presentation/screens/select_labels.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/utils/helpers.dart';
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
  // late Color? _selectedColor;
  late List<NoteImage> _images = [];
  Reminder? _reminder;
  List<Label>? _labels;

//todo image rerendering on color change
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy', Intl.defaultLocale);

  Future<List<NoteImage>> _loadImages() async {
    final ByteData data = await rootBundle
        .load('assets/images/notes-high-resolution-logo-only.png');
    return List.generate(
      2,
      (index) => NoteImage(
        imageData: data.buffer.asUint8List(),
        id: 'image_$index',
        noteId: widget.note.id,
      ),
    );
  }

  late final ValueNotifier<Color?> _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
    // _selectedColor = widget.note.color;
    //_selectedColor was causing the ImageGrid to rebuild so I settled on valuenotifier
    _selectedColor = ValueNotifier(widget.note.color);
    _images = widget.note.images;
    _reminder = widget.note.reminder;
    _labels = widget.note.labels;
    timeDilation = 1; // 1.0 means normal animation speed.
  }

  @override
  void dispose() {
    _selectedColor.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Color getThemeAwareSelectedColor() {
    return _selectedColor.value!.getThemeAwareColor(ref);
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Helpers.getDefaultBackgroundColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero),
      ),
      builder: (BuildContext context) {
        return ColorPicker(
          selectedColor: _selectedColor.value!,
          onColorSelected: (color) {
            // setState(() {});
            //setting state here caused the rebuilding
            _selectedColor.value = color;
          },
        );
      },
    );
  }

  Color getThemeAwareColor() => _selectedColor.value!.getThemeAwareColor(ref);

  void _showBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero),
      ),
      context: context,
      backgroundColor: _selectedColor.value == Colors.transparent
          ? Helpers.getDefaultBackgroundColor(context)
          : getThemeAwareSelectedColor(),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
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
                leading: const Icon(Icons.copy),
                title: const Text('Make a copy'),
                onTap: () {
                  // Copy note action here
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text('Send'),
                onTap: () {
                  // Send note action here
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.label_outline),
                title: const Text('Labels'),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SelectLabelsScreen()),
                  );
                  // print("result");
                  // print(result);
                  if (result != null && result is Set<String>) {
                    print("lets go");
                    print(result);
                    await addlabels(result);
                    // setState(() {
                    //   _labels = result;
                    // });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Collaborator'),
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

  Future<void> addlabels(Set<String> result) async {
    final updatedLabels = List<Label>.from(_labels!);
    for (var label in result) {
      // await _addLabel(label);
      final labelsNotifier = ref.read(labelsProvider.notifier);
      final existingLabel = await labelsNotifier.getLabelById(label);
      print('$existingLabel existing');
      if (existingLabel != null && !_labels!.contains(existingLabel)) {
        updatedLabels.add(existingLabel);

        setState(() {
          _labels = updatedLabels;
        });
      }
      print('$updatedLabels update');
    }
  }

  /// Updates an existing note or saves a new note if it doesn't exist.
  Future<void> _saveOrUpdateNote() async {
    final updatedNote = widget.note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor.value,
        images: _images,
        reminder: _reminder,
        updatedAt: DateTime.now(),
        labels: _labels);

    // final notesNotifier = ref.read(notesProvider.notifier);
    if (updatedNote.title.isEmpty && updatedNote.content.isEmpty) {
      ref.read(notesProvider.notifier).deleteNoteById(updatedNote.id);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.fixed,
            content: Text('Empty note discarded'),
          ),
        );
      return;
    }
    if (updatedNote.id.isEmpty) {
      await ref.read(notesProvider.notifier).createNote(updatedNote);
    } else {
      ref.read(notesProvider.notifier).updateNote(updatedNote);
    }
  }

  final _imageGridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveOrUpdateNote();
        }
      },
      child: ValueListenableBuilder(
        valueListenable: _selectedColor,
        child: RepaintBoundary(
          key: _imageGridKey,
          child: _images.isNotEmpty
              ? ImageGrid(
                  key: ValueKey(_images.hashCode),
                  images: _images,
                )
              : FutureBuilder<List<NoteImage>>(
                  future: _loadImages(), // This uses the caching system
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final images = snapshot.data ?? [];
                      return ImageGrid(
                        key: ValueKey(images.hashCode),
                        images: images,
                      );
                    }
                    return const CircularProgressIndicator.adaptive();
                  },
                ),
        ),
        builder: (context, selectedColor, imageGrid) {
          return Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: selectedColor!.getThemeAwareColor(ref),
              leading: IconButton(
                tooltip: 'Navigate back',
                icon: const Icon(
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
                  icon: const Icon(
                    Icons.add_alert_outlined,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            body: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selectedColor.getThemeAwareColor(ref),
                ),
                child: Hero(
                  tag: widget.note.id,
                  child: Material(
                    type: MaterialType.transparency,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  imageGrid!,
                                  // StaggeredGrid.count(
                                  //   crossAxisCount: 3,
                                  //   mainAxisSpacing: 4,
                                  //   crossAxisSpacing: 4,
                                  //   children: const [
                                  //     StaggeredGridTile.count(
                                  //       crossAxisCellCount: 2,
                                  //       mainAxisCellCount: 2,
                                  //       child: Text('0'),
                                  //     ),
                                  //     StaggeredGridTile.count(
                                  //       crossAxisCellCount: 2,
                                  //       mainAxisCellCount: 1,
                                  //       child: Text('1'),
                                  //     ),
                                  //     StaggeredGridTile.count(
                                  //       crossAxisCellCount: 1,
                                  //       mainAxisCellCount: 1,
                                  //       child: Text('2'),
                                  //     ),
                                  //     StaggeredGridTile.count(
                                  //       crossAxisCellCount: 1,
                                  //       mainAxisCellCount: 1,
                                  //       child: Text('3'),
                                  //     ),
                                  //     StaggeredGridTile.count(
                                  //       crossAxisCellCount: 4,
                                  //       mainAxisCellCount: 2,
                                  //       child: Text('4'),
                                  //     ),
                                  //   ],
                                  // ),
                                  // ImageGrid(images: _images),
                                  // MasonryGridView.count(
                                  //   shrinkWrap: true,
                                  //   physics: NeverScrollableScrollPhysics(),
                                  //   crossAxisCount: 3,
                                  //   mainAxisSpacing: 4,
                                  //   crossAxisSpacing: 4,
                                  //   itemCount: _images.length,
                                  //   itemBuilder: (context, index) {
                                  //     if (index == 0) {
                                  //       return Container(
                                  //         decoration: ShapeDecoration(
                                  //           shape: RoundedRectangleBorder(
                                  //             side: BorderSide(
                                  //               color: Color(0xFF5f6368),
                                  //               width: 1.5,
                                  //             ),
                                  //             borderRadius: BorderRadius.circular(8),
                                  //           ),
                                  //         ),
                                  //         child: Image.memory(
                                  //           Uint8List.fromList(_images[index].imageData),
                                  //           fit: BoxFit.cover,
                                  //           height:
                                  //               200, // Adjust the height for the first large image
                                  //         ),
                                  //       );
                                  //     } else {
                                  //       return Container(
                                  //         decoration: ShapeDecoration(
                                  //           shape: RoundedRectangleBorder(
                                  //             side: BorderSide(
                                  //               color: Color(0xFF5f6368),
                                  //               width: 1.5,
                                  //             ),
                                  //             borderRadius: BorderRadius.circular(8),
                                  //           ),
                                  //         ),
                                  //         child: Image.memory(
                                  //           Uint8List.fromList(_images[index].imageData),
                                  //           fit: BoxFit.cover,
                                  //           height:
                                  //               100, // Adjust the height for smaller images
                                  //         ),
                                  //       );
                                  //     }
                                  //   },
                                  // ),
                                  // StaggeredGrid.count(
                                  //   crossAxisCount: 3,
                                  //   mainAxisSpacing: 4,
                                  //   crossAxisSpacing: 4,
                                  //   children: _images.asMap().entries.map((entry) {
                                  //     int index = entry.key;
                                  //     NoteImage image = entry.value;
                                  //     var imgblob = Image.memory(
                                  //         Uint8List.fromList(image.imageData),
                                  //         fit: BoxFit.cover);
                                  //     return StaggeredGridTile.count(
                                  //       crossAxisCellCount: (index % 3 == 0) ? 3 : 1,
                                  //       mainAxisCellCount: (index % 3 == 0) ? 2 : 1,
                                  //       child: AspectRatio(
                                  //         aspectRatio:
                                  //             (imgblob.width ?? 1) / (imgblob.height ?? 1),
                                  //         child: Image.memory(
                                  //           Uint8List.fromList(image.imageData),
                                  //           fit: BoxFit.cover,
                                  //         ),
                                  //       ),
                                  //     );
                                  //   }).toList(),
                                  // ),

                                  // GridView.custom(
                                  //   shrinkWrap: true,
                                  //   physics: NeverScrollableScrollPhysics(),
                                  //   gridDelegate: SliverQuiltedGridDelegate(
                                  //     crossAxisCount: 4,
                                  //     mainAxisSpacing: 4,
                                  //     crossAxisSpacing: 4,
                                  //     repeatPattern: QuiltedGridRepeatPattern.inverted,
                                  //     pattern: [
                                  //       QuiltedGridTile(2, 2),
                                  //       QuiltedGridTile(1, 1),
                                  //       QuiltedGridTile(1, 1),
                                  //       QuiltedGridTile(1, 2),
                                  //     ],
                                  //   ),
                                  //   childrenDelegate: SliverChildBuilderDelegate(
                                  //     (context, index) => Text('$index'),
                                  //   ),
                                  // ),
                                  TextField(
                                    controller: _titleController,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                    showCursor: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom !=
                                        0,
                                    decoration: const InputDecoration(
                                      hintText: 'Title',
                                      border: InputBorder.none,
                                    ),
                                    maxLines: null,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },
                                      child: TextField(
                                        controller: _contentController,
                                        showCursor: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom !=
                                            0,
                                        decoration: const InputDecoration(
                                          hintText: 'Note',
                                          border: InputBorder.none,
                                        ),
                                        maxLines: null,
                                        expands: true,
                                      ),
                                    ),
                                  ),
                                  if (_labels!.isNotEmpty)
                                    NoteLabels(labels: _labels ?? []),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )),
            floatingActionButton: kDebugMode
                ? FloatingActionButton(
                    onPressed: () {
                      debugPaintSizeEnabled = !debugPaintSizeEnabled;
                    },
                    child: const Icon(Icons.bug_report),
                  )
                : null,
            bottomNavigationBar: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: BottomAppBar(
                padding: EdgeInsets.zero,
                color: selectedColor.getThemeAwareColor(ref),
                // height: kBottomNavigationBarHeight +
                //     MediaQuery.of(context).viewInsets.bottom,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                  margin: const EdgeInsets.all(0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.color_lens),
                        onPressed: () => _showColorPicker(),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 1.8,
                        child: Text(
                          'Edited ${_dateFormat.format(widget.note.updatedAt)}',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          _showBottomDrawer(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  const ImageGrid({
    super.key,
    required this.images,
  });

  final List<NoteImage> images;

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: [
        if (images.isNotEmpty)
          StaggeredGridTile.extent(
            crossAxisCellCount: 2,
            mainAxisExtent: 200,
            child: Image.memory(Uint8List.fromList(images[0].imageData),
                fit: BoxFit.cover),
          ),
        if (images.length > 1)
          StaggeredGridTile.extent(
            crossAxisCellCount: 2,
            mainAxisExtent: 200,
            child: Image.memory(Uint8List.fromList(images[1].imageData),
                fit: BoxFit.cover),
          ),
        for (int i = 2; i < images.length; i++)
          StaggeredGridTile.extent(
            crossAxisCellCount: (i % 3 == 0) ? 2 : 1,
            mainAxisExtent: 100,
            child: Image.memory(Uint8List.fromList(images[i].imageData),
                fit: BoxFit.cover),
          ),
      ],
    );
  }
}

//a widget that displays the labels of a note
class NoteLabels extends StatelessWidget {
  final List<Label> labels;

  const NoteLabels({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(2),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.name,
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
