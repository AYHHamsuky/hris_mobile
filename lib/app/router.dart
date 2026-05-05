import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_repository.dart';
import '../features/auth/biometric_gate.dart';
import '../features/auth/change_password_page.dart';
import '../features/auth/login_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/inspections/inspection_form_page.dart';
import '../features/inspections/inspections_list_page.dart';
import '../features/leave/leave_apply_page.dart';
import '../features/leave/leave_list_page.dart';
import '../features/leave/team_leave_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/performance/appraisal_detail_page.dart';
import '../features/performance/appraisals_list_page.dart';
import '../features/profile/profile_page.dart';
import '../features/projects/project_detail_page.dart';
import '../features/projects/projects_list_page.dart';
import '../features/tasks/task_detail_page.dart';
import '../features/tasks/tasks_list_page.dart';
import 'main_shell.dart';

GoRouter buildRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loggedIn = auth.user != null;
      final atLogin = state.matchedLocation == '/login';

      if (!loggedIn && !atLogin) return '/login';
      if (loggedIn && atLogin) return '/dashboard';
      if (loggedIn && auth.user!.mustChangePassword && state.matchedLocation != '/change-password?first=1') {
        return '/change-password?first=1';
      }
      return null;
    },
    refreshListenable: _AuthRefreshNotifier(ref),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/change-password',
        builder: (_, state) => ChangePasswordPage(firstLogin: state.uri.queryParameters['first'] == '1'),
      ),
      ShellRoute(
        builder: (context, state, child) => BiometricGate(child: MainShell(location: state.uri.path, child: child)),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          GoRoute(
            path: '/tasks',
            builder: (_, __) => const TasksListPage(),
            routes: [
              GoRoute(path: ':id', builder: (_, state) => TaskDetailPage(id: int.parse(state.pathParameters['id']!))),
            ],
          ),
          GoRoute(
            path: '/inspections',
            builder: (_, __) => const InspectionsListPage(),
            routes: [
              GoRoute(path: 'new', builder: (_, __) => const InspectionFormPage()),
            ],
          ),
          GoRoute(
            path: '/leave',
            builder: (_, __) => const LeaveListPage(),
            routes: [
              GoRoute(path: 'apply', builder: (_, __) => const LeaveApplyPage()),
              GoRoute(path: 'team', builder: (_, __) => const TeamLeavePage()),
            ],
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
          GoRoute(
            path: '/appraisals',
            builder: (_, __) => const AppraisalsListPage(),
            routes: [
              GoRoute(path: ':id', builder: (_, s) => AppraisalDetailPage(id: int.parse(s.pathParameters['id']!))),
            ],
          ),
          GoRoute(
            path: '/projects',
            builder: (_, __) => const ProjectsListPage(),
            routes: [
              GoRoute(path: ':id', builder: (_, s) => ProjectDetailPage(id: int.parse(s.pathParameters['id']!))),
            ],
          ),
        ],
      ),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(WidgetRef ref) {
    // listenManual is the only ref.listen variant that's allowed outside of
    // a build() callback. The plain ref.listen used here previously silently
    // no-opped, so the router never re-evaluated its `redirect` callback
    // after login — the user could enter valid credentials, the auth state
    // would flip to "logged in", and the redirect would never fire because
    // refreshListenable was never notified.
    ref.listenManual<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }
}
