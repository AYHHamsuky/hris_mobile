// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hausa (`ha`).
class AppL10nHa extends AppL10n {
  AppL10nHa([String locale = 'ha']) : super(locale);

  @override
  String get appTitle => 'Kaduna Electric HRIS';

  @override
  String get appTagline => 'Aikace-aikacen Ma\'aikata';

  @override
  String get navHome => 'Gida';

  @override
  String get navTasks => 'Ayyuka';

  @override
  String get navInspections => 'Bincike';

  @override
  String get navLeave => 'Hutu';

  @override
  String get navMe => 'Ni';

  @override
  String get loginEmailOrPayroll => 'Imel ko Lambar Albashi';

  @override
  String get loginPassword => 'Kalmar wucewa';

  @override
  String get loginSignIn => 'Shiga';

  @override
  String get loginRequired => 'Wajibi ne';

  @override
  String get loginHint => 'Yi amfani da imel din aiki ko Lambar Albashinka';

  @override
  String get dashboardGreetingMorning => 'Barka da safiya.';

  @override
  String get dashboardGreetingAfternoon => 'Barka da rana.';

  @override
  String get dashboardGreetingEvening => 'Barka da yamma.';

  @override
  String dashboardHello(Object name) {
    return 'Sannu, $name';
  }

  @override
  String get dashboardMyTasks => 'Ayyukana';

  @override
  String get dashboardProjects => 'Manyan Ayyuka';

  @override
  String get dashboardLeaveDaysLeft => 'Sauran Kwanakin Hutu';

  @override
  String get dashboardFieldInspections => 'Bincike a Wuri';

  @override
  String get dashboardOpenProjectCount => 'Adadin manyan ayyuka';

  @override
  String get dashboardCaptureGps => 'Dauki GPS + hoton';

  @override
  String get dashboardLogVisit => 'Adana ziyara';

  @override
  String dashboardOverdueDue(Object overdue, Object due) {
    return '$overdue sun wuce · $due sauran kwana 7';
  }

  @override
  String dashboardPendingApps(Object n) {
    return '$n ana jiran amincewa';
  }

  @override
  String get tasksTitle => 'Ayyukana';

  @override
  String get tasksSearchHint => 'Nemo ayyuka…';

  @override
  String get tasksAllStates => 'Duk matakai';

  @override
  String get tasksNoneMatch => 'Babu aiki da ya dace da matatar yanzu.';

  @override
  String get stateBacklog => 'Jira';

  @override
  String get stateInProgress => 'Ana Aiki';

  @override
  String get stateChangesRequested => 'An Nemi Gyara';

  @override
  String get stateApproved => 'An Amince';

  @override
  String get stateDone => 'An Gama';

  @override
  String get stateCancelled => 'An Soke';

  @override
  String get leaveTitle => 'Hutu';

  @override
  String get leaveBalances => 'Sauran Kwanaki';

  @override
  String get leaveMyApps => 'Aikace-aikacena';

  @override
  String get leaveApply => 'Nema';

  @override
  String leaveDaysLeft(Object n) {
    return '$n suka rage';
  }

  @override
  String leaveTaken(Object taken, Object pending, Object allowed) {
    return '$taken an dauka · $pending ana jira · $allowed an bayar';
  }

  @override
  String get leaveNoApps => 'Babu wani aikace-aikace tukuna.';

  @override
  String get leavePendingLm => 'Ana Jiran LM';

  @override
  String get leaveAwaitingHr => 'Ana Jiran HR';

  @override
  String get leaveRejectedLm => 'LM ya Ƙi';

  @override
  String get leaveApproved => 'An Amince';

  @override
  String get leaveRejected => 'An Ƙi';

  @override
  String get leaveApplyTitle => 'Neman Hutu';

  @override
  String get leaveType => 'Nau\'in Hutu';

  @override
  String get leaveTypeSelect => 'Zaɓi nau\'in hutu';

  @override
  String get leaveStartDate => 'Ranar farko';

  @override
  String get leaveEndDate => 'Ranar ƙarshe';

  @override
  String get leaveChooseDate => 'Zaɓi…';

  @override
  String get leaveReason => 'Dalili (zaɓi)';

  @override
  String get leaveReasonHint => 'misali, Taron iyali';

  @override
  String get leaveSubmit => 'Aika aikace-aikace';

  @override
  String get inspectionsTitle => 'Bincike a Wuri';

