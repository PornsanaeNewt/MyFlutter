import 'package:flutter/material.dart';

class CustomDrawerbar extends StatelessWidget {
  const CustomDrawerbar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: Center(
        child: Text('Instagram Menu Content'),
      ),
    );
  }
}
