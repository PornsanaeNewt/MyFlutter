import 'package:flutter/material.dart';
import 'package:flutter_app_test1/route/app_route.dart';

void main() {
  runApp( const MyApp());
}

final _appRoute = AppRoute();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: _appRoute.router.routeInformationParser,
      routeInformationProvider: _appRoute.router.routeInformationProvider,
      routerDelegate: _appRoute.router.routerDelegate,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
