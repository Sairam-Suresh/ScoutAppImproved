import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Announcements extends StatefulHookWidget {
  const Announcements({super.key});

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Announcements")),
    );
  }
}
