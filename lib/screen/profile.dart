import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final String name;
  const Profile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            child: Center(
              child: Text(
                'Profile',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome, $name!',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
