import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'leave_models.dart';

class LeaveRepository {
  LeaveRepository(this._api);
  final ApiClient _api;

  Future<List<LeaveApplication>> myApplications() async {
    final r = await _api.dio.get('/leave', queryParameters: {'per_page': 50});
    return (r.data['data'] as List).cast<Map<String, dynamic>>().map(LeaveApplication.fromJson).toList();
  }

  Future<List<LeaveBalance>> balances() async {
    final r = await _api.dio.get('/leave/balances');
    return (r.data['data'] as List).cast<Map<String, dynamic>>().map(LeaveBalance.fromJson).toList();
  }

  Future<void> apply({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    String? reason,
    int? relieverEmployeeId,
  }) async {
    await _api.dio.post('/leave', data: {
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
      if (relieverEmployeeId != null) 'reliever_employee_id': relieverEmployeeId,
    });
  }

  /// Pending applications for staff who report to the current line manager.
  Future<List<TeamLeaveItem>> teamPending() async {
    final r = await _api.dio.get('/leave/team', queryParameters: {'per_page': 50});
    return (r.data['data'] as List).cast<Map<String, dynamic>>().map(TeamLeaveItem.fromJson).toList();
  }

  Future<void> lmApprove(int id) async {
    await _api.dio.post('/leave/$id/lm-approve');
  }

  Future<void> lmReject(int id, String reason) async {
    await _api.dio.post('/leave/$id/lm-reject', data: {'reason': reason});
  }
}

class TeamLeaveItem {
  TeamLeaveItem({
    required this.id, required this.employeeName, required this.leaveTypeName,
    required this.startDate, required this.endDate, required this.daysRequested,
    required this.status, this.reason, this.department,
  });

  final int id;
  final String employeeName;
  final String? department;
  final String leaveTypeName;
  final String startDate;
  final String endDate;
  final int daysRequested;
  final String status;
  final String? reason;

  factory TeamLeaveItem.fromJson(Map<String, dynamic> j) => TeamLeaveItem(
        id: j['id'] as int,
        employeeName: (j['employee'] as Map?)?['name'] as String? ?? 'Employee',
        department: (j['employee'] as Map?)?['department'] as String?,
        leaveTypeName: (j['leave_type'] as Map?)?['name'] as String? ?? 'Leave',
        startDate: j['start_date'] as String,
        endDate: j['end_date'] as String,
        daysRequested: j['days_requested'] as int? ?? 0,
        status: j['status'] as String? ?? 'pending',
        reason: j['reason'] as String?,
      );
}

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository(ref.read(apiClientProvider));
});

final myLeaveProvider = FutureProvider<List<LeaveApplication>>((ref) async {
  return ref.read(leaveRepositoryProvider).myApplications();
});

final leaveBalancesProvider = FutureProvider<List<LeaveBalance>>((ref) async {
  return ref.read(leaveRepositoryProvider).balances();
});

final teamLeaveProvider = FutureProvider<List<TeamLeaveItem>>((ref) async {
  return ref.read(leaveRepositoryProvider).teamPending();
});
