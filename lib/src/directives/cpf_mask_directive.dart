import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:essential_core/essential_core.dart';
import 'package:ngx_dart/angular.dart';

/// Applies a CPF mask to a text input as the user types.
///
/// The directive expects to run on an [web.HTMLInputElement] and delegates the
/// `000.000.000-00` mask and cursor handling to `essential_core`.
@Directive(selector: '[liCpfMask]')
class LiCpfMaskDirective implements OnDestroy {
  final InteractiveTextMask _mask = InteractiveTextMask.cpf();
  late web.HTMLInputElement inputElement;
  final web.Element _el;
  late final web.EventListener _inputListener;
  var _lastValue = MaskedTextValue.collapsed('');

  LiCpfMaskDirective(this._el) {
    if (!_el.isA<web.HTMLInputElement>()) {
      throw Exception(
          'LiCpfMaskDirective has to be applied to an HTMLInputElement');
    }
    inputElement = _el as web.HTMLInputElement;
    _lastValue = MaskedTextValue.collapsed(inputElement.value);
    _inputListener = ((web.Event event) => _onChange()).toJS;
    inputElement.addEventListener('input', _inputListener, true.toJS);
  }

  /// Applies the CPF mask to the current input value.
  void _onChange() {
    final result = _mask.applyEdit(
      oldValue: _lastValue,
      newValue: MaskedTextValue(
        text: inputElement.value,
        selectionStart: inputElement.selectionStart,
        selectionEnd: inputElement.selectionEnd,
      ),
    );

    inputElement.value = result.text;
    inputElement.setSelectionRange(result.selectionStart, result.selectionEnd);
    _lastValue = result;
  }

  @override
  void ngOnDestroy() {
    inputElement.removeEventListener('input', _inputListener, true.toJS);
  }
}
