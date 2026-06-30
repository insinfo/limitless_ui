import 'dart:html' as html;

import 'package:ngdart/angular.dart';

/// Writes an explicit non-standard autocomplete token to discourage browser
/// autofill without capturing the native `autocomplete` attribute.
@Directive(selector: '[liDisableBrowserAutocomplete]')
class LiDisableBrowserAutocompleteDirective implements OnInit, AfterChanges {
  LiDisableBrowserAutocompleteDirective(this._element) {
    _originalAutocomplete = _element.getAttribute('autocomplete');
  }

  final html.Element _element;
  String? _originalAutocomplete;

  /// Enables the autocomplete override.
  @Input('liDisableBrowserAutocomplete')
  bool liDisableBrowserAutocomplete = true;

  /// Optional exact token to write into `autocomplete`.
  @Input()
  String? liAutocompleteValue;

  /// Prefix used when [liAutocompleteValue] is omitted.
  @Input()
  String liAutocompletePrefix = 'new';

  @override
  void ngOnInit() {
    _syncAutocomplete();
  }

  @override
  void ngAfterChanges() {
    _syncAutocomplete();
  }

  void _syncAutocomplete() {
    if (!liDisableBrowserAutocomplete) {
      final original = _originalAutocomplete;
      if (original == null) {
        _element.attributes.remove('autocomplete');
      } else {
        _element.setAttribute('autocomplete', original);
      }
      return;
    }

    final explicit = liAutocompleteValue?.trim() ?? '';
    final value = explicit.isNotEmpty
        ? explicit
        : '${liAutocompletePrefix.trim()}-${_element.attributes['name'] ?? 'field'}';
    _element.setAttribute('autocomplete', value);
  }
}
