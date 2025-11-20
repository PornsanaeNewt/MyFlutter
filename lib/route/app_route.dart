import 'package:flutter/material.dart';
import 'package:flutter_app_test1/pages/home.dart';
import 'package:flutter_app_test1/route/route_name.dart';
import 'package:flutter_app_test1/screen/home.dart';
import 'package:flutter_app_test1/screen/login.dart';
import 'package:flutter_app_test1/screen/profile.dart';
import 'package:flutter_app_test1/screen/register.dart';
import 'package:go_router/go_router.dart';

class AppRoute {

  GoRouter router = GoRouter(

    routes: [
      GoRoute(
        name: RouteName.home,
        path: '/', 
        pageBuilder: (context, state) {
          return MaterialPage(child: Home());
        },
      ),

      GoRoute(
        name: RouteName.homepage,
        path: '/home', 
        pageBuilder: (context, state) {
          return MaterialPage(child: HomePage());
        },
      ),

      GoRoute(
        name: RouteName.login, 
        path: '/login',
        pageBuilder: (context, state) {
          return MaterialPage(child: Login());
        },
      ),
      GoRoute(
        name: RouteName.register,
        path: '/register',
        pageBuilder: (context, state) {
          return MaterialPage(child: Register());
        },
      ),

      GoRoute(
        name: RouteName.profile,
        path: '/profile/:name', 
        pageBuilder: (context, state) {
          return MaterialPage(
            child: Profile(
              name: state.pathParameters['name']!,
            ),
          );
        },
      ),
    ],
  );  

}