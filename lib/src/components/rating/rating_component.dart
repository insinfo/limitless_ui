import 'package:web/web.dart' as web;

import 'dart:async';

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import 'rating_config.dart';

@Component(
  selector: 'li-rating',
  templateUrl: 'rating_component.html',
  styleUrls: ['rating_component.css'],
  directives: [coreDirectives],
  providers: [ExistingProvider.forToken(ngValueAccessor, LiRatingComponent)],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiRatingComponent
    implements ControlValueAccessor<num?>, OnDestroy, AfterChanges {
  LiRatingComponent(
    this._changeDetectorRef, [
    @Optional() LiRatingConfig? config,
  ]) : _config = config ?? LiRatingConfig() {
    max = _config.max;
    readonly = _config.readonly;
    resettable = _config.resettable;
    size = _config.size;
    _syncIndexes();
  }

  final ChangeDetectorRef _changeDetectorRef;
  final LiRatingConfig _config;
  final StreamController<num> _rateChangeController =
      StreamController<num>.broadcast();
  final StreamController<num> _userValueChangeController =
      StreamController<num>.broadcast();
  final StreamController<num> _hoverController =
      StreamController<num>.broadcast();
  final StreamController<num> _leaveController =
      StreamController<num>.broadcast();

  num _rate = 0;
  num? _hoverRate;

  @Input()
  bool disabled = false;

  @Input()
  int max = 5;

  @Input()
  bool readonly = false;

  @Input()
  bool resettable = false;

  @Input()
  String ariaLabel = 'Rating';

  @Input()
  String? name;

  @Input()
  String size = 'lg';

  @Input()
  String activeClass = '';

  @Input()
  String inactiveClass = '';

  @Input()
  set rate(num? value) {
    _rate = _normalizeRate(value);
    _markForCheck();
  }

  num get rate => _rate;

  @Output()
  Stream<num> get rateChange => _rateChangeController.stream;

  @Output('userValueChange')
  Stream<num> get userValueChange => _userValueChangeController.stream;

  @Output()
  Stream<num> get hover => _hoverController.stream;

  @Output()
  Stream<num> get leave => _leaveController.stream;

  ChangeFunction<num?> _onChange = (num? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  List<int> starIndexes = const <int>[];

  bool get isInteractive => !readonly && !disabled;

  num get visualRate => _hoverRate ?? _rate;

  String get resolvedSizeClass {
    switch (size.trim().toLowerCase()) {
      case 'sm':
        return 'li-rating-sm';
      case 'md':
        return 'li-rating-md';
      default:
        return 'li-rating-lg';
    }
  }

  String get resolvedRootClass => _joinClasses(<String>[
        'li-rating',
        resolvedSizeClass,
        disabled ? 'is-disabled' : '',
        readonly ? 'is-readonly' : '',
      ]);

  String? get resolvedName => name;

  @HostBinding('class.d-inline-block')
  bool get hostClass => true;

  @override
  void ngAfterChanges() {
    if (max <= 0) {
      max = 1;
    }
    _syncIndexes();
    _rate = _normalizeRate(_rate);
    if (_hoverRate != null) {
      _hoverRate = _normalizeRate(_hoverRate);
    }
    _markForCheck();
  }

  int fillPercentage(int index) {
    return ((visualRate - index).clamp(0, 1) * 100).round();
  }

  String starClass(int index) {
    final isFilled = fillPercentage(index) > 0;
    return _joinClasses(<String>[
      'li-rating__star-button',
      isFilled ? 'is-active' : 'is-inactive',
      isFilled ? activeClass : inactiveClass,
    ]);
  }

  void preview(int value) {
    if (!isInteractive) {
      return;
    }
    _hoverRate = value;
    _hoverController.add(value);
    _markForCheck();
  }

  void resetPreview() {
    final previousHover = _hoverRate;
    _hoverRate = null;
    _leaveController.add(previousHover ?? _rate);
    _markForCheck();
  }

  void handleBlur() {
    _onTouched();
  }

  void handleKeyDown(web.KeyboardEvent event) {
    if (!isInteractive) {
      return;
    }

    switch (event.key) {
      case 'ArrowLeft':
      case 'ArrowDown':
        update(_rate - 1, emitUserValueChange: true);
        event.preventDefault();
        break;
      case 'ArrowRight':
      case 'ArrowUp':
        update(_rate + 1, emitUserValueChange: true);
        event.preventDefault();
        break;
      case 'Home':
        update(0, emitUserValueChange: true);
        event.preventDefault();
        break;
      case 'End':
        update(max, emitUserValueChange: true);
        event.preventDefault();
        break;
    }
  }

  void select(int value) {
    if (!isInteractive) {
      return;
    }
    final nextValue = resettable && _rate == value ? 0 : value;
    update(nextValue, emitUserValueChange: true);
  }

  void update(
    num? value, {
    bool emitToForm = true,
    bool emitUserValueChange = false,
  }) {
    final normalized = _normalizeRate(value);
    if (_rate != normalized) {
      _rate = normalized;
      _rateChangeController.add(_rate);
      if (emitUserValueChange) {
        _userValueChangeController.add(_rate);
      }
    }
    if (emitToForm) {
      _onChange(_rate, rawValue: _rate.toString());
      _onTouched();
    }
    _markForCheck();
  }

  @override
  void registerOnChange(ChangeFunction<num?> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void writeValue(num? value) {
    update(value, emitToForm: false);
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  Object trackByIndex(int index, dynamic item) => item as int;

  num _normalizeRate(num? value) {
    final normalizedValue = value ?? 0;
    if (normalizedValue < 0) {
      return 0;
    }
    if (normalizedValue > max) {
      return max;
    }
    return normalizedValue;
  }

  void _syncIndexes() {
    starIndexes = List<int>.generate(max, (int index) => index);
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngOnDestroy() {
    _rateChangeController.close();
    _userValueChangeController.close();
    _hoverController.close();
    _leaveController.close();
  }
}
