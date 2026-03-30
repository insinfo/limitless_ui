import 'dart:async';

import 'package:ngdart/angular.dart';

/// Public directives used by the alerts component.
const liAlertDirectives = <Object>[
  LiAlertComponent,
];

/// Limitless/Bootstrap alert component.
@Component(
  selector: 'li-alert',
  templateUrl: 'alert_component.html',
  styleUrls: ['alert_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiAlertComponent implements OnDestroy {
  final _visibleChangeController = StreamController<bool>.broadcast(sync: true);
  final _dismissedController = StreamController<void>.broadcast(sync: true);

  /// Context color name, e.g. primary, success, danger, indigo, or teal.
  @Input()
  String variant = 'primary';

  /// Uses solid background styling instead of alert-[variant].
  @Input()
  bool solid = false;

  /// Shows the close button and enables dismiss behavior.
  @Input()
  bool dismissible = false;

  /// Controls alert visibility.
  @Input()
  bool visible = true;

  /// Removes the default border.
  @Input()
  bool borderless = false;

  /// Applies Limitless rounded-pill styling.
  @Input()
  bool roundedPill = false;

  /// Prevents wrapping and truncates long content.
  @Input()
  bool truncated = false;

  /// Adds Bootstrap fade/show classes.
  @Input()
  bool fade = true;

  /// Optional icon CSS classes, e.g. ph-info or ph-warning-circle.
  @Input()
  String iconClass = '';

  /// Icon render mode: none, block, or inline.
  @Input()
  String iconMode = 'none';

  /// Icon alignment: start or end.
  @Input()
  String iconPosition = 'start';

  /// Optional extra classes appended to the alert container.
  @Input()
  String alertClass = '';

  /// Optional classes appended to the block icon wrapper.
  @Input()
  String iconContainerClass = '';

  /// Optional text color classes appended to the alert container.
  @Input()
  String textClass = '';

  /// Forces the dismiss button to the white variant.
  @Input()
  bool closeButtonWhite = false;

  /// Optional ARIA role override.
  @Input()
  String role = 'alert';

  @Output()
  Stream<bool> get visibleChange => _visibleChangeController.stream;

  @Output()
  Stream<void> get dismissed => _dismissedController.stream;

  String get normalizedVariant {
    final currentVariant = variant.trim().toLowerCase();
    if (currentVariant.isEmpty) {
      return 'primary';
    }

    return currentVariant;
  }

  String get normalizedIconMode {
    final currentMode = iconMode.trim().toLowerCase();
    if (currentMode == 'block' || currentMode == 'inline') {
      return currentMode;
    }

    return 'none';
  }

  String get normalizedIconPosition {
    return iconPosition.trim().toLowerCase() == 'end' ? 'end' : 'start';
  }

  String get normalizedIconClass => iconClass.trim();

  bool get hasIcon => normalizedIconClass.isNotEmpty;

  bool get showBlockIcon => hasIcon && normalizedIconMode == 'block';

  bool get showInlineStartIcon {
    return hasIcon &&
        normalizedIconMode == 'inline' &&
        normalizedIconPosition == 'start';
  }

  bool get showInlineEndIcon {
    return hasIcon &&
        normalizedIconMode == 'inline' &&
        normalizedIconPosition == 'end';
  }

  String get resolvedTextClass {
    final currentTextClass = textClass.trim();
    if (currentTextClass.isNotEmpty) {
      return currentTextClass;
    }

    if (solid) {
      return 'text-white';
    }

    return '';
  }

  String get resolvedAlertClasses {
    return _joinClasses(<String>[
      'alert',
      solid ? 'bg-$normalizedVariant' : 'alert-$normalizedVariant',
      resolvedTextClass,
      dismissible ? 'alert-dismissible' : '',
      borderless ? 'border-0' : '',
      roundedPill ? 'rounded-pill' : '',
      truncated ? 'text-truncate' : '',
      fade ? 'fade' : '',
      fade && visible ? 'show' : '',
      showBlockIcon && normalizedIconPosition == 'start'
          ? 'alert-icon-start'
          : '',
      showBlockIcon && normalizedIconPosition == 'end' ? 'alert-icon-end' : '',
      alertClass,
    ]);
  }

  String get resolvedBlockIconClasses {
    final customClasses = iconContainerClass.trim();
    final defaultClasses =
        solid ? 'bg-black bg-opacity-20' : 'bg-$normalizedVariant text-white';

    return _joinClasses(<String>[
      'alert-icon',
      customClasses.isNotEmpty ? customClasses : defaultClasses,
      roundedPill ? 'rounded-pill' : '',
    ]);
  }

  String get resolvedInlineStartIconClasses {
    return _joinClasses(<String>[normalizedIconClass, 'me-2']);
  }

  String get resolvedInlineEndIconClasses {
    return _joinClasses(<String>[normalizedIconClass, 'float-end', 'ms-2']);
  }

  String get resolvedCloseButtonClasses {
    return _joinClasses(<String>[
      'btn-close',
      resolvedCloseButtonWhite ? 'btn-close-white' : '',
      roundedPill ? 'rounded-pill' : '',
    ]);
  }

  bool get resolvedCloseButtonWhite => closeButtonWhite || solid;

  void dismiss() {
    if (!visible) {
      return;
    }

    visible = false;
    _visibleChangeController.add(false);
    _dismissedController.add(null);
  }

  void show() {
    if (visible) {
      return;
    }

    visible = true;
    _visibleChangeController.add(true);
  }

  void toggle() {
    if (visible) {
      dismiss();
      return;
    }

    show();
  }

  @override
  void ngOnDestroy() {
    _visibleChangeController.close();
    _dismissedController.close();
  }

  String _joinClasses(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }
}
