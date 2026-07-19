import 'dart:js_interop';
import 'dart:async';
import 'package:limitless_ui/web_compat.dart' as html;

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';

/// Form/container helper that centralizes common validation UI flows.
///
/// The directive is intentionally agnostic to business rules. Host apps can:
/// - rely on AngularDart validators and call [validate]
/// - set custom invalid/error state on fields and call [focusFirstInvalidLater]
///
/// This avoids page-level DOM hacks for the common "mark invalid + focus the
/// first failing field" interaction pattern.
@Directive(
  selector: '[liForm]',
  exportAs: 'liForm',
)
class LiFormDirective {
  LiFormDirective(
    this._hostElement, [
    @Optional() @Self() this._ngForm,
  ]);

  final html.Element _hostElement;
  final NgForm? _ngForm;
  final StreamController<bool> _submissionStateController =
      StreamController<bool>.broadcast(sync: true);

  bool _submitted = false;
  final List<LiFormFieldDirective> _registeredFields = <LiFormFieldDirective>[];
  int _nextRegistrationOrder = 0;

  /// CSS selector used to discover invalid controls inside the host tree.
  ///
  /// It supports:
  /// - library components that mirror invalid state via `data-invalid`
  /// - native/bootstrap-like controls using `.is-invalid`
  /// - AngularDart native form controls using `.ng-invalid`
  @Input('liFormInvalidSelector')
  String invalidSelector = '[data-invalid="true"], .is-invalid, .ng-invalid';

  /// CSS selector used to resolve the focus target from an invalid host.
  @Input('liFormFocusableSelector')
  String focusableSelector =
      'input:not([disabled]), textarea:not([disabled]), select:not([disabled]), button:not([disabled]), [href], [tabindex]:not([tabindex="-1"])';

  @HostBinding('attr.data-li-form-submitted')
  String? get submittedAttribute => _submitted ? 'true' : null;

  bool get hasNgForm => _ngForm?.form != null;

  bool get submitted => _submitted;

  Stream<bool> get submissionStateChanges => _submissionStateController.stream;

  /// Marks all AngularDart controls as touched and recalculates their validity.
  void markAllAsTouched() {
    final form = _ngForm?.form;
    if (form == null) {
      _submitted = true;
      _submissionStateController.add(true);
      return;
    }

    _visitControls(form, (control) {
      control.markAsTouched(updateParent: false);
      control.updateValueAndValidity(onlySelf: true, emitEvent: false);
    });

    form.markAsTouched(updateParent: true);
    form.updateValueAndValidity(onlySelf: true, emitEvent: false);
    _submitted = true;
    _submissionStateController.add(true);
  }

  /// Validates AngularDart controls inside this host, if present.
  ///
  /// Returns `true` when no invalid field is detected in the rendered DOM after
  /// the Angular form model has been marked as touched.
  bool validate() {
    markAllAsTouched();
    final formInvalid = _ngForm?.form?.invalid ?? false;
    return !formInvalid && !hasInvalidFields;
  }

  /// Validates and then focuses the first invalid field after the DOM settles.
  Future<bool> validateAndFocusFirstInvalid({bool scroll = true}) async {
    markAllAsTouched();
    await Future<void>.microtask(() {});
    final nextFrame = Completer<void>();
    html.window.liRequestAnimationFrame((_) {
      if (!nextFrame.isCompleted) {
        nextFrame.complete();
      }
    });
    await nextFrame.future;

    final formInvalid = _ngForm?.form?.invalid ?? false;
    final isValid = !formInvalid && !hasInvalidFields;
    if (!isValid) {
      focusFirstInvalid(scroll: scroll);
    }
    return isValid;
  }

  bool get hasInvalidFields => _findFirstInvalidFocusTarget() != null;

  /// Focuses the first invalid field using the current rendered DOM state.
  bool focusFirstInvalid({bool scroll = true}) {
    final target = _findFirstInvalidFocusTarget();
    if (target == null) {
      return false;
    }

    if (scroll) {
      target.scrollIntoView();
    }
    target.focus();
    return true;
  }

  /// Waits for the next microtask before resolving invalid UI and focusing.
  ///
  /// This is the safest entry point after host components update `[invalid]`,
  /// `[dataInvalid]`, or error maps inside the same click handler.
  Future<bool> focusFirstInvalidLater({bool scroll = true}) async {
    await Future<void>.microtask(() {});
    final nextFrame = Completer<void>();
    html.window.liRequestAnimationFrame((_) {
      if (!nextFrame.isCompleted) {
        nextFrame.complete();
      }
    });
    await nextFrame.future;
    return focusFirstInvalid(scroll: scroll);
  }

