import 'dart:html';

import 'package:limitless_ui_example/messages.i18n.dart';
import 'package:limitless_ui_example/messages_en.i18n.dart' as en;

enum DemoLocale { pt, en }

class DemoI18nService {
  DemoI18nService() {
    useBrowserLocale();
  }

  DemoLocale _locale = DemoLocale.pt;
  Messages _messages = Messages();

  DemoLocale get locale => _locale;
  Messages get t => _messages;
  bool get isPortuguese => _locale == DemoLocale.pt;
  bool get isEnglish => _locale == DemoLocale.en;

  void usePortuguese() {
    _locale = DemoLocale.pt;
    _messages = Messages();
  }

  void useEnglish() {
    _locale = DemoLocale.en;
    _messages = en.MessagesEn();
  }

  void useBrowserLocale() {
    final navigator = window.navigator as dynamic;
    final List<dynamic>? languages = navigator.languages as List<dynamic>?;
    final locale = (languages != null && languages.isNotEmpty
                ? languages.first?.toString()
                : window.navigator.language)
            ?.toLowerCase() ??
        'en';
    final language = locale.split(RegExp('[-_]')).first;

    if (language == 'pt') {
      usePortuguese();
      return;
    }

    useEnglish();
  }
}
