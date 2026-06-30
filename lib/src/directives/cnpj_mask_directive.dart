import 'dart:html';

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';

/// Applies a CNPJ mask to a text input as the user types.
///
/// The mask accepts the Receita Federal alphanumeric CNPJ shape introduced in
/// `essential_core` 1.4.0: `AA.AAA.AAA/AAAA-00`. Letters are normalized to
/// uppercase and the cursor is preserved around mask literals.
@Directive(selector: '[liCnpjMask]')
class LiCnpjMaskDirective implements OnDestroy {
  final InteractiveTextMask _mask = InteractiveTextMask.cnpjAlphanumeric();
  late InputElement inputElement;
  final Element _el;
  late final EventListener _inputListener;
  var _lastValue = MaskedTextValue.collapsed('');

  LiCnpjMaskDirective(this._el) {
    if (_el is! InputElement) {
      throw Exception(
          'LiCnpjMaskDirective has to be applied to an InputElement');
    }
    inputElement = _el;
    _lastValue = MaskedTextValue.collapsed(inputElement.value ?? '');
    _inputListener = (event) => _onChange();
    inputElement.addEventListener('input', _inputListener, true);
  }

  /// Applies the CNPJ mask to the current input value.
  void _onChange() {
    final result = _mask.applyEdit(
      oldValue: _lastValue,
      newValue: MaskedTextValue(
        text: inputElement.value ?? '',
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
    inputElement.removeEventListener('input', _inputListener, true);
  }
}