  void resetSubmissionState() {
    _submitted = false;
    _submissionStateController.add(false);
  }

  void registerField(LiFormFieldDirective field) {
    if (_registeredFields.contains(field)) {
      return;
    }

    field._registrationSequence = _nextRegistrationOrder++;
    _registeredFields.add(field);
  }

  void unregisterField(LiFormFieldDirective field) {
    _registeredFields.remove(field);
  }

  void _visitControls(
    AbstractControl control,
    void Function(AbstractControl control) visitor,
  ) {
    visitor(control);

    if (control is AbstractControlGroup) {
      for (final child in control.controls.values) {
        _visitControls(child, visitor);
      }
      return;
    }

    if (control is ControlArray) {
      for (final child in control.controls) {
        _visitControls(child, visitor);
      }
    }
  }

  html.HtmlElement? _findFirstInvalidFocusTarget() {
    final registeredTarget = _findFirstRegisteredInvalidFocusTarget();
    if (registeredTarget != null) {
      return registeredTarget;
    }

    final focusableNodes = _hostElement.queryAll(focusableSelector);
    for (final node in focusableNodes) {
      if (!node.isA<html.HtmlElement>() || !_isFocusable(node)) {
        continue;
      }

      final invalidAncestor = node.closest(invalidSelector);
      if ((invalidAncestor?.isA<html.Element>() ?? false) &&
          _hostElement.contains(invalidAncestor) &&
          _isUsableInvalidCandidate(invalidAncestor!)) {
        return node as html.HtmlElement;
      }
    }

    final invalidNodes = _hostElement.queryAll(invalidSelector);
    for (final node in invalidNodes) {
      if (!_isUsableInvalidCandidate(node)) {
        continue;
      }

      final target = _resolveFocusTarget(node);
      if (target != null) {
        return target;
      }
    }
    return null;
  }

  html.HtmlElement? _findFirstRegisteredInvalidFocusTarget() {
    if (_registeredFields.isEmpty) {
      return null;
    }

    final orderedFields = List<LiFormFieldDirective>.from(_registeredFields)
      ..sort((a, b) {
        if (a.hasExplicitPriority && b.hasExplicitPriority) {
          final priorityCompare = a.priority.compareTo(b.priority);
          if (priorityCompare != 0) {
            return priorityCompare;
          }
        } else if (a.hasExplicitPriority != b.hasExplicitPriority) {
          return a.hasExplicitPriority ? -1 : 1;
        }
        return a._registrationSequence.compareTo(b._registrationSequence);
      });

    for (final field in orderedFields) {
      if (!field.enabled ||
          !field.isInvalid(defaultInvalidSelector: invalidSelector)) {
        continue;
      }

      final target = field.resolveFocusTarget(
        defaultFocusableSelector: focusableSelector,
      );
      if (target != null) {
        return target;
      }
    }

    return null;
  }

  bool _isUsableInvalidCandidate(html.Element element) {
    if (element == _hostElement || element.isA<html.FormElement>()) {
      return false;
    }
    if (element.hasAttribute('disabled') ||
        element.getAttribute('aria-disabled') == 'true') {
      return false;
    }
    return true;
  }

  html.HtmlElement? _resolveFocusTarget(html.Element element) {
    if (_isFocusable(element)) {
      return element as html.HtmlElement;
    }

    final nested = element.querySelector(focusableSelector);
    if ((nested?.isA<html.HtmlElement>() ?? false) && _isFocusable(nested!)) {
      return nested as html.HtmlElement;
    }

    return null;
  }

  bool _isFocusable(html.Element element) {
    if (!element.isA<html.HtmlElement>()) {
      return false;
    }

    if (element.hasAttribute('disabled') ||
        element.getAttribute('aria-disabled') == 'true') {
      return false;
    }

    if (element.isA<html.InputElement>() ||
        element.isA<html.TextAreaElement>() ||
        element.isA<html.SelectElement>() ||
        element.isA<html.ButtonElement>()) {
      return true;
    }

    if (element.isA<html.AnchorElement>()) {
      return (element as html.AnchorElement).href.trim().isNotEmpty;
    }

    final tabindex = element.getAttribute('tabindex');
    return tabindex != null && tabindex != '-1';
  }
}