  @override
  String get inspectionsNew => 'Sabo';

  @override
  String get inspectionsEmpty => 'Babu wani bincike tukuna.';

  @override
  String get inspectionsEmptyHint =>
      'Danna \"Sabo\" don adana ziyararka ta farko.';

  @override
  String inspectionDraftCount(Object n) {
    return '$n sun jira a aika';
  }

  @override
  String get inspectionSyncNow => 'Aika yanzu';

  @override
  String get inspectionSavedAsDraft =>
      'An ajiye azaman daftari — za mu aika lokacin da ka koma kan layi.';

  @override
  String get inspectionFormTitle => 'Sabon Bincike a Wuri';

  @override
  String get inspectionProject => 'Babban Aiki';

  @override
  String get inspectionWeather => 'Yanayi';

  @override
  String inspectionProgressObserved(Object pct) {
    return 'Ci gaba: $pct%';
  }

  @override
  String get inspectionNotes => 'Bayanai';

  @override
  String get inspectionNotesHint => 'Me ka gani?';

  @override
  String get inspectionUseLocation => 'Yi amfani da wurina';

  @override
  String get inspectionLocation => 'Wuri';

  @override
  String get inspectionLocationName => 'Sunan wuri (zaɓi)';

  @override
  String inspectionMedia(Object n) {
    return 'Hoto/Bidiyo ($n)';
  }

  @override
  String get inspectionCamera => 'Kyamara';

  @override
  String get inspectionGallery => 'Hoto';

  @override
  String get inspectionFiles => 'Fayiloli';

  @override
  String get inspectionSave => 'Ajiye Bincike';

  @override
  String get profileTitle => 'Bayanan Kaina';

  @override
  String get profileChangePassword => 'Canza Kalmar Wucewa';

  @override
  String get profileBiometric => 'Buɗewa da Yatsa';

  @override
  String get profileBiometricSub =>
      'Yi amfani da yatsa ko Face ID don buɗe app';

  @override
  String get profileLanguage => 'Harshe';

  @override
  String get profileSignOut => 'Fita';

  @override
  String get notificationsTitle => 'Saƙonni';

  @override
  String get notificationsAllRead => 'Sanya duk an karanta';

  @override
  String get notificationsEmpty => 'Babu sabbin saƙonni.';

  @override
  String get teamLeaveTitle => 'Hutun Tawagar';

  @override
  String get teamLeaveEmpty =>
      'Babu wani aikace-aikace na hutu daga tawagarka.';

  @override
  String get approve => 'Amincewa';

  @override
  String get reject => 'Ƙi';

  @override
  String get cancel => 'Soke';

  @override
  String get save => 'Ajiye';

  @override
  String get tryAgain => 'Sake gwadawa';

  @override
  String get retry => 'Sake';

  @override
  String get loading => 'Ana ɗaukar…';

  @override
  String get navAppraisals => 'Tantancewa';

  @override
  String get appraisalsTitle => 'Tantancewata';

  @override
  String get appraisalsEmpty => 'Babu tantancewa da aka ba ka tukuna.';

  @override
  String get appraisalsObjectives => 'Manufofin';

  @override
  String get appraisalsSelfAssessment => 'Tantancewar kai';

  @override
  String get appraisalsReviewerComments => 'Tsokaci na mai duba';

  @override
  String get appraisalsHrRejectionReason => 'Dalilin ƙin HR';

  @override
  String get appraisalsWebOnlyNotice =>
      'Gyara, ba da maki, da yarda ana yi ne kawai a yanar gizo. Shiga a kadunaelectric.cloud.';

  @override
  String get appraisalStatusPlanning => 'Tsarawa';

  @override
  String get appraisalStatusPlanAgreed => 'An Yarda';

  @override
  String get appraisalStatusTracking => 'Tsakiyar Shekara';

  @override
  String get appraisalStatusRating => 'Bayar da Maki';

  @override
  String get appraisalStatusFinalized => 'An Gama';

  @override
  String get leaveSubmitted => 'An aika aikace-aikacen hutu.';

  @override
  String get rejectionReason => 'Dalilin ƙin amincewa';

  @override
  String get post => 'Aika';

  @override
  String get addComment => 'Ƙara Tsokaci';

  @override
  String get languageSystem => 'Tsoffin tsarin';

  @override
  String get languageEnglish => 'Turanci';

  @override
  String get languageHausa => 'Hausa';
}
