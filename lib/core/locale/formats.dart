import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Locale-aware formatters used everywhere in the app.
/// Hausa (`ha`) gets its own short month list since the bundled intl
/// package doesn't ship one out of the box.
class AppFormats {
  static bool _intlInitialised = false;

  /// Call once at startup.
  static Future<void> init() async {
    if (_intlInitialised) return;
    await initializeDateFormatting('en');
    // initializeDateFormatting throws on unsupported locales; load 'en' only.
    _intlInitialised = true;
  }

  /// Hausa short month names (Janairu, Faburairu, …) for manual formatting.
  static const _haShortMonths = [
    '', 'Jan', 'Fab', 'Mar', 'Afr', 'May', 'Yun', 'Yul', 'Aug', 'Sat', 'Okt', 'Nuw', 'Dis',
  ];

  static const _haFullMonths = [
    '', 'Janairu', 'Faburairu', 'Maris', 'Afrilu', 'Mayu', 'Yuni',
    'Yuli', 'Agusta', 'Satumba', 'Oktoba', 'Nuwamba', 'Disamba',
  ];

  /// Format a date as e.g. "5 May 2026" / "5 May 2026".
  /// Falls back to ISO if the date is null.
  static String date(DateTime? d, BuildContext context) {
    if (d == null) return '';
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ha') {
      return '${d.day} ${_haShortMonths[d.month]} ${d.year}';
    }
    return DateFormat.yMMMd('en').format(d);
  }

  /// Same as [date] but parses an ISO yyyy-MM-dd string first.
  static String dateString(String? iso, BuildContext context) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return date(DateTime.parse(iso), context);
    } catch (_) {
      return iso;
    }
  }

  /// Long month name in the active locale.
  static String monthLong(int month, BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ha') return _haFullMonths[month];
    return DateFormat.MMMM('en').format(DateTime(2000, month, 1));
  }

  /// Locale-aware integer (thousand separators).
  static String number(num value, BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return NumberFormat.decimalPattern(code).format(value);
  }
}
