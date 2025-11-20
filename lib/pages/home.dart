import 'package:flutter/material.dart';
import 'package:flutter_app_test1/route/route_name.dart';
import 'package:go_router/go_router.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24),
            ),
          ),
          
          //Push Named
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(RouteName.login);
            },
            child: const Text('Login'),
          ),

          const SizedBox(height: 16.0),


          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(RouteName.register);
            },
            child: const Text('Register'),
          ),

          //Use Go to
          // ElevatedButton(
          //   onPressed: () {
          //     GoRouter.of(context).go('/register');
          //   },
          //   child: const Text('Register'),
          // ),


          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(RouteName.homepage);
            },
            child: const Text('Home Page'),
          ),

          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(RouteName.profile, pathParameters: {'name': 'New Pornsanae' });
            },
            child: const Text('Profile'),
          ),
        ],
      ),
    );
  }
}