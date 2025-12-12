import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/logarte.dart';
import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/model/conversation.dart';
import 'package:flutter_app_test1/screen/chat/view/chat.dart';
import 'package:flutter_app_test1/screen/home/view/home.dart';
import 'package:flutter_app_test1/screen/login/login.dart';
import 'package:flutter_app_test1/screen/profile/view/profile.dart';
import 'package:flutter_app_test1/screen/register/register.dart';
import 'package:flutter_app_test1/screen/splash/view/splash_sceen.dart';
import 'package:go_router/go_router.dart';
import 'package:logarte/logarte.dart';

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
    observers: [LogarteNavigatorObserver(logarte)],
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
        builder: (context, state) {
          return SplashSceen();
        },
      ),

      GoRoute(
        name: login,
        path: login,
        builder: (context, state) {
          return Login();
        },
      ),

      GoRoute(
        name: home,
        path: home,
        builder: (context, state) {
          return HomePage();
        },
      ),

      GoRoute(
        name: register,
        path: register,
        builder: (context, state) {
          return Register();
        },
      ),

      GoRoute(
        name: profile,
        path: profile,
        builder: (context, state) {
          return Profile();
        },
      ),

      GoRoute(
        name: chat,
        path: '${chat}/:conversationId',
        builder: (context, state) {
          return ChatPage(
            conversationId: state.pathParameters['conversationId']!,
          );
        },
      ),
    ],
  );
}
