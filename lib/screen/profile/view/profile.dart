import 'package:flutter/material.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/screen/profile/widgets/profile_details.dart';
import 'package:flutter_app_test1/service/auth.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> logout() async {
    await Auth().logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ProfileDetails(),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to edit profile page
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text(
              'Log Out',
              style: TextStyle(color: Colors.red.shade700),
            ),
            onTap: logout,
          ),
        ],
      ),
    );
  }
}
