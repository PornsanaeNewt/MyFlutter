import 'package:flutter/material.dart';

class ListFriendWidget extends StatelessWidget {
  final String name;
  final String lname;

  const ListFriendWidget({
    required this.name,
    required this.lname,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: <Widget>[
          CircleAvatar(
            radius: 30,
          ),
          const SizedBox(height: 4), 
          Text(
            name,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis, 
          ),
        ],
      ),
    );
  }
}