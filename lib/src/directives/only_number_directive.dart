// ignore_for_file: unnecessary_cast

import 'dart:html';
import 'package:ngx_dart/angular.dart';

/// Restricts keyboard and paste input to numeric characters only.
///
/// Example:
/// ```html
/// <input [liOnlyNumber]="true" name="phone" type="text">
/// ```
@Directive(selector: '[liOnlyNumber]')
class LiOnlyNumberDirective {
  late InputElement inputElement;
  final Element _el;

  @Input('liOnlyNumber')
  bool liOnlyNumber = true;

  LiOnlyNumberDirective(this._el) {
    if (_el is! InputElement) {
      throw Exception(
          'LiOnlyNumberDirective has to be applied to an InputElement');
    }
    inputElement = _el as InputElement;
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
  void onlyNumberKey(KeyboardEvent evt) {
    final whichCode = evt.which;
    final asciiCode =
        (whichCode == null || whichCode == 0) ? evt.keyCode : whichCode;
    if (asciiCode > 31 && (asciiCode < 48 || asciiCode > 57)) {
      evt.preventDefault();
    }
  }
}
