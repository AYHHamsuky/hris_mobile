class LeaveBalance {
  LeaveBalance({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.daysAllowed,
    required this.daysTaken,
    required this.daysPending,
    required this.daysRemaining,
    required this.requiresDocument,
    required this.requiresReliever,
  });

  final int leaveTypeId;
  final String leaveTypeName;
  final int daysAllowed;
  final int daysTaken;
  final int daysPending;
  final int daysRemaining;
  final bool requiresDocument;
  final bool requiresReliever;

  factory LeaveBalance.fromJson(Map<String, dynamic> j) => LeaveBalance(
        leaveTypeId: j['leave_type_id'] as int,
        leaveTypeName: j['leave_type_name'] as String,
        daysAllowed: j['days_allowed'] as int? ?? 0,
        daysTaken: j['days_taken'] as int? ?? 0,
        daysPending: j['days_pending'] as int? ?? 0,
        daysRemaining: j['days_remaining'] as int? ?? 0,
        requiresDocument: j['requires_document'] as bool? ?? false,
        requiresReliever: j['requires_reliever'] as bool? ?? true,
      );
}

class LeaveApplication {
  LeaveApplication({
    required this.id,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.daysRequested,
    required this.status,
    this.reason,
    this.lmRejectionReason,
    this.rejectionReason,
  });

  final int id;
  final String leaveTypeName;
  final String startDate;
  final String endDate;
  final int daysRequested;
  final String status; // pending, lm_approved, lm_rejected, approved, rejected
  final String? reason;
  final String? lmRejectionReason;
  final String? rejectionReason;

  factory LeaveApplication.fromJson(Map<String, dynamic> j) => LeaveApplication(
        id: j['id'] as int,
        leaveTypeName: (j['leave_type'] as Map?)?['name'] as String? ?? 'Leave',
        startDate: j['start_date'] as String,
        endDate: j['end_date'] as String,
        daysRequested: j['days_requested'] as int? ?? 0,
        status: j['status'] as String? ?? 'pending',
        reason: j['reason'] as String?,
        lmRejectionReason: j['lm_rejection_reason'] as String?,
        rejectionReason: j['rejection_reason'] as String?,
      );
}
