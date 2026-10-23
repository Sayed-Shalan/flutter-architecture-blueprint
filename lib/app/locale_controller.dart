import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { system, english, arabic }

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void use(AppLanguage language) {
    state = switch (language) {
      AppLanguage.system => null,
      AppLanguage.english => const Locale('en'),
      AppLanguage.arabic => const Locale('ar'),
    };
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
