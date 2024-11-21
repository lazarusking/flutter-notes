import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/presentation/screens/note_screen.dart';
import 'package:notes/widgets/color_picker.dart';
import 'package:notes/widgets/search_bar.dart';

final _tileCounts = [
  [2, 2],
  [2, 2],
  [4, 2],
  [2, 3],
  [2, 2],
  [2, 3],
  [2, 2],
];

//unused
class SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var adjustedShrinkOffset =
        shrinkOffset > minExtent ? minExtent : shrinkOffset;
    // double offset = (minExtent - adjustedShrinkOffset) * 0.5;
    double centerOffset = (maxExtent - adjustedShrinkOffset) * 0.5;
    double topPadding = MediaQuery.of(context).padding.top + 16;
    return Stack(
      children: [
        SizedBox(
          child: ClipPath(
              clipper: BackgroundWaveClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 280,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  // colors: [Color(0xFFFACCCC), Color(0xFFF6EFE9)],
                  colors: [Color(0xFF607D8B), Color(0xFF455A64)],
                )),
              )),
        ),
        Positioned(
            top: topPadding + centerOffset * 0.5,
            left: 16,
            right: 16,
            child: CustomSearchBar(onCancel: () {})),
      ],
    );
  }

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent;
}

class BackgroundWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    const minSize = 100.0;

    // when h = max = 280
    // h = 280, p1 = 210, p1Diff = 70
    // when h = min = 140
    // h = 140, p1 = 140, p1Diff = 0
    final p1Diff = ((minSize - size.height) * 0.5).truncate().abs();
    path.lineTo(0.0, size.height - p1Diff);

    final controlPoint = Offset(size.width * 0.4, size.height);
    final endPoint = Offset(size.width, minSize);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(BackgroundWaveClipper oldClipper) => oldClipper != this;
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isSearchBarVisible = false;
  final List<String> selectedGrids = [];

  void onSelect(String id) {
    setState(() {
      if (selectedGrids.contains(id)) {
        selectedGrids.remove(id);
      } else {
        selectedGrids.add(id);
      }
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearchBarVisible = !_isSearchBarVisible;
      // if (_isSearchBarVisible) {
      //   Navigator.push(
      //       context,
      //       PageRouteBuilder(
      //           barrierDismissible: true,
      //           opaque: false,
      //           pageBuilder: (_, anim1, anim2) => const HomePage(),
      //           settings: RouteSettings(arguments: _isSearchBarVisible)));
      // } else {
      //   Navigator.pop(context);
      // }
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  // Color _getNoteColor(int index) {
  //   final colors = [
  //     Colors.orange[100],
  //     Colors.yellow[100],
  //     Colors.green[100],
  //     Colors.blue[100],
  //     Colors.purple[100],
  //     Colors.pink[100]
  //   ];
  //   return colors[index % colors.length]!;
  // }

  // Color _getThemeColor(BuildContext context) {
  //   return Theme.of(context).primaryColor;
  // }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      FlutterNativeSplash.remove();
    });
  }

  void _showColorPicker() {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        final firstNote =
            ref.read(notesProvider.notifier).getNoteById(selectedGrids.first);
        return Dialog(
          backgroundColor: switch (firstNote) {
            AsyncData(:Note value) => value.color,
            AsyncError() => null,
            _ => Colors.transparent,
          },
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Container(
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 300),
            child: ColorPicker(
              isBlockStyle: true,
              selectedColor: Colors.transparent,
              onColorSelected: (color) {
                setState(() async {
                  for (final id in selectedGrids) {
                    final note =
                        await ref.read(notesProvider.notifier).getNoteById(id);
                    if (note != null) {
                      final updatedNote = note.copyWith(color: color);
                      ref.read(notesProvider.notifier).updateNote(updatedNote);
                    }
                  }
                  selectedGrids.clear();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final List<Note> notes = ref.watch(notesProvider);
    final filteredNotes =
        ref.read(notesProvider.notifier).searchNotes(searchQuery);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _isSearchBarVisible) {
          _toggleSearchBar();
          setState(() {
            selectedGrids.clear();
          });
        }
      },
      child: Scaffold(
          // backgroundColor: Colors.deepPurple,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 30.0, right: 0),
            child: FloatingActionButton(
                backgroundColor: Colors.black,
                shape: const CircleBorder(),
                onPressed: () {
                  if (kDebugMode) {
                    debugPaintSizeEnabled = !debugPaintSizeEnabled;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteScreen(note: Note.empty()),
                      ));
                },
                child: const Icon(Icons.add, color: Colors.white)),
          ),
          body: SafeArea(
              // minimum: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: CustomScrollView(slivers: [
            // SliverPersistentHeader(
            //   delegate: SliverSearchAppBar(),
            //   // pinned: true,
            // ),
            notesSliverAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: notes.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No notes available',
                          style: GoogleFonts.comfortaa(fontSize: 18),
                        ),
                      ),
                    )
                  : NoteSliverMasonryGrid(
                      notes: filteredNotes,
                      selectedGrids: selectedGrids,
                      onSelect: onSelect,
                    ),
            ),
          ]))),
    );
  }

  SliverPadding notesSliverAppBar(BuildContext context) {
    return selectedGrids.isNotEmpty
        ? SliverPadding(
            padding: const EdgeInsets.only(top: 2),
            sliver: SliverAppBar(
              expandedHeight: kToolbarHeight + 10,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              title: Text(
                "${selectedGrids.length}",
                style: GoogleFonts.comfortaa(fontSize: 18),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // ref.read(notesProvider.notifier).deleteNoteById(selectedGrids);
                  setState(() {
                    selectedGrids.clear();
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    for (final id in selectedGrids) {
                      ref.read(notesProvider.notifier).deleteNoteById(id);
                    }
                    // ref.read(notesProvider.notifier).deleteNoteById(selectedGrids);
                    setState(() {
                      selectedGrids.clear();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.archive),
                  onPressed: () {
                    // ref
                    //     .read(notesProvider.notifier)
                    //     .archiveNotes(selectedGrids);
                    // setState(() {
                    //   selectedGrids.clear();
                    // });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.color_lens),
                  onPressed: () {
                    _showColorPicker();
                  },
                ),
              ],
            ),
          )
        : SliverPadding(
            padding: const EdgeInsets.only(top: 2),
            sliver: SliverAppBar(
                // snap: true,
                // toolbarHeight: 100,
                expandedHeight: kToolbarHeight + 10,
                // collapsedHeight: 120,
                // floating: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                // backgroundColor: Colors.black45,
                pinned: true,
                title: AnimatedSwitcher(
                  // key: const ValueKey('title'),
                  // switchInCurve: Curves.bounceIn,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation =
                        Tween(begin: const Offset(.0, 1.0), end: Offset.zero)
                            .animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  duration: const Duration(milliseconds: 300),
                  child: _isSearchBarVisible
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: CustomSearchBar(onCancel: _toggleSearchBar))
                      : SizedBox(
                          width: double.infinity,
                          child: Text(
                            "notes",
                            textAlign: TextAlign.left,
                            key: const ValueKey('title'),
                            style: GoogleFonts.comfortaa(
                                fontSize: 25, color: Colors.white),
                          ),
                        ),
                ),
                actions: _isSearchBarVisible
                    ? []
                    : [
                        Container(
                          // padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          // decoration: BoxDecoration(
                          //     color: Colors.white.withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _toggleSearchBar();
                              },
                              icon: const Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.white,
                              )),
                        )
                      ]),
          );
  }
}

