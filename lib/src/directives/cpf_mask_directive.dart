import 'dart:html';

import 'package:ngdart/angular.dart';

@Directive(selector: '[cpfMask]')
class CpfMaskDirective {
  String mask = 'xxx.xxx.xxx-xx';
  int maxLength = 14;
  String escapeCharacter = 'x';
  late InputElement inputElement;
  final Element _el;
  var lastTextSize = 0;
  var lastTextValue = '';

  CpfMaskDirective(this._el) {
    lastTextSize = 0;
    if (_el is! InputElement) {
      throw Exception('CpfMaskDirective has to be applied to an InputElement');
    }
    inputElement = _el;
    inputElement.onInput.listen((e) {
      _onChange();
    });
  }

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