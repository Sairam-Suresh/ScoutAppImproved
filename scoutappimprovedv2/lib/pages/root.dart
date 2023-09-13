import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootPage extends StatefulWidget {
  const RootPage(
      {super.key, required this.child, required this.currentNavLink});

  final Widget child;
  final String currentNavLink;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant RootPage oldWidget) {
    if (widget.currentNavLink == "/settings") {
      setState(() {
        _currentIndex = 1;
      });
    } else {
      setState(() {
        _currentIndex = 0;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void _goOtherTab(BuildContext context, int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      context.go('/');
    } else {
      context.go("/settings");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          // the appearance of each tab is defined with a [NavigationDestination] widget
          NavigationDestination(label: 'Overview', icon: Icon(Icons.home)),
          NavigationDestination(label: 'Settings', icon: Icon(Icons.settings)),
        ],
        onDestinationSelected: (indexAt) {
          _goOtherTab(context, indexAt);
          setState(() {
            _currentIndex = indexAt;
          });
        },
      ),
    );
  }
}
