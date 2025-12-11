import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/app_config.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/screen/widgets/profile_circle.dart';
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
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Obx(() {
        final user = userController.userProfile.value?.data;
        if (user == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading profile..."),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Column(
              children: [
                ProfileCircle(imageUrl: user.profileUrl),
                const SizedBox(height: 16),
                Text(
                  user.name ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? 'No Email',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Text(
                  '${AppConfig.env}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 32),
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
        );
      }),
    );
  }
}
