import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/presentation/screens/note_screen.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/providers/theme_provider.dart';
import 'package:notes/utils/helpers.dart';
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

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<MainScreen> {
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
        print('$firstNote ${AsyncValue.data(firstNote)}');
        return Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Container(
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 300),
            child: FutureBuilder<Note?>(
              future: ref
                  .read(notesProvider.notifier)
                  .getNoteById(selectedGrids.first),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Note not found'));
                } else {
                  final note = snapshot.data!;
                  return ColorPicker(
                    isBlockStyle: true,
                    selectedColor: note.color!,
                    onColorSelected: (color) {
                      () async {
                        for (final id in selectedGrids) {
                          final note = await ref
                              .read(notesProvider.notifier)
                              .getNoteById(id);
                          if (note != null) {
                            final updatedNote = note.copyWith(color: color);
                            ref
                                .read(notesProvider.notifier)
                                .updateNote(updatedNote);
                          }
                        }
                        if (context.mounted) {
                          setState(() {
                            selectedGrids.clear();
                            Navigator.of(context).pop();
                          });
                        }
                      }();
                    },
                  );
                }
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
    final notes = ref.watch(notesProvider);
    final filteredNotes =
        ref.read(notesProvider.notifier).searchNotes(searchQuery);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final currentTheme = ref.watch(themeModeProvider);
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
                // backgroundColor: Colors.black,
                // backgroundColor: Theme.of(context).primaryColor,
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
                sliver: notes.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error: $error',
                        style: GoogleFonts.comfortaa(fontSize: 18),
                      ),
                    ),
                  ),
                  data: (notesList) => notesList.isEmpty
                      ?

                      // SliverFillRemaining(
                      //     child: Center(
                      //       child: Text(
                      //         'No notes available',
                      //         style: GoogleFonts.comfortaa(fontSize: 18),
                      //       ),
                      //     ),
                      //   )
                      SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                _buildEmptyState(context),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNoteCard(
                                        context,
                                        'Hiking in Tahoe',
                                        'Winter is coming, pack accordingly',
                                        'assets/tahoe.jpg',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildNoteCard(
                                        context,
                                        'Desert trip',
                                        'Palm Springs here I come',
                                        'assets/desert.jpg',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 8,
                                    // childAspectRatio: 3,
                                    mainAxisExtent: 50,
                                  ),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    final actions = [
                                      (
                                        'New Note',
                                        Icons.add,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NoteScreen(
                                                  note: Note.empty()),
                                            ),
                                          );
                                        },
                                      ),
                                      ('Label', Icons.sell_outlined, () {}),
                                      ('Recording', Icons.mic_none, () {}),
                                      ('Sketch', Icons.image_outlined, () {}),
                                      (
                                        'Snapshot',
                                        Icons.camera_alt_outlined,
                                        () {}
                                      ),
                                      (
                                        'Handwriting',
                                        Icons.edit_outlined,
                                        () {}
                                      ),
                                    ];
                                    return _buildActionButton(actions[index].$1,
                                        actions[index].$2, actions[index].$3);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : NoteSliverMasonryGrid(
                          notes: filteredNotes,
                          selectedGrids: selectedGrids,
                          onSelect: onSelect,
                        ),
                )),
            SliverToBoxAdapter(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose your theme:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildRadioTile(
                  title: "System Default",
                  value: ThemeMode.system,
                  groupValue: currentTheme,
                  onChanged: themeNotifier.setThemeMode,
                ),
                _buildRadioTile(
                  title: "Light Mode",
                  value: ThemeMode.light,
                  groupValue: currentTheme,
                  onChanged: themeNotifier.setThemeMode,
                ),
                _buildRadioTile(
                  title: "Dark Mode",
                  value: ThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: themeNotifier.setThemeMode,
                ),
              ],
            ))
          ]))),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required Function(ThemeMode) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      leading: Radio<ThemeMode>(
        value: value,
        groupValue: groupValue,
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  SliverPadding notesSliverAppBar(BuildContext context) {
    return selectedGrids.isNotEmpty
        ? SliverPadding(
            padding: const EdgeInsets.only(top: 2),
            sliver: SliverAppBar(
              automaticallyImplyLeading: false,
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
                automaticallyImplyLeading: false,
                // snap: true,
                // toolbarHeight: 100,
                expandedHeight: kToolbarHeight + 10,
                // collapsedHeight: 120,
                // floating: true,
                // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                            style: GoogleFonts.comfortaa(fontSize: 25),
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
                              )),
                        )
                      ]),
          );
  }

  Widget _buildNoteCard(
      BuildContext context, String title, String subtitle, String imagePath) {
    Future<List<int>> loadAssetImageBytes(String path) async {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    }

    return InkWell(
      onTap: () async {
        final imageData = await loadAssetImageBytes(imagePath);
        if (!context.mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteScreen(
                  note: Note.empty().copyWith(
                title: title,
                content: subtitle,
                images: [NoteImage(id: '', noteId: '', imageData: imageData)],
                color: Colors.transparent,
              )),
            ));
      },
      child: Container(
        // padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
                side: BorderSide(
                  color: Colors.grey.shade500,
                  width: 1.2,
                ),
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CircleAvatar(
            //   radius: 24,
            //   backgroundImage: AssetImage(imagePath),
            // ),
            // if (note.images.isNotEmpty)
            ClipSmoothRect(
              radius: const SmoothBorderRadius.only(
                  topLeft: SmoothRadius(
                    cornerRadius: 8,
                    cornerSmoothing: 0,
                  ),
                  topRight: SmoothRadius(
                    cornerRadius: 8,
                    cornerSmoothing: 0,
                  )),
              // borderRadius: SmoothBorderRadius(
              //     cornerRadius: 10, cornerSmoothing: 0),
              child: SizedBox(
                height: 100,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Helpers.calculateCrossAxisCount(1),
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    // final image = imagePath;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              // padding: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                splashColor: note.color!.getThemeAwareColor(ref),
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
                  print(widget.selectedGrids);
                  widget.onSelect(id);
                },
                child: Ink(
                  // padding:
                  //     const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
                  decoration: ShapeDecoration(
                      color: note.color!.getThemeAwareColor(ref),
                      shape: SmoothRectangleBorder(
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context)
                                    .floatingActionButtonTheme
                                    .backgroundColor!
                                : note.color!.getThemeAwareColor(ref) ==
                                        transparent
                                    ? Theme.of(context).hintColor
                                    : note.color!.getThemeAwareColor(ref),
                            width: 0,
                          ),
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 0))),
                  child: Transform.scale(
                    scale: isSelected ? 1.009 : 1.0,
                    child: GridTile(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.images.isNotEmpty)
                              ClipSmoothRect(
                                radius: const SmoothBorderRadius.only(
                                    topLeft: SmoothRadius(
                                      cornerRadius: 8,
                                      cornerSmoothing: 0,
                                    ),
                                    topRight: SmoothRadius(
                                      cornerRadius: 8,
                                      cornerSmoothing: 0,
                                    )),
                                // borderRadius: SmoothBorderRadius(
                                //     cornerRadius: 10, cornerSmoothing: 0),
                                child: SizedBox(
                                  height: 100,
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          Helpers.calculateCrossAxisCount(
                                              note.images.length),
                                      mainAxisSpacing: 4,
                                      crossAxisSpacing: 4,
                                      childAspectRatio: 1.5,
                                    ),
                                    itemCount: note.images.length,
                                    itemBuilder: (context, index) {
                                      final image = note.images[index];
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.memory(
                                          Uint8List.fromList(image.imageData),
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
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
                                      // style: const TextStyle(
                                      //     fontSize: 15, color: Color(0xFFe8eaed)),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 15,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 12,
                                    ),
                                  ]),
                            )
                          ],
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

Widget _buildEmptyState(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      // color: Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.note_add,
          size: 48,
          color: Colors.blueGrey[200],
        ),
        const SizedBox(height: 16),
        const Text(
          'No notes yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            // color: Colors.grey[800],
            // color: Theme.of(context).primaryColor
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start creating your first note or open one of the samples.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              // color: Colors.grey[600],
              color: Theme.of(context).textTheme.bodySmall!.color),
        ),
      ],
    ),
  );
}

Widget _buildActionButton(String label, IconData icon, Function onTap) {
  return Container(
    decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
            side: BorderSide(
              color: Colors.grey.shade500,
              // width: 2,
            ),
            borderRadius:
                SmoothBorderRadius(cornerRadius: 5, cornerSmoothing: 0))),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        // borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
