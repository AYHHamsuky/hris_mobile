// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kaduna Electric HRIS';

  @override
  String get appTagline => 'HRIS Staff Companion';

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navInspections => 'Inspections';

  @override
  String get navLeave => 'Leave';

  @override
  String get navMe => 'Me';

  @override
  String get loginEmailOrPayroll => 'Email or Payroll ID';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginRequired => 'Required';

  @override
  String get loginHint => 'Use your work email or Payroll ID';

  @override
  String get dashboardGreetingMorning => 'Good morning.';

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon.';

  @override
  String get dashboardGreetingEvening => 'Good evening.';

  @override
  String dashboardHello(Object name) {
    return 'Hello, $name';
  }

  @override
  String get dashboardMyTasks => 'My Tasks';

  @override
  String get dashboardProjects => 'Projects';

  @override
  String get dashboardLeaveDaysLeft => 'Leave Days Left';

  @override
  String get dashboardFieldInspections => 'Field Inspections';

  @override
  String get dashboardOpenProjectCount => 'Open project count';

  @override
  String get dashboardCaptureGps => 'Capture GPS + photos';

  @override
  String get dashboardLogVisit => 'Log a visit';

  @override
  String dashboardOverdueDue(Object overdue, Object due) {
    return '$overdue overdue · $due due ≤7d';
  }

  @override
  String dashboardPendingApps(Object n) {
    return '$n pending applications';
  }

  @override
  String get tasksTitle => 'My Tasks';

  @override
  String get tasksSearchHint => 'Search tasks…';

  @override
  String get tasksAllStates => 'All states';

  @override
  String get tasksNoneMatch => 'No tasks match the current filter.';

  @override
  String get stateBacklog => 'Backlog';

  @override
  String get stateInProgress => 'In Progress';

  @override
  String get stateChangesRequested => 'Changes Requested';

  @override
  String get stateApproved => 'Approved';

  @override
  String get stateDone => 'Done';

  @override
  String get stateCancelled => 'Cancelled';

  @override
  String get leaveTitle => 'Leave';

  @override
  String get leaveBalances => 'Balances';

  @override
  String get leaveMyApps => 'My Applications';

  @override
  String get leaveApply => 'Apply';

  @override
  String leaveDaysLeft(Object n) {
    return '$n left';
  }

  @override
  String leaveTaken(Object taken, Object pending, Object allowed) {
    return '$taken taken · $pending pending · $allowed allowed';
  }

  @override
  String get leaveNoApps => 'No leave applications yet.';

  @override
  String get leavePendingLm => 'Pending LM';

  @override
  String get leaveAwaitingHr => 'Awaiting HR';

  @override
  String get leaveRejectedLm => 'Rejected by LM';

  @override
  String get leaveApproved => 'Approved';

  @override
  String get leaveRejected => 'Rejected';

  @override
  String get leaveApplyTitle => 'Apply for Leave';

  @override
  String get leaveType => 'Leave type';

  @override
  String get leaveTypeSelect => 'Select leave type';

  @override
  String get leaveStartDate => 'Start date';

  @override
  String get leaveEndDate => 'End date';

  @override
  String get leaveChooseDate => 'Choose…';

  @override
  String get leaveReason => 'Reason (optional)';

  @override
  String get leaveReasonHint => 'e.g. Family event';

  @override
  String get leaveSubmit => 'Submit application';

  @override
  String get inspectionsTitle => 'Field Inspections';

  @override
  String get inspectionsNew => 'New';

  @override
  String get inspectionsEmpty => 'No inspections yet.';

  @override
  String get inspectionsEmptyHint =>
      'Tap \"New\" to record your first site visit.';

  @override
  String inspectionDraftCount(Object n) {
    return '$n draft(s) waiting to sync';
  }

  @override
  String get inspectionSyncNow => 'Sync now';

  @override
  String get inspectionSavedAsDraft =>
      'Saved as draft — we\'ll upload when you\'re back online.';

  @override
  String get inspectionFormTitle => 'New Field Inspection';

  @override
  String get inspectionProject => 'Project';

  @override
  String get inspectionWeather => 'Weather';

  @override
  String inspectionProgressObserved(Object pct) {
    return 'Progress observed: $pct%';
  }

  @override
  String get inspectionNotes => 'Notes';

  @override
  String get inspectionNotesHint => 'What did you observe?';

  @override
  String get inspectionUseLocation => 'Use my location';

  @override
  String get inspectionLocation => 'Location';

  @override
  String get inspectionLocationName => 'Site / location name (optional)';

  @override
  String inspectionMedia(Object n) {
    return 'Media ($n)';
  }

  @override
  String get inspectionCamera => 'Camera';

  @override
  String get inspectionGallery => 'Gallery';

  @override
  String get inspectionFiles => 'Files';

  @override
  String get inspectionSave => 'Save Inspection';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileBiometric => 'Biometric unlock';

  @override
  String get profileBiometricSub =>
      'Use fingerprint or Face ID to open the app';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsAllRead => 'Mark all read';

  @override
  String get notificationsEmpty => 'You\'re all caught up.';

  @override
  String get teamLeaveTitle => 'Team Leave';

  @override
  String get teamLeaveEmpty => 'No pending leave from your team.';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get tryAgain => 'Try again';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get navAppraisals => 'Appraisals';

  @override
  String get appraisalsTitle => 'My Appraisals';

  @override
  String get appraisalsEmpty => 'No appraisals assigned to you yet.';

  @override
  String get appraisalsObjectives => 'Objectives';

  @override
  String get appraisalsSelfAssessment => 'Self assessment';

  @override
  String get appraisalsReviewerComments => 'Reviewer comments';

  @override
  String get appraisalsHrRejectionReason => 'HR rejection reason';

  @override
  String get appraisalsWebOnlyNotice =>
      'Editing, rating, and agreement actions are only available on the web. Sign in at kadunaelectric.cloud to act on this appraisal.';

  @override
  String get appraisalStatusPlanning => 'Planning';

  @override
  String get appraisalStatusPlanAgreed => 'Plan Agreed';

  @override
  String get appraisalStatusTracking => 'Mid-Year Tracking';

  @override
  String get appraisalStatusRating => 'Rating';

  @override
  String get appraisalStatusFinalized => 'Finalized';

  @override
  String get leaveSubmitted => 'Leave application submitted.';

  @override
  String get rejectionReason => 'Rejection reason';

  @override
  String get post => 'Post';

  @override
  String get addComment => 'Add Comment';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHausa => 'Hausa';
}
