import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/app_config.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/screen/widgets/profile_circle.dart';
import 'package:get/get.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
      return Column(
        children: [
          ProfileCircle(
            imageUrl: userController.userProfile.value?.data?.profileUrl,
          ),
          const SizedBox(height: 16),
          Text(
            userController.userProfile.value?.data?.name ?? 'No Name',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            userController.userProfile.value?.data?.email ?? 'No Email',
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
      );
    });
  }
}
