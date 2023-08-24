import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Settings extends HookWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
    );
  }
}
