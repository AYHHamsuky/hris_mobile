import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const _paths = ['/dashboard', '/tasks', '/inspections', '/leave', '/appraisals'];

  int _indexFor(String loc) {
    for (var i = 0; i < _paths.length; i++) {
      if (loc.startsWith(_paths[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexFor(location);
    final l = AppL10n.of(context);
    final destinations = [
      (Icons.home_outlined, Icons.home, l.navHome),
      (Icons.task_alt_outlined, Icons.task_alt, l.navTasks),
      (Icons.location_on_outlined, Icons.location_on, l.navInspections),
      (Icons.calendar_month_outlined, Icons.calendar_month, l.navLeave),
      (Icons.assignment_outlined, Icons.assignment, l.navAppraisals),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_paths[i]),
        destinations: [
          for (final d in destinations)
            NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
        ],
      ),
    );
  }
}
