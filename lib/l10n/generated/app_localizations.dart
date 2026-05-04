import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ha.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ha'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kaduna Electric HRIS'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'HRIS Staff Companion'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navInspections.
  ///
  /// In en, this message translates to:
  /// **'Inspections'**
  String get navInspections;

  /// No description provided for @navLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get navLeave;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @loginEmailOrPayroll.
  ///
  /// In en, this message translates to:
  /// **'Email or Payroll ID'**
  String get loginEmailOrPayroll;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get loginRequired;

  /// No description provided for @loginHint.
  ///
  /// In en, this message translates to:
  /// **'Use your work email or Payroll ID'**
  String get loginHint;

  /// No description provided for @dashboardGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning.'**
  String get dashboardGreetingMorning;

  /// No description provided for @dashboardGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon.'**
  String get dashboardGreetingAfternoon;

  /// No description provided for @dashboardGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening.'**
  String get dashboardGreetingEvening;

  /// No description provided for @dashboardHello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String dashboardHello(Object name);

  /// No description provided for @dashboardMyTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get dashboardMyTasks;

  /// No description provided for @dashboardProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get dashboardProjects;

  /// No description provided for @dashboardLeaveDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Leave Days Left'**
  String get dashboardLeaveDaysLeft;

  /// No description provided for @dashboardFieldInspections.
  ///
  /// In en, this message translates to:
  /// **'Field Inspections'**
  String get dashboardFieldInspections;

  /// No description provided for @dashboardOpenProjectCount.
  ///
  /// In en, this message translates to:
  /// **'Open project count'**
  String get dashboardOpenProjectCount;

  /// No description provided for @dashboardCaptureGps.
  ///
  /// In en, this message translates to:
  /// **'Capture GPS + photos'**
  String get dashboardCaptureGps;

  /// No description provided for @dashboardLogVisit.
  ///
  /// In en, this message translates to:
  /// **'Log a visit'**
  String get dashboardLogVisit;

  /// No description provided for @dashboardOverdueDue.
  ///
  /// In en, this message translates to:
  /// **'{overdue} overdue · {due} due ≤7d'**
  String dashboardOverdueDue(Object overdue, Object due);

  /// No description provided for @dashboardPendingApps.
  ///
  /// In en, this message translates to:
  /// **'{n} pending applications'**
  String dashboardPendingApps(Object n);

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks…'**
  String get tasksSearchHint;

  /// No description provided for @tasksAllStates.
  ///
  /// In en, this message translates to:
  /// **'All states'**
  String get tasksAllStates;

  /// No description provided for @tasksNoneMatch.
  ///
  /// In en, this message translates to:
  /// **'No tasks match the current filter.'**
  String get tasksNoneMatch;

  /// No description provided for @stateBacklog.
  ///
  /// In en, this message translates to:
  /// **'Backlog'**
  String get stateBacklog;

  /// No description provided for @stateInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get stateInProgress;

  /// No description provided for @stateChangesRequested.
  ///
  /// In en, this message translates to:
  /// **'Changes Requested'**
  String get stateChangesRequested;

  /// No description provided for @stateApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get stateApproved;

  /// No description provided for @stateDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stateDone;

  /// No description provided for @stateCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get stateCancelled;

  /// No description provided for @leaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveTitle;

  /// No description provided for @leaveBalances.
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get leaveBalances;

  /// No description provided for @leaveMyApps.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get leaveMyApps;

  /// No description provided for @leaveApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get leaveApply;

  /// No description provided for @leaveDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{n} left'**
  String leaveDaysLeft(Object n);

  /// No description provided for @leaveTaken.
  ///
  /// In en, this message translates to:
  /// **'{taken} taken · {pending} pending · {allowed} allowed'**
  String leaveTaken(Object taken, Object pending, Object allowed);

  /// No description provided for @leaveNoApps.
  ///
  /// In en, this message translates to:
  /// **'No leave applications yet.'**
  String get leaveNoApps;

  /// No description provided for @leavePendingLm.
  ///
  /// In en, this message translates to:
  /// **'Pending LM'**
  String get leavePendingLm;

  /// No description provided for @leaveAwaitingHr.
  ///
  /// In en, this message translates to:
  /// **'Awaiting HR'**
  String get leaveAwaitingHr;

  /// No description provided for @leaveRejectedLm.
  ///
  /// In en, this message translates to:
  /// **'Rejected by LM'**
  String get leaveRejectedLm;

  /// No description provided for @leaveApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get leaveApproved;

  /// No description provided for @leaveRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get leaveRejected;

  /// No description provided for @leaveApplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply for Leave'**
  String get leaveApplyTitle;

  /// No description provided for @leaveType.
  ///
  /// In en, this message translates to:
  /// **'Leave type'**
  String get leaveType;

  /// No description provided for @leaveTypeSelect.
  ///
  /// In en, this message translates to:
  /// **'Select leave type'**
  String get leaveTypeSelect;

  /// No description provided for @leaveStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get leaveStartDate;

  /// No description provided for @leaveEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get leaveEndDate;

  /// No description provided for @leaveChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose…'**
  String get leaveChooseDate;

  /// No description provided for @leaveReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get leaveReason;

  /// No description provided for @leaveReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Family event'**
  String get leaveReasonHint;

  /// No description provided for @leaveSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit application'**
  String get leaveSubmit;

  /// No description provided for @inspectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Field Inspections'**
  String get inspectionsTitle;

  /// No description provided for @inspectionsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get inspectionsNew;

  /// No description provided for @inspectionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No inspections yet.'**
  String get inspectionsEmpty;

  /// No description provided for @inspectionsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New\" to record your first site visit.'**
  String get inspectionsEmptyHint;

  /// No description provided for @inspectionDraftCount.
  ///
  /// In en, this message translates to:
  /// **'{n} draft(s) waiting to sync'**
  String inspectionDraftCount(Object n);

  /// No description provided for @inspectionSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get inspectionSyncNow;

  /// No description provided for @inspectionSavedAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Saved as draft — we\'ll upload when you\'re back online.'**
  String get inspectionSavedAsDraft;

  /// No description provided for @inspectionFormTitle.
  ///
  /// In en, this message translates to:
  /// **'New Field Inspection'**
  String get inspectionFormTitle;

  /// No description provided for @inspectionProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get inspectionProject;

  /// No description provided for @inspectionWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get inspectionWeather;

  /// No description provided for @inspectionProgressObserved.
  ///
  /// In en, this message translates to:
  /// **'Progress observed: {pct}%'**
  String inspectionProgressObserved(Object pct);

  /// No description provided for @inspectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get inspectionNotes;

  /// No description provided for @inspectionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'What did you observe?'**
  String get inspectionNotesHint;

  /// No description provided for @inspectionUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get inspectionUseLocation;

  /// No description provided for @inspectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get inspectionLocation;

  /// No description provided for @inspectionLocationName.
  ///
  /// In en, this message translates to:
  /// **'Site / location name (optional)'**
  String get inspectionLocationName;

  /// No description provided for @inspectionMedia.
  ///
  /// In en, this message translates to:
  /// **'Media ({n})'**
  String inspectionMedia(Object n);

  /// No description provided for @inspectionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get inspectionCamera;

  /// No description provided for @inspectionGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get inspectionGallery;

  /// No description provided for @inspectionFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get inspectionFiles;

  /// No description provided for @inspectionSave.
  ///
  /// In en, this message translates to:
  /// **'Save Inspection'**
  String get inspectionSave;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get profileBiometric;

  /// No description provided for @profileBiometricSub.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID to open the app'**
  String get profileBiometricSub;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get notificationsEmpty;

  /// No description provided for @teamLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Leave'**
  String get teamLeaveTitle;

  /// No description provided for @teamLeaveEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending leave from your team.'**
  String get teamLeaveEmpty;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ha'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'ha':
      return AppL10nHa();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
