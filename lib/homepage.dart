import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/presentation/notes_provider.dart';
import 'package:notes/presentation/screens/note_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final notesNotifier = ref.read(notesProvider.notifier);
    final notesState = ref.read(notesProvider);
    final List<Note> notes = ref.watch(notesProvider).where((note) {
      return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    print(searchQuery);
    // print(notes.length);
    if (notesState.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notes', style: GoogleFonts.comfortaa(fontSize: 25)),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: _toggleSearchBar,
            ),
          ],
        ),
        body: Center(
          child: Text(
            'No notes available',
            style: GoogleFonts.comfortaa(fontSize: 18),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add new note action
            String title = '';
            String content = '';
            final newnote = notesNotifier.createNote(title, content);
            print(newnote);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteScreen(note: newnote),
                ));
          },
          child: Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
        // backgroundColor: Colors.deepPurple,
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              // debugPaintSizeEnabled = !debugPaintSizeEnabled;
              String title = '';
              String content = '';
              final newnote = notesNotifier.createNote(title, content);
              print(newnote);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteScreen(note: newnote),
                  ));
            },
            child: const Icon(Icons.add)),
        body: SafeArea(
            minimum: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: CustomScrollView(slivers: [
              // SliverPersistentHeader(
              //   delegate: SliverSearchAppBar(),
              //   // pinned: true,
              // ),
              notesSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: notes.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No notes available',
                            style: GoogleFonts.comfortaa(fontSize: 18),
                          ),
                        ),
                      )
                    : NoteSliverMasonryGrid(
                        notes: notes,
                        selectedGrids: selectedGrids,
                        onSelect: onSelect,
                      ),
              ),
              // SliverList(
              //   delegate: SliverChildBuilderDelegate((context, index) {
              //     // return
              //     return Container(
              //         margin: const EdgeInsets.all(10),
              //         padding: const EdgeInsets.all(15),
              //         decoration: ShapeDecoration(
              //             gradient: const LinearGradient(colors: [
              //               Color(0xFFFF4286),
              //               Color(0xFFFF6666),
              //             ]),
              //             shape: SmoothRectangleBorder(
              //
              //     borderAlign: BorderAlign.outside,
              //                 borderRadius: SmoothBorderRadius(
              //                     cornerRadius: 16, cornerSmoothing: 0))),
              //         child: const Padding(
              //             padding: EdgeInsets.all(12.0),
              //             child: const Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [Text('data')])));
              //   }),
              // ),
            ])));
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
                    setState(() {
                      selectedGrids.clear();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.color_lens),
                  onPressed: () {
                    // ref.read(notesProvider.notifier).archiveNotes(selectedGrids);
                    // setState(() {
                    //   selectedGrids.clear();
                    // });
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
                // shape: ShapeBorder.lerp(
                //     const RoundedRectangleBorder(
                //         borderRadius: BorderRadius.only(
                //             bottomLeft: Radius.circular(20),
                //             bottomRight: Radius.circular(20))),
                //     const RoundedRectangleBorder(
                //         borderRadius: BorderRadius.only(
                //             bottomLeft: Radius.circular(20),
                //             bottomRight: Radius.circular(20))),
                //     0.5),
                // flexibleSpace: LayoutBuilder(
                //   builder: (BuildContext context, BoxConstraints constraints) {
                //     // Calculate the opacity based on scroll position
                //     double top = constraints.biggest.height;
                //     double opacity =
                //         (top - kToolbarHeight) / (200 - kToolbarHeight);

                //     return FlexibleSpaceBar(
                //       centerTitle: true,
                //       title: Opacity(
                //         opacity: opacity.clamp(0.0, 1.0),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: const [
                //             Text(
                //               "Notes",
                //               style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 16,
                //               ),
                //             ),
                //             Icon(
                //               Icons.search,
                //               color: Colors.white,
                //             ),
                //           ],
                //         ),
                //       ),
                //       background: Container(
                //         decoration: const BoxDecoration(
                //           gradient: LinearGradient(
                //             colors: [Color(0xFF607D8B), Color(0xFF455A64)],
                //             begin: Alignment.topCenter,
                //             end: Alignment.bottomCenter,
                //           ),
                //         ),
                //         child: const Center(
                //           child: Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Icon(
                //                 Icons.pets,
                //                 size: 80,
                //                 color: Colors.white,
                //               ),
                //               SizedBox(height: 8),
                //               Text(
                //                 "Start brand search",
                //                 style: TextStyle(
                //                     color: Colors.white, fontSize: 20),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                // leading: _isSearchBarVisible
                //     ? BackButton(onPressed: _toggleSearchBar)
                //     : null,
                //remove unnecassary customsearch
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
                              fontSize: 25,
                            ),
                          ),
                        ),
                ),
                actions: _isSearchBarVisible
                    ? []
                    : [
                        Container(
                          // padding: const EdgeInsets.all(10),
                          // margin: const EdgeInsets.symmetric(
                          //     horizontal: 10, vertical: 10),
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

class NoteSliverMasonryGrid extends StatelessWidget {
  final List<Note> notes;
  final List<String> selectedGrids;
  final Function(String) onSelect;

  const NoteSliverMasonryGrid(
      {super.key,
      required this.notes,
      required this.selectedGrids,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      // crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 12,
      // childCount: 20,
      delegate: SliverChildBuilderDelegate(
        childCount: notes.length,
        (BuildContext context, int index) {
          var id = notes[index].id;
          final isSelected = selectedGrids.contains(id);

          return InkWell(
            enableFeedback: true,
            onTap: () {
              if (selectedGrids.isNotEmpty) {
                onSelect(id);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteScreen(note: notes[index]),
                  ),
                );
              }
            },
            onLongPress: () {
              print("Long pressed");
              print(selectedGrids);
              onSelect(id);
            },
            // splashColor: Colors.grey, // splash color
            child: Ink(
              child: GridTile(
                child: Container(
                  // margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  // padding: EdgeInsets.all(isSelected ? 1 : 0),

                  decoration: ShapeDecoration(
                      // gradient: const LinearGradient(colors: [
                      //   Color(0xFFFF4286),
                      //   Color(0xFFFF6666),
                      // ]),
                      // color: _getNoteColor(index),
                      // color: Color(0xff77172e),
                      color: notes[index].color ?? Color(0xFF5f6368),
                      // color: Colors.red.withOpacity(0.75),
                      shape: SmoothRectangleBorder(
                          side: BorderSide(
                            color: isSelected
                                ? Colors.grey
                                : notes[index].color ?? Color(0xFF5f6368),
                            width: isSelected ? 2 : 0,
                          ),
                          borderAlign: BorderAlign.inside,
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 0))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notes[index].title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            // color: Color(0xFFe8eaed)
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          notes[index].content,
                          style:
                              TextStyle(fontSize: 16, color: Color(0xFFe8eaed)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 12,
                        ),
                      ],
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
            // onTap: () {
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => NoteWidget(
            //                   note: Note(
            //                 id: "1",
            //                 title: "Note 1",
            //                 content: "Note content",
            //                 color: "blue",
            //                 createdAt: DateTime.now(),
            //                 updatedAt: DateTime.now(),
            //                 todos: [
            //                   Todo(
            //                     id: "1",
            //                     task: "Todo 1",
            //                     completed: false,
            //                   ),
            //                   Todo(
            //                     id: "2",
            //                     task: "Todo 2",
            //                     completed: true,
            //                   ),
            //                 ],
            //               ))));
            // },
          );
        });
  }
}
