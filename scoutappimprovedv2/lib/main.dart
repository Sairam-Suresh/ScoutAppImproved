import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scoutappimprovedv2/pages/badge_viewer.dart';
import 'package:scoutappimprovedv2/pages/home.dart';
import 'package:scoutappimprovedv2/pages/settings.dart';
import 'package:scoutappimprovedv2/pages/welcome.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: "/welcome",
  routes: [
    GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            MaterialPage(child: Home(), maintainState: true),
        routes: [
          GoRoute(
              path: 'badge/:name',
              builder: (context, state) =>
                  BadgeViewer(name: state.pathParameters["name"]!)),
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) => MaterialPage(
                child: Settings(state.extra as Function(bool logOut)),
                fullscreenDialog: true,
                maintainState: false),
          )

          // GoRoute(
          //     path: 'all_badges', builder: (context, state) => SeeAllBadgesView())
        ]),
    GoRoute(
        path: '/welcome',
        builder: (context, state) {
          return Welcome();
        }),
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
