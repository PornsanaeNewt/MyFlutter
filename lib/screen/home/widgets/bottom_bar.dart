import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  static const _radiusBorderMenu = 16.0;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final List<Widget> pages = [
    Center(child: Text('Home')),
    Center(child: Text('Profile')),
  ];
  int currentIndex = 0; 

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(BottomBar._radiusBorderMenu),
        topRight: Radius.circular(BottomBar._radiusBorderMenu),
      ),
      child: BottomAppBar(
        elevation: 0,
        notchMargin: 8,
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        child: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}