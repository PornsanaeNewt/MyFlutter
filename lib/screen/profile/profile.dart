import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/routes/app_route.dart';
import 'package:flutter_app_test1/model/user_profile.dart';
import 'package:flutter_app_test1/service/dudee_service.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {

  Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
   UserProfile? userProfile;
  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    await Future.delayed(const Duration(seconds: 2));
    userProfile = await DudeeService().getUserProfile();
    setState(() {
      
    });
  }

  Future<void> logout() async {
    final response = await DudeeService().logOut();
    if (response.statusCode == 201) {
      GoRouter.of(context).goNamed(AppRoute.login) ;
    }
  }

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
            'Welcome ${userProfile?.data?.name}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 16),
          ElevatedButton(onPressed: logout , child: Text("Log out"))
        ],
      ),
    );
  }
}
