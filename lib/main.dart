import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/routes/app_route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: AppRoute.router.routeInformationParser,
      routeInformationProvider: AppRoute.router.routeInformationProvider,
      routerDelegate: AppRoute.router.routerDelegate,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
