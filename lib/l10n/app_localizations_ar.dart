// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الحجوزات';

  @override
  String get bookingsTitle => 'الحجوزات';

  @override
  String get emptyBookings => 'لا توجد حجوزات بعد';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loadFailed => 'تعذر تحميل الحجوزات';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get loadMoreFailed => 'تعذر تحميل المزيد من الحجوزات';

  @override
  String get createBooking => 'حجز جديد';

  @override
  String get bookingDetails => 'الحجز';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get customerLabel => 'العميل';

  @override
  String get startLabel => 'يبدأ';

  @override
  String get pickDate => 'اختر وقت البدء';

  @override
  String get save => 'حفظ';

  @override
  String get saving => 'جارٍ الحفظ';

  @override
  String get required => 'مطلوب';

  @override
  String get mustBeFuture => 'اختر وقتًا في المستقبل';

  @override
  String get notFound => 'الحجز غير موجود';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get networkError => 'الشبكة غير متاحة';

  @override
  String get timeoutError => 'انتهت مهلة الطلب';

  @override
  String get statusScheduled => 'مجدول';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'النظام';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';
}
