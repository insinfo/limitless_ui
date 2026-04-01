import 'dart:html';

import 'package:ngdart/angular.dart';

/// Immutable configuration object for [TextMaskDirective].
class TextMaskConfig {
  final String mask;
  final int maxLength;
  TextMaskConfig({this.mask = 'xxx.xxx.xxx-xx', this.maxLength = 14});
}

/// Applies an arbitrary character mask to a text input as the user types.
///
/// The directive uses `x` as the editable placeholder character. Any other
/// character in the mask is inserted automatically.
@Directive(selector: '[textMask]')
class TextMaskDirective {
  Map<String, dynamic> _textMask = {};

  @Input()
  set textMask(Map<String, dynamic> val) {
    _textMask = val;

    mask = _textMask.containsKey('mask') ? _textMask['mask'] : 'xxx.xxx.xxx-xx';
    maxLength = (_textMask.containsKey('maxLength')
        ? int.parse(_textMask['maxLength'].toString())
        : mask.length);
  }

  String mask = 'xxx.xxx.xxx-xx';
  int maxLength = 14;
  String escapeCharacter = 'x';
  late InputElement inputElement;
  final Element _el;
  var lastTextSize = 0;
  var lastTextValue = '';

  TextMaskDirective(this._el) {
    if (_el is! InputElement) {
      throw Exception('TextMaskDirective has to be applied to an InputElement');
    }
    mask = _textMask.containsKey('mask') ? _textMask['mask'] : 'xxx.xxx.xxx-xx';
    maxLength = (_textMask.containsKey('maxLength')
        ? int.parse(_textMask['maxLength'].toString())
        : mask.length);

    lastTextSize = 0;
    inputElement = _el;
    inputElement.onInput.listen((e) {
      _onChange();
    });
  }

  /// Rebuilds the input value after each user change.
  void _onChange() {
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

        if (inputElement.selectionStart! < inputElement.value!.length) {
          inputElement.setSelectionRange(
              inputElement.value!.length, inputElement.value!.length);
          inputElement.select();
        }
      }
      // update cursor position
      lastTextSize = inputElement.value!.length;
      lastTextValue = inputElement.value!;
    } else {
      inputElement.value = lastTextValue;
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
