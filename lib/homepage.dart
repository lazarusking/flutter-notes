import 'package:flutter/material.dart';
import 'package:notes/main_screen.dart';
import 'package:notes/presentation/screens/manage_labels.dart';
import 'package:notes/widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tabs = <Widget>[const MainScreen(), const ManageLabelsScreen()];
  late PageController _pageController;

  int currentTab = 0;

  void setPage(int page) {
    setState(() {
      currentTab = page;
    });
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 50), curve: Curves.bounceIn);
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: currentTab);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const AppDrawer(),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            scrollBehavior: const MaterialScrollBehavior(),
            children: tabs,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: setPage,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                currentTab == 0
                    ? Icons.sticky_note_2
                    : Icons.sticky_note_2_outlined,
                size: 22,
              ),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentTab == 1 ? Icons.access_time_filled : Icons.access_time,
                size: 22,
              ),
              label: 'Reminders',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentTab == 2 ? Icons.archive : Icons.archive_outlined,
                size: 22,
              ),
              label: 'Archive',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentTab == 3 ? Icons.delete : Icons.delete_outline,
                size: 22,
              ),
              label: 'Trash',
            ),
          ],
        ));
  }
}
