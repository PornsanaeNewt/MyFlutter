import 'package:flutter/material.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/screen/home/view/home.dart';
import 'package:flutter_app_test1/screen/login/login.dart';
import 'package:flutter_app_test1/screen/profile/profile.dart';
import 'package:flutter_app_test1/screen/register/register.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoute {
  static const String currentRoute = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    redirect: (BuildContext context, GoRouterState state) {
      final userController = Get.put(UserController());
      userController.update;
      final bool isLoggedIn = userController.isLogIn.value;
      final String location = state.matchedLocation;
      final bool isGoingToLogin = location == AppRoute.login;
      final bool isGoingToRegister = location == AppRoute.register;
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return AppRoute.login;
      }
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return AppRoute.home;
      }
      return null;
    },
    
    routes: [
      GoRoute(
        name: 'current',
        path: currentRoute,
        pageBuilder: (context, state) {
          return MaterialPage(child: Login());
        },
      ),

      GoRoute(
        name: login,
        path: login,
        pageBuilder: (context, state) {
          return MaterialPage(child: Login());
        },
      ),

      GoRoute(
        name: home,
        path: home,
        pageBuilder: (context, state) {
          return MaterialPage(child: HomePage());
        },
      ),

      // GoRoute(
      //   name: RouteName.login,
      //   path: '/login',
      //   pageBuilder: (context, state) {
      //     return MaterialPage(child: Login());
      //   },
      // ),
      GoRoute(
        name: register,
        path: register,
        pageBuilder: (context, state) {
          return MaterialPage(child: Register());
        },
      ),

      GoRoute(
        name: profile,
        path: profile,
        pageBuilder: (context, state) {
          return MaterialPage(child: Profile());
        },
      ),
    ],
  );
}
