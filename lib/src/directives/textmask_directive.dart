import 'dart:html';

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';

/// Immutable configuration object for [LiTextMaskDirective].
class LiTextMaskConfig {
  /// Mask pattern consumed by [InteractiveTextMask].
  final String mask;

  /// Kept for compatibility with previous configuration maps.
  final int maxLength;

  /// Whether literals are inserted as soon as their preceding token group is
  /// complete.
  final bool eager;

  /// Character used to escape editable token characters in [mask].
  final String escapeCharacter;

  LiTextMaskConfig({
    this.mask = 'xxx.xxx.xxx-xx',
    this.maxLength = 14,
    this.eager = true,
    this.escapeCharacter = r'\',
  });
}

/// Applies an arbitrary character mask to a text input as the user types.
///
/// The directive delegates token filtering, literal insertion, and cursor
/// handling to [InteractiveTextMask]. Default editable tokens are the
/// `essential_core` tokens: `0` for digits, `A`/`x` for alphanumeric values,
/// `S` for letters, and `*` for any single code-unit character.
@Directive(selector: '[liTextMask]')
class LiTextMaskDirective implements OnDestroy {
  Map<String, dynamic> _liTextMask = const <String, dynamic>{};
  late InteractiveTextMask _maskFormatter;
  late final EventListener _inputListener;
  var _lastValue = MaskedTextValue.collapsed('');

  @Input()
  set liTextMask(dynamic val) {
    _liTextMask = _normalizeConfig(val);
    _configureMask();
    _applyCurrentValue();
  }

  String mask = 'xxx.xxx.xxx-xx';
  int maxLength = 14;
  bool eager = true;
  String escapeCharacter = r'\';
  late InputElement inputElement;
  final Element _el;

  LiTextMaskDirective(this._el) {
    if (_el is! InputElement) {
      throw Exception(
          'LiTextMaskDirective has to be applied to an InputElement');
    }
    inputElement = _el;
    _configureMask();
    _lastValue = MaskedTextValue.collapsed(inputElement.value ?? '');
    _inputListener = (event) => _onChange();
    inputElement.addEventListener('input', _inputListener, true);
  }

  /// Applies the configured mask to the current input value.
  void _onChange() {
    final result = _maskFormatter.applyEdit(
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

  Map<String, dynamic> _normalizeConfig(dynamic val) {
    if (val is LiTextMaskConfig) {
      return <String, dynamic>{
        'mask': val.mask,
        'maxLength': val.maxLength,
        'eager': val.eager,
        'escapeCharacter': val.escapeCharacter,
      };
    }
    if (val is Map) {
      return Map<String, dynamic>.from(val);
    }
    return const <String, dynamic>{};
  }

  void _configureMask() {
    final config = EssentialCoreUtils.mergeDefaults<String, dynamic>(
      _liTextMask,
      const <String, dynamic>{
        'mask': 'xxx.xxx.xxx-xx',
        'eager': true,
        'escapeCharacter': r'\',
      },
    );

    mask = EssentialCoreUtils.stringOrDefault(
      config['mask'],
      'xxx.xxx.xxx-xx',
    );
    maxLength =
        EssentialCoreUtils.toNullableInt(config['maxLength']) ?? mask.length;
    eager = EssentialCoreUtils.parseBoolLoose(config['eager']) ?? true;
    escapeCharacter = EssentialCoreUtils.stringOrDefault(
      config['escapeCharacter'],
      r'\',
    );

    _maskFormatter = InteractiveTextMask(
      pattern: mask,
      eager: eager,
      escapeCharacter: escapeCharacter,
    );
  }

  void _applyCurrentValue() {
    if (_el is! InputElement) {
      return;
    }

    final result = _maskFormatter.apply(
      MaskedTextValue(
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
