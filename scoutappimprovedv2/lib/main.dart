import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scoutappimprovedv2/pages/badge_viewer.dart';
import 'package:scoutappimprovedv2/pages/home.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => Home(), routes: [
      GoRoute(
          path: 'badge/:name',
          builder: (context, state) =>
              BadgeViewer(name: state.pathParameters["name"]!)),
      // GoRoute(
      //     path: 'all_badges', builder: (context, state) => SeeAllBadgesView())
    ]),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
