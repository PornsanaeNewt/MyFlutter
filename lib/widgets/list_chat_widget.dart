import 'package:flutter/material.dart';

class ListChatWidget extends StatelessWidget {
  final String name;
  final String lname;

  const ListChatWidget({
    required this.name,
    required this.lname,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
      ),

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$name $lname',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      
      trailing: const Icon(Icons.check_circle_outline, size: 18, color: Colors.grey),
      
      onTap: () {
        // 
      },
    );
  }

}