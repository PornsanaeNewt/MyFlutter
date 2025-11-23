import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/routes/app_route.dart';
import 'package:flutter_app_test1/screen/widgets/custom_drawerbar.dart';
import 'package:flutter_app_test1/screen/home/widgets/list_chat_widget.dart';
import 'package:flutter_app_test1/screen/home/widgets/list_friend_widget.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class friend {
  final String name;
  final String lname;
  friend({required this.name, required this.lname});
}

final List<friend> friends = [
  friend(name: 'Miyamura', lname: 'Izumi'),
  friend(name: 'Hori', lname: 'Kyoko'),
  friend(name: 'Shoya', lname: 'Ishida'),
  friend(name: 'Nishimiya', lname: 'Shoko'),
  friend(name: 'Hayasaka', lname: 'Akito'),
  friend(name: 'Sakurai', lname: 'Haruna'),
  friend(name: 'Shokuho', lname: 'Misaki'),
  friend(name: 'Kamijo', lname: 'Toma'),
];

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawerbar(),
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: <Widget>[
          Builder(
            builder: (BuildContext innerContext) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(innerContext).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    GoRouter.of(context).pushNamed(AppRoute.profile);
                  },
                  child: CircleAvatar(
                  radius: 30.0,
                ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Chats',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 200),
                const Icon(Icons.camera_alt_outlined, size: 28),
                const SizedBox(width: 16),
                const Icon(Icons.edit, size: 28),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListFriendWidget(
                    name: friend.name,
                    lname: friend.lname,
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListChatWidget(name: friend.name, lname: friend.lname);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
