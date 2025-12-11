import 'package:flutter/material.dart';
import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/model/conversation.dart';
import 'package:flutter_app_test1/screen/chat/view/chat.dart';
import 'package:flutter_app_test1/screen/home/view/home.dart';
import 'package:flutter_app_test1/screen/login/login.dart';
import 'package:flutter_app_test1/screen/profile/profile.dart';
import 'package:flutter_app_test1/screen/register/register.dart';
import 'package:flutter_app_test1/screen/splash/view/splash_sceen.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoute {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String chat = '/chat';

  Conversation conversation = Conversation();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoute.splash,
    // Redirect function สำหรับตรวจสอบ authentication
    redirect: (BuildContext context, GoRouterState state) async {
      final isSplashPage = state.uri.path == AppRoute.splash;
      if (isSplashPage) return null;

      final isLoginPage = state.uri.path == AppRoute.login;
      final isRegisterPage = state.uri.path == AppRoute.register;

      if (isLoginPage || isRegisterPage) {
        return null;
      }

      final isLoggedIn = await LocalStorageService.getIsLogin();

      if (!isLoggedIn) {
        return AppRoute.login;
      }

      return null;
    },

    routes: [
      GoRoute(
        name: 'splash',
        path: splash,
        pageBuilder: (context, state) {
          return MaterialPage(child: SplashSceen());
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

      GoRoute(
        name: chat,
        path: '${chat}/:conversationId',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: ChatPage(
              conversationId: state.pathParameters['conversationId']!,
            ),
          );
        },
      ),
    ],
  );
}
