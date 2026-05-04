import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

class AppraisalSummary {
  AppraisalSummary({
    required this.id,
    required this.status,
    required this.cycleName,
    required this.cyclePhase,
    this.overallScore,
    this.jobRoleTitle,
    this.reviewerName,
    this.hrApprovedAt,
    this.hrRejectedAt,
    this.planningLockedAt,
  });

  final int id;
  final String status;
  final String cycleName;
  final String cyclePhase;
  final String? overallScore;
  final String? jobRoleTitle;
  final String? reviewerName;
  final String? hrApprovedAt;
  final String? hrRejectedAt;
  final String? planningLockedAt;

  factory AppraisalSummary.fromJson(Map<String, dynamic> j) => AppraisalSummary(
        id: j['id'] as int,
        status: j['status'] as String? ?? 'draft',
        cycleName: (j['cycle'] as Map?)?['name'] as String? ?? '—',
        cyclePhase: (j['cycle'] as Map?)?['current_phase'] as String? ?? 'planning',
        overallScore: j['overall_score']?.toString(),
        jobRoleTitle: j['job_role_title'] as String?,
        reviewerName: (j['reviewer'] as Map?)?['name'] as String?,
        hrApprovedAt: j['hr_approved_at'] as String?,
        hrRejectedAt: j['hr_rejected_at'] as String?,
        planningLockedAt: j['planning_locked_at'] as String?,
      );
}

class AppraisalDetail {
  AppraisalDetail({
    required this.id,
    required this.status,
    required this.cycleName,
    required this.cyclePhase,
    required this.objectives,
    this.overallScore,
    this.jobRoleTitle,
    this.reviewerName,
    this.hrApprovedAt,
    this.hrRejectedAt,
    this.hrRejectionReason,
    this.planningLockedAt,
    this.trackingLockedAt,
    this.selfAssessment,
    this.reviewerComments,
  });

  final int id;
  final String status;
  final String cycleName;
  final String cyclePhase;
  final List<AppraisalObjective> objectives;
  final String? overallScore;
  final String? jobRoleTitle;
  final String? reviewerName;
  final String? hrApprovedAt;
  final String? hrRejectedAt;
  final String? hrRejectionReason;
  final String? planningLockedAt;
  final String? trackingLockedAt;
  final String? selfAssessment;
  final String? reviewerComments;

  factory AppraisalDetail.fromJson(Map<String, dynamic> root) {
    final d = root['data'] as Map<String, dynamic>;
    final objs = (root['objectives'] as List? ?? const []).cast<Map<String, dynamic>>();
    return AppraisalDetail(
      id: d['id'] as int,
      status: d['status'] as String? ?? 'draft',
      cycleName: (d['cycle'] as Map?)?['name'] as String? ?? '—',
      cyclePhase: (d['cycle'] as Map?)?['current_phase'] as String? ?? 'planning',
      objectives: objs.map(AppraisalObjective.fromJson).toList(),
      overallScore: d['overall_score']?.toString(),
      jobRoleTitle: d['job_role_title'] as String?,
      reviewerName: (d['reviewer'] as Map?)?['name'] as String?,
      hrApprovedAt: d['hr_approved_at'] as String?,
      hrRejectedAt: d['hr_rejected_at'] as String?,
      hrRejectionReason: d['hr_rejection_reason'] as String?,
      planningLockedAt: d['planning_locked_at'] as String?,
      trackingLockedAt: d['tracking_locked_at'] as String?,
      selfAssessment: d['self_assessment'] as String?,
      reviewerComments: d['reviewer_comments'] as String?,
    );
  }
}

class AppraisalObjective {
  AppraisalObjective({
    required this.id,
    required this.bscCategory,
    required this.description,
    this.kpi,
    this.weight,
    this.target,
    this.selfRating,
    this.score,
    this.managerComment,
    this.progressStatus,
    this.yearlyAchieved,
  });

  final int id;
  final String bscCategory;
  final String description;
  final String? kpi;
  final num? weight;
  final String? target;
  final int? selfRating;
  final int? score;
  final String? managerComment;
  final String? progressStatus;
  final String? yearlyAchieved;

  factory AppraisalObjective.fromJson(Map<String, dynamic> j) => AppraisalObjective(
        id: j['id'] as int,
        bscCategory: j['bsc_category'] as String? ?? 'Other',
        description: j['description'] as String? ?? '',
        kpi: j['kpi'] as String?,
        weight: j['weight'] as num?,
        target: j['target']?.toString(),
        selfRating: j['self_rating'] as int?,
        score: j['score'] as int?,
        managerComment: j['manager_comment'] as String?,
        progressStatus: j['progress_status'] as String?,
        yearlyAchieved: j['yearly_achieved']?.toString(),
      );
}

class PerformanceRepository {
  PerformanceRepository(this._api);
  final ApiClient _api;

  Future<List<AppraisalSummary>> myAppraisals() async {
    final r = await _api.dio.get('/performance/my-appraisals', queryParameters: {'per_page': 25});
    return (r.data['data'] as List).cast<Map<String, dynamic>>().map(AppraisalSummary.fromJson).toList();
  }

  Future<AppraisalDetail> show(int id) async {
    final r = await _api.dio.get('/performance/reviews/$id');
    return AppraisalDetail.fromJson(r.data as Map<String, dynamic>);
  }
}

final performanceRepoProvider = Provider<PerformanceRepository>((ref) {
  return PerformanceRepository(ref.read(apiClientProvider));
});

final myAppraisalsProvider = FutureProvider<List<AppraisalSummary>>((ref) async {
  return ref.read(performanceRepoProvider).myAppraisals();
});

final appraisalDetailProvider = FutureProvider.family<AppraisalDetail, int>((ref, id) async {
  return ref.read(performanceRepoProvider).show(id);
});
