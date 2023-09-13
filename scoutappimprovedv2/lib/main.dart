import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scoutappimprovedv2/pages/announcements.dart';
import 'package:scoutappimprovedv2/pages/badge_viewer.dart';
import 'package:scoutappimprovedv2/pages/experiences.dart';
import 'package:scoutappimprovedv2/pages/home.dart';
import 'package:scoutappimprovedv2/pages/root.dart';
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
        path: '/welcome',
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: Welcome());
        }),
    ShellRoute(
      pageBuilder: (context, state, child) => CustomTransitionPage(
          child: RootPage(
            currentNavLink: state.uri.toString(),
            child: child,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
                opacity: animation,
                child: child,
              ),
          maintainState: true),
      routes: [
        GoRoute(
            path: '/',
            pageBuilder: (context, state) => CustomTransitionPage(
                child: const Home(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        const Home(),
                maintainState:
                    false), // Using a custom transition page as for some reason NoTransitionPage saves the state
            routes: [
              GoRoute(
                  path: 'badge/:name',
                  builder: (context, state) =>
                      BadgeViewer(name: state.pathParameters["name"]!)),
              GoRoute(
                  path: 'view_all_badges',
                  pageBuilder: (context, state) =>
                      const MaterialPage(child: ViewAllBadgesView())),
            ]),
        GoRoute(
          path: '/experiences',
          pageBuilder: (context, state) => CustomTransitionPage(
              child: const Experiences(),
              fullscreenDialog: true,
              maintainState: false,
              transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) =>
                  const Experiences()),
        ),
        GoRoute(
          path: '/announcements',
          pageBuilder: (context, state) => CustomTransitionPage(
              child: const Announcements(),
              fullscreenDialog: true,
              maintainState: false,
              transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) =>
                  const Announcements()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => CustomTransitionPage(
              child: const Settings(),
              fullscreenDialog: true,
              maintainState: false,
              transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) =>
                  const Settings()),
        ),
      ],
    ),
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
