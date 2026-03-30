import 'package:ngdart/angular.dart';

/// Public directives used by the button component.
const liButtonDirectives = <Object>[
  LiButtonComponent,
];

/// Button style type.
enum LiButtonStyle {
  solid,
  outline,
  flat,
  link,
}

/// Limitless/Bootstrap button component.
///
/// Renders a `<button>` element styled with Limitless CSS classes.
///
/// Usage:
/// ```html
/// <li-button variant="primary">Click me</li-button>
/// <li-button variant="danger" buttonStyle="outline" size="lg">Large</li-button>
/// <li-button variant="success" iconClass="ph-check" [rounded]="true">OK</li-button>
/// ```
@Component(
  selector: 'li-button',
  templateUrl: 'button_component.html',
  styleUrls: ['button_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiButtonComponent {
  /// Context color name: primary, secondary, success, danger, warning,
  /// info, light, dark, indigo, pink, purple, yellow, teal, white.
  @Input()
  String variant = 'primary';

  /// Button style: solid (default), outline, flat, or link.
  @Input()
  String buttonStyle = 'solid';

  /// Button size: sm, lg, or empty for default.
  @Input()
  String size = '';

  /// HTML button type attribute.
  @Input()
  String type = 'button';

  /// Whether the button is disabled.
  @Input()
  bool disabled = false;

  /// Applies rounded-pill styling.
  @Input()
  bool rounded = false;

  /// Makes the button an icon-only button (equal width and height).
  @Input()
  bool iconOnly = false;

  /// Optional icon CSS classes, e.g. ph-check or ph-lock.
  @Input()
  String iconClass = '';

  /// Icon position: start or end.
  @Input()
  String iconPosition = 'start';

  /// Labeled button mode: none, start, or end.
  /// When set, the icon is separated with a darker background.
  @Input()
  String labeledMode = 'none';

  /// Custom classes for the labeled icon container.
  @Input()
  String labeledIconClass = '';

  /// Additional CSS classes appended to the button element.
  @Input()
  String buttonClass = '';

  /// Whether the border should be transparent (outline/flat only).
  @Input()
  bool borderTransparent = false;

  /// Border width: 0 for default, 2 for thick, etc.
  @Input()
  int borderWidth = 0;

  /// Custom border color class, e.g. border-primary.
  @Input()
  String borderClass = '';

  /// Makes the button display as a vertical/floating button.
  @Input()
  bool floating = false;

  /// Applies Limitless loading state styling and disables interaction.
  @Input()
  bool loading = false;

  /// Adds the dropdown caret styling used by Limitless dropdown buttons.
  @Input()
  bool dropdownToggle = false;

  String get normalizedVariant {
    final v = variant.trim().toLowerCase();
    return v.isEmpty ? 'primary' : v;
  }

  String get normalizedButtonStyle {
    final s = buttonStyle.trim().toLowerCase();
    if (s == 'outline' || s == 'flat' || s == 'link') return s;
    return 'solid';
  }

  String get normalizedSize {
    final s = size.trim().toLowerCase();
    if (s == 'sm' || s == 'lg') return s;
    return '';
  }

  String get normalizedIconClass => iconClass.trim();
  bool get hasIcon => normalizedIconClass.isNotEmpty;

  String get normalizedLabeledMode {
    final m = labeledMode.trim().toLowerCase();
    if (m == 'start' || m == 'end') return m;
    return 'none';
  }

  bool get isLabeled => normalizedLabeledMode != 'none';
  bool get isLabeledStart => normalizedLabeledMode == 'start';
  bool get isLabeledEnd => normalizedLabeledMode == 'end';

  bool get showInlineStartIcon =>
      hasIcon &&
      !isLabeled &&
      !iconOnly &&
      !loading &&
      iconPosition.trim().toLowerCase() != 'end';

  bool get showInlineEndIcon =>
      hasIcon &&
      !isLabeled &&
      !iconOnly &&
      !loading &&
      iconPosition.trim().toLowerCase() == 'end';

  bool get showIconOnly => hasIcon && iconOnly && !loading;

  String get _baseColorClass {
    final style = normalizedButtonStyle;
    final v = normalizedVariant;
    if (style == 'link') return 'btn-link';
    if (style == 'outline') return 'btn-outline-$v';
    if (style == 'flat') return 'btn-flat-$v';
    return 'btn-$v';
  }

  String get _sizeClass {
    final s = normalizedSize;
    return s.isNotEmpty ? 'btn-$s' : '';
  }

  String get resolvedIconSizeClass {
    final s = normalizedSize;
    if (s == 'lg') return 'ph-lg';
    if (s == 'sm') return 'ph-sm';
    return '';
  }

  String get resolvedButtonClasses {
    return _joinClasses(<String>[
      'btn',
      _baseColorClass,
      _sizeClass,
      rounded ? 'rounded-pill' : '',
      iconOnly ? 'btn-icon' : '',
      isLabeled ? 'btn-labeled' : '',
      isLabeledStart ? 'btn-labeled-start' : '',
      isLabeledEnd ? 'btn-labeled-end' : '',
      floating ? 'flex-column' : '',
      borderTransparent ? 'border-transparent' : '',
      borderWidth > 0 ? 'border-width-$borderWidth' : '',
      loading ? 'btn-loading' : '',
      dropdownToggle ? 'dropdown-toggle' : '',
      borderClass,
      buttonClass,
    ]);
  }

  String get resolvedLabeledIconClasses {
    final custom = labeledIconClass.trim();
    final classes = <String>['btn-labeled-icon'];

    if (custom.isNotEmpty) {
      classes.add(custom);
    } else {
      final style = normalizedButtonStyle;
      final v = normalizedVariant;
      if (style == 'solid') {
        classes.addAll(<String>['bg-black', 'bg-opacity-20']);
      } else {
        classes.addAll(<String>['bg-$v', 'text-white']);
      }
    }

    if (rounded) {
      classes.add('rounded-pill');
    }

    return _joinClasses(classes);
  }

  String get resolvedStartIconClasses {
    return _joinClasses(<String>[normalizedIconClass, resolvedIconSizeClass, 'me-2']);
  }

  String get resolvedEndIconClasses {
    return _joinClasses(<String>[normalizedIconClass, resolvedIconSizeClass, 'ms-2']);
  }

  String get resolvedLabeledInnerIconClasses {
    if (loading) {
      return _joinClasses(<String>['ph-spinner', 'spinner', resolvedIconSizeClass]);
    }

    return _joinClasses(<String>[normalizedIconClass, resolvedIconSizeClass]);
  }

  String get resolvedIconOnlyClasses {
    return _joinClasses(<String>[normalizedIconClass, resolvedIconSizeClass]);
  }

  String get resolvedLoadingInlineIconClasses {
    return _joinClasses(<String>['ph-spinner', 'spinner', resolvedIconSizeClass, 'me-2']);
  }

  String get resolvedLoadingIconOnlyClasses {
    return _joinClasses(<String>['ph-spinner', 'spinner', resolvedIconSizeClass]);
  }

  String _joinClasses(List<String> classNames) {
    return classNames
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }
}
