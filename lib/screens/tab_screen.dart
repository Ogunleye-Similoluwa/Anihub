import 'package:anihub/config/styles.dart';
import 'package:anihub/screens/favourites_screen.dart';
import 'package:anihub/screens/home_page.dart';
import 'package:anihub/screens/search_screen.dart';
import 'package:anihub/screens/watching_screen.dart';
import 'package:anihub/screens/manga_screen.dart';
import 'package:anihub/screens/recent_screen.dart';
import 'package:flutter/material.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _currentIndex = 0;
  final pageController = PageController(initialPage: 0);
  
  final List<Widget> _pages = [
    const HomePage(),
    const SearchScreen(),
    const MangaScreen(),
    // const WatchingScreen(),
    // const RecentScreen(),
    const FavouritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          padding: const EdgeInsets.only(right: 12, left: 12, top: 25),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "anihub",
                style: TextStyles.appbarStyle,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.red,
                  size: 28,
                )
              )
            ],
          ),
        ),
      ),
      body: PageView(
        children: _pages,
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          pageController.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Manga',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.play_circle_outline),
          //   selectedIcon: Icon(Icons.play_circle),
          //   label: 'Watching',
          // ),
          // NavigationDestination(
          //   icon: Icon(Icons.history_outlined),
          //   selectedIcon: Icon(Icons.history),
          //   label: 'Recent',
          // ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
} 