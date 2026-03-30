import '../../messages.i18n.dart';
import '../../messages_en.i18n.dart' as en;

enum DemoLocale { pt, en }

class DemoI18nService {
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
}