@Directive(
  selector: '[liFormField]',
  exportAs: 'liFormField',
)
class LiFormFieldDirective implements AfterChanges, OnDestroy {
  LiFormFieldDirective(
    this._hostElement, [
    @Optional() LiFormDirective? form,
  ]) : _form = form {
    _form?.registerField(this);
  }

  static const String _defaultPreferredFocusTargetSelector =
      '[data-li-form-focus-target="true"]';

  final html.Element _hostElement;
  final LiFormDirective? _form;

  int _registrationSequence = 0;
  int? _priority;

  @Input('liFormField')
  String fieldName = '';

  @Input('liFormFieldOrder')
  set priority(int? value) {
    _priority = value;
  }

  int get priority => _priority ?? 0;

  bool get hasExplicitPriority => _priority != null;

  @Input('liFormFieldTarget')
  String targetSelector = '';

  @Input('liFormFieldInvalidSelector')
  String invalidSelector = '';

  @Input('liFormFieldFocusableSelector')
  String focusableSelector = '';

  @Input('liFormFieldEnabled')
  bool enabled = true;

  @override
  void ngAfterChanges() {
    _form?.registerField(this);
  }

  @override
  void ngOnDestroy() {
    _form?.unregisterField(this);
  }

  bool isInvalid({required String defaultInvalidSelector}) {
    if (!enabled) {
      return false;
    }

    final selector = invalidSelector.trim().isEmpty
        ? defaultInvalidSelector
        : invalidSelector.trim();
    return _matchSelfOrDescendant(selector) != null;
  }

  html.HtmlElement? resolveFocusTarget({
    required String defaultFocusableSelector,
  }) {
    if (!enabled) {
      return null;
    }

    final resolvedFocusableSelector = focusableSelector.trim().isEmpty
        ? defaultFocusableSelector
        : focusableSelector.trim();

    final explicitTarget = _findMatchingSelfOrDescendant(targetSelector);
    if ((explicitTarget?.isA<html.HtmlElement>() ?? false) &&
        _isFocusable(
            explicitTarget as html.HtmlElement, resolvedFocusableSelector)) {
      return explicitTarget;
    }

    final preferredTarget = _findMatchingSelfOrDescendant(
      _defaultPreferredFocusTargetSelector,
    );
    if ((preferredTarget?.isA<html.HtmlElement>() ?? false) &&
        _isFocusable(
            preferredTarget as html.HtmlElement, resolvedFocusableSelector)) {
      return preferredTarget;
    }

    if (_hostElement.isA<html.HtmlElement>() &&
        _isFocusable(
            _hostElement as html.HtmlElement, resolvedFocusableSelector)) {
      return _hostElement;
    }

    final nestedTarget = _hostElement.querySelector(resolvedFocusableSelector);
    if ((nestedTarget?.isA<html.HtmlElement>() ?? false) &&
        _isFocusable(
            nestedTarget as html.HtmlElement, resolvedFocusableSelector)) {
      return nestedTarget;
    }

    return null;
  }

  html.Element? _matchSelfOrDescendant(String selector) {
    if (selector.trim().isEmpty) {
      return null;
    }

    final selfMatch = _findMatchingSelfOrDescendant(selector);
    if (!(selfMatch?.isA<html.Element>() ?? false)) {
      return null;
    }

    if (_isDisabled(selfMatch!)) {
      return null;
    }

    return selfMatch;
  }

  html.Element? _findMatchingSelfOrDescendant(String selector) {
    if (selector.trim().isEmpty) {
      return null;
    }

    if (_matchesSelector(_hostElement, selector)) {
      return _hostElement;
    }

    final nested = _hostElement.querySelector(selector);
    if ((nested?.isA<html.Element>() ?? false)) {
      return nested;
    }

    return null;
  }

  bool _matchesSelector(html.Element element, String selector) {
    try {
      return element.matches(selector);
    } catch (_) {
      return false;
    }
  }

  bool _isFocusable(html.HtmlElement element, String selector) {
    if (_isDisabled(element)) {
      return false;
    }

    if (_matchesSelector(element, selector)) {
      return true;
    }

    final tabindex = element.getAttribute('tabindex');
    return tabindex != null && tabindex != '-1';
  }

  bool _isDisabled(html.Element element) {
    if (element.hasAttribute('disabled')) {
      return true;
    }

    return element.getAttribute('aria-disabled') == 'true';
  }
}
