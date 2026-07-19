import 'dart:async';
import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

const liEditableTextValueAccessor = ExistingProvider.forToken(
  ngValueAccessor,
  LiEditableTextDirective,
);

/// Turns an element into editable text and optionally binds it to AngularDart
/// forms as a [ControlValueAccessor].
@Directive(
  selector: '[liEditableText]',
  providers: [liEditableTextValueAccessor],
)
class LiEditableTextDirective
    implements AfterChanges, OnDestroy, ControlValueAccessor<String?> {
  LiEditableTextDirective(this._element) {
    _inputSubscription = _element.onInput.listen((_) => _emitValue());
    _blurSubscription = _element.onBlur.listen((_) {
      onTouched();
      if (liEditableTextSubmitOnBlur) {
        _submit();
      }
    });
    _keydownSubscription = _element.onKeyDown.listen(_handleKeyDown);
  }

  final web.Element _element;
  StreamSubscription<web.Event>? _inputSubscription;
  StreamSubscription<web.Event>? _blurSubscription;
  StreamSubscription<web.KeyboardEvent>? _keydownSubscription;
  final _submitController = StreamController<String>.broadcast(sync: true);

  bool _disabled = false;
  String _value = '';

  /// Enables or disables editing.
  @Input('liEditableText')
  bool liEditableText = true;

  /// Maximum accepted text length. `null` means no limit.
  @Input()
  int? liEditableTextMaxLength;

  /// Trims text before notifying the form model and submit output.
  @Input()
  bool liEditableTextTrim = false;

  /// Emits submit and prevents a newline when Enter is pressed.
  @Input()
  bool liEditableTextSubmitOnEnter = true;

  /// Emits submit and prevents the default action when Escape is pressed.
  @Input()
  bool liEditableTextSubmitOnEscape = true;

  /// Emits submit when the element loses focus.
  @Input()
  bool liEditableTextSubmitOnBlur = false;

  /// Emits the current value when a configured submit interaction happens.
  @Output('liEditableTextSubmit')
  Stream<String> get liEditableTextSubmit => _submitController.stream;

  ChangeFunction<String?> onChange = (String? _, {String? rawValue}) {};
  TouchFunction onTouched = () {};

  @override
  void ngAfterChanges() {
    _syncEditableState();
  }

  @override
  void writeValue(String? value) {
    _value = value ?? '';
    if ((_element as web.HTMLElement).innerText != _value) {
      _element.innerText = _value;
    }
    _syncEditableState();
  }

  @override
  void registerOnChange(ChangeFunction<String?> fn) {
    onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    onTouched = fn;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _disabled = isDisabled;
    _syncEditableState();
  }

  void _handleKeyDown(web.KeyboardEvent event) {
    final key = event.key;
    if (liEditableTextSubmitOnEnter && key == 'Enter') {
      event.preventDefault();
      _submit();
      return;
    }
    if (liEditableTextSubmitOnEscape && key == 'Escape') {
      event.preventDefault();
      _submit();
      return;
    }

    final maxLength = liEditableTextMaxLength;
    if (maxLength == null || _currentValue().length < maxLength) {
      return;
    }
    const editingKeys = <String>{
      'Backspace',
      'Delete',
      'ArrowLeft',
      'ArrowRight',
      'ArrowUp',
      'ArrowDown',
      'Home',
      'End',
    };
    if (!editingKeys.contains(key) && !_hasSelectedText()) {
      event.preventDefault();
    }
  }

  void _emitValue() {
    final value = _currentValue();
    _value = value;
    onChange(value, rawValue: value);
  }

  void _submit() {
    _emitValue();
    _submitController.add(_value);
  }

  String _currentValue() {
    final text = (_element as web.HTMLElement).innerText;
    return liEditableTextTrim ? text.trim() : text;
  }

  bool _hasSelectedText() {
    final selection = web.window.getSelection();
    return selection != null &&
        selection.toString().isNotEmpty &&
        selection.anchorNode?.parentNode == _element;
  }

  void _syncEditableState() {
    if (liEditableText && !_disabled) {
      _element.setAttribute('contenteditable', 'true');
    } else {
      _element.removeAttribute('contenteditable');
    }
  }

  @override
  void ngOnDestroy() {
    _inputSubscription?.cancel();
    _blurSubscription?.cancel();
    _keydownSubscription?.cancel();
    _submitController.close();
  }
}
