import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Experiences extends StatefulHookWidget {
  const Experiences({super.key});

  @override
  State<Experiences> createState() => _ExperiencesState();
}

class _ExperiencesState extends State<Experiences> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Experiences")),
    );
  }
}
