// ignore_for_file: unnecessary_cast

import 'dart:html';
import 'package:ngdart/angular.dart';

/// Applies a CNPJ mask to a text input as the user types.
///
/// The directive formats values using the `xx.xxx.xxx/xxxx-xx` pattern and
/// keeps the caret at the end of the input while the mask is being expanded.
@Directive(selector: '[cnpjMask]')
class CnpjMaskDirective {
  String mask = 'xx.xxx.xxx/xxxx-xx';
  int maxLength = 18;
  String escapeCharacter = 'x';
  late InputElement inputElement;
  final Element _el;
  var lastTextSize = 0;
  var lastTextValue = '';

  CnpjMaskDirective(this._el) {
    lastTextSize = 0;
    if (_el is! InputElement) {
      throw Exception('CnpjMaskDirective has to be applied to an InputElement');
    }
    inputElement = _el as InputElement;
    inputElement.onInput.listen((e) {
      _onChange();
    });
  }

  /// Rebuilds the input value after each user change.
  void _onChange() {
    if (inputElement.value != null) {
      var text = inputElement.value!;

      if (text.length <= mask.length) {
        // its deleting text
        if (text.length < lastTextSize) {
          if (mask[text.length] != escapeCharacter) {
            //inputElement.focus();
            inputElement.setSelectionRange(
                inputElement.value!.length, inputElement.value!.length);
            inputElement.select();
          }
        } else {
          // its typing
          if (text.length >= lastTextSize) {
            var position = text.length;
            position = position <= 0 ? 1 : position;
            if (position < mask.length - 1) {
              if ((mask[position - 1] != escapeCharacter) &&
                  (text[position - 1] != mask[position - 1])) {
                inputElement.value = _buildText(text);
              }
              if (mask[position] != escapeCharacter) {
                inputElement.value = '${inputElement.value}${mask[position]}';
              }
            }
          }
          if (inputElement.selectionStart != null) {
            if (inputElement.selectionStart! < inputElement.value!.length) {
              inputElement.setSelectionRange(
                  inputElement.value!.length, inputElement.value!.length);
              inputElement.select();
            }
          }
        }
        // update cursor position
        lastTextSize = inputElement.value!.length;
        lastTextValue = inputElement.value!;
      } else {
        inputElement.value = lastTextValue;
      }
    }
  }

  /// Inserts the next literal mask character before the newly typed digit.
  String _buildText(String text) {
    var result = '';
    for (var i = 0; i < text.length - 1; i++) {
      result += text[i];
    }
    result += mask[text.length - 1];
    result += text[text.length - 1];
    return result;
  }
}
