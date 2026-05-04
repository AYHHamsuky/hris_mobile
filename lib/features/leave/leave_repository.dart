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
