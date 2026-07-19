// ignore_for_file: unnecessary_cast

import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:ngx_dart/angular.dart';

/// Restricts keyboard and paste input to numeric characters only.
///
/// Example:
/// ```html
/// <input [liOnlyNumber]="true" name="phone" type="text">
/// ```
@Directive(selector: '[liOnlyNumber]')
class LiOnlyNumberDirective {
  late web.HTMLInputElement inputElement;
  final web.Element _el;

  @Input('liOnlyNumber')
  bool liOnlyNumber = true;

  LiOnlyNumberDirective(this._el) {
    if (!_el.isA<web.HTMLInputElement>()) {
      throw Exception(
          'LiOnlyNumberDirective has to be applied to an HTMLInputElement');
    }
    inputElement = _el as web.HTMLInputElement;
    if (liOnlyNumber) {
      inputElement.onKeyPress.listen(onlyNumberKey);
    }
    inputElement.onPaste.listen((e) {
      final regex = RegExp(r'^[0-9]*$');
      final data = e.clipboardData?.getData('text/plain');
      if (data != null && regex.hasMatch(data)) {
      } else {
        e.preventDefault();
      }
    });
  }

  /// Prevents non-digit key presses from reaching the input.
  void onlyNumberKey(web.KeyboardEvent evt) {
    if (!evt.ctrlKey &&
        !evt.metaKey &&
        !evt.altKey &&
        evt.key.length == 1 &&
        !RegExp(r'^\d$').hasMatch(evt.key)) {
      evt.preventDefault();
    }
  }
}
