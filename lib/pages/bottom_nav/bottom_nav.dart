import 'package:flutter/material.dart';
import '../homepage.dart';
import '../swipe_page.dart';
import '../profile_page.dart';
import '../chats_list_page.dart';


class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  void switchTab(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pages list - instantiate Homepage and pass callback
    final pages = [
      Homepage(onNavigate: switchTab), // pass callback to allow homepage cards to switch tabs
      const ChatsListPage(),
      const SwipePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: switchTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
