import 'dart:js_interop';

import 'package:ngx_dart/security.dart' show DomSanitizationService;
import 'package:web/web.dart';

final DomSanitizationService _sanitizer = DomSanitizationService();

String _sanitize(String value) => _sanitizer.sanitizeHtml(value) ?? '';

/// Reads the string branch of the Web IDL `innerHTML` union.
String readHtml(Element element) =>
    (element.innerHTML as JSString?)?.toDart ?? '';

/// Replaces [element]'s HTML after applying the Angular sanitizer.
void setSanitizedHtml(Element element, String value) {
  element.innerHTML = _sanitize(value).toJS;
}

/// Appends HTML after applying the Angular sanitizer.
void appendSanitizedHtml(Element element, String value) {
  element.insertAdjacentHTML('beforeend', _sanitize(value).toJS);
}

/// Replaces [element]'s HTML without sanitization.
///
/// Callers must only pass framework-owned markup or content already proven
/// safe. The explicit name keeps this security boundary visible in reviews.
void setTrustedHtml(Element element, String value) {
  element.innerHTML = value.toJS;
}
