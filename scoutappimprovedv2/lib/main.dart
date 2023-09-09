import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scoutappimprovedv2/pages/badge_viewer.dart';
import 'package:scoutappimprovedv2/pages/home.dart';
import 'package:scoutappimprovedv2/pages/settings.dart';
import 'package:scoutappimprovedv2/pages/view_all_badges.dart';
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
            const MaterialPage(child: Home(), maintainState: false),
        routes: [
          GoRoute(
              path: 'badge/:name',
              builder: (context, state) =>
                  BadgeViewer(name: state.pathParameters["name"]!)),
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) => const MaterialPage(
                child: Settings(),
                fullscreenDialog: true,
                maintainState: false),
          ),
          GoRoute(
              path: 'view_all_badges',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: ViewAllBadgesView())),

          // GoRoute(
          //     path: 'all_badges', builder: (context, state) => SeeAllBadgesView())
        ]),
    GoRoute(
        path: '/welcome',
        builder: (context, state) {
          return const Welcome();
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
