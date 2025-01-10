import 'package:anihub/config/styles.dart';
import 'package:anihub/screens/favourites_screen.dart';
import 'package:anihub/screens/home_page.dart';
import 'package:anihub/screens/search_screen.dart';
import 'package:flutter/material.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _currentIndex = 0;
  final pageController = PageController(initialPage: 0);
  static final List<Widget> _pages = [
    const HomePage(),
    const SearchScreen(),
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
                      ))
                ],
              ),
            )),
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (val) {
            pageController.jumpToPage(val);
            setState(() {
              _currentIndex = val;
            });
          },
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.explore), label: "Explore"),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_rounded), label: "My List"),
          ],
        ));
  }
}