class NoteSliverMasonryGrid extends ConsumerStatefulWidget {
  final List<Note> notes;
  final List<String> selectedGrids;
  final Function(String) onSelect;

  const NoteSliverMasonryGrid(
      {super.key,
      required this.notes,
      required this.selectedGrids,
      required this.onSelect});

  @override
  ConsumerState<NoteSliverMasonryGrid> createState() =>
      _NoteSliverMasonryGridState();
}

class _NoteSliverMasonryGridState extends ConsumerState<NoteSliverMasonryGrid> {
  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 9,
      crossAxisSpacing: 10,
      delegate: SliverChildBuilderDelegate(
        childCount: widget.notes.length,
        (BuildContext context, int index) {
          final note = widget.notes[index];
          final id = note.id;
          final isSelected = widget.selectedGrids.contains(id);

          return Hero(
            tag: note.id,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                enableFeedback: true,
                splashColor: note.color,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(9)),
                onTap: () async {
                  if (widget.selectedGrids.isNotEmpty) {
                    widget.onSelect(id);
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteScreen(note: note),
                      ),
                    );
                    int originalPosition = index; // Store the original position

                    if (result is Note) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: const Text('Note deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                ref.read(notesProvider.notifier).createNote(
                                    result,
                                    position: originalPosition);
                              },
                            ),
                          ),
                        );
                    }
                  }
                },
                onLongPress: () {
                  print("Long pressed");
                  print(widget.selectedGrids);
                  widget.onSelect(id);
                },
                child: Ink(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
                  decoration: ShapeDecoration(
                      color: note.color,
                      shape: SmoothRectangleBorder(
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFD2D4D7)
                                : note.color == defaultColor
                                    ? const Color(0xFF5f6368)
                                    : note.color ?? defaultColor,
                            width: 2,
                          ),
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 0))),
                  child: Transform.scale(
                    scale: isSelected ? 1.009 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: GridTile(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                note.content,
                                style: const TextStyle(
                                    fontSize: 15, color: Color(0xFFe8eaed)),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class NotesMasonry extends StatelessWidget {
  const NotesMasonry({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: 20,
        itemBuilder: (context, index) {
          return GridTile(
            // header: Text("Note $index"),
            // footer: const Text("Note content"),
            child: Container(
              // color: Colors.red,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              decoration: ShapeDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFFFF4286),
                    Color(0xFFFF6666),
                  ]),
                  // color: Colors.red.withOpacity(0.75),
                  shape: SmoothRectangleBorder(
                      // side: const BorderSide(
                      //   color: Colors.blue,
                      //   width: 2,
                      // ),
                      borderAlign: BorderAlign.outside,
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 16, cornerSmoothing: 0))),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index % 2 == 0) ...const [
                      Text(
                        "Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1Note 1",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Note content",
                        style: TextStyle(fontSize: 16),
                      ),
                    ] else ...[
                      Text(
                        "Note $index",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Short content",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        });
  }
}
