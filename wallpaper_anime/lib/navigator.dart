import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

import 'package:flutter/material.dart';
import 'package:wallpaper_anime/chanel1.dart';
import 'package:wallpaper_anime/chanel2.dart';

class navigator extends StatefulWidget {
  const navigator({super.key});

  @override
  State<navigator> createState() => _navigatorState();
}

class _navigatorState extends State<navigator> {
  //State class
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController(initialPage: _currentIndex, keepPage: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> tabItems = [chanell1(), chanel2()];
  final iconList = <IconData>[
    Icons.brightness_5,
    Icons.brightness_4,
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: false,
        body: tabItems[_currentIndex],
        bottomNavigationBar: FlashyTabBar(
          selectedIndex: _currentIndex,
          showElevation: true,
          onItemSelected: (index) => setState(() {
            print(index);
            _currentIndex = index;
          }),
          items: [
            FlashyTabBarItem(
              icon: Icon(
                Icons.pie_chart,
                color: Color(0xFFFF69B4),
              ),
              title: Text(
                'Image & Gif',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            FlashyTabBarItem(
              icon: Icon(
                Icons.now_wallpaper,
                color: Color(0xFFFF69B4),
              ),
              title: Text(
                'Walpaper',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
