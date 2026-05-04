import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const _routes = [
    ('/dashboard', Icons.home_outlined, Icons.home, 'Home'),
    ('/tasks', Icons.task_alt_outlined, Icons.task_alt, 'Tasks'),
    ('/inspections', Icons.location_on_outlined, Icons.location_on, 'Inspections'),
    ('/leave', Icons.calendar_month_outlined, Icons.calendar_month, 'Leave'),
    ('/profile', Icons.person_outline, Icons.person, 'Me'),
  ];

  int _indexFor(String loc) {
    for (var i = 0; i < _routes.length; i++) {
      if (loc.startsWith(_routes[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexFor(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_routes[i].$1),
        destinations: _routes
            .map((r) => NavigationDestination(
                  icon: Icon(r.$2),
                  selectedIcon: Icon(r.$3),
                  label: r.$4,
                ))
            .toList(),
      ),
    );
  }
}
