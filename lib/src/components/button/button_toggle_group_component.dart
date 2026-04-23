import 'dart:async';

import 'package:ngdart/angular.dart';

/// Public directives used by the button toggle group component.
const liButtonToggleGroupDirectives = <Object>[
  LiButtonToggleGroupComponent,
];

/// Declarative option used by [LiButtonToggleGroupComponent].
class LiButtonToggleOption {
  const LiButtonToggleOption({
    required this.value,
    required this.label,
    this.iconClass = '',
    this.title = '',
    this.disabled = false,
  });

  final String value;
  final String label;
  final String iconClass;
  final String title;
  final bool disabled;
}

/// Segmented button group for switching between a small set of options.
@Component(
  selector: 'li-button-toggle-group',
  templateUrl: 'button_toggle_group_component.html',
  styleUrls: ['button_toggle_group_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiButtonToggleGroupComponent {
  @Input()
  List<LiButtonToggleOption> options = const <LiButtonToggleOption>[];

  @Input()
  String value = '';

  @Input()
  String ariaLabel = '';

  /// Button size: sm, lg, or empty for default.
  @Input()
  String size = 'sm';

  /// Active option variant.
  @Input()
  String activeVariant = 'primary';

  /// Inactive option variant.
  @Input()
  String inactiveVariant = 'light';

  /// Active option style: solid, outline, flat, or link.
  @Input()
  String activeButtonStyle = 'solid';

  /// Inactive option style: solid, outline, flat, or link.
  @Input()
  String inactiveButtonStyle = 'outline';

  @Input()
  String groupClass = '';

  @Input()
  String buttonClass = '';

  @Input()
  bool rounded = false;

  @Output()
  Stream<String> get valueChange => _valueChange.stream;

  final _valueChange = StreamController<String>.broadcast();

  bool isSelected(LiButtonToggleOption option) => option.value == value;

  void select(LiButtonToggleOption option) {
    if (option.disabled || isSelected(option)) {
      return;
    }

    _valueChange.add(option.value);
  }

  String resolvedGroupClasses() {
    return _joinClasses(<String>[
      'btn-group',
      size.trim().isNotEmpty ? 'btn-group-${size.trim().toLowerCase()}' : '',
      groupClass,
    ]);
  }

  String resolvedButtonClasses(LiButtonToggleOption option) {
    final isActive = isSelected(option);
    final variant = isActive ? activeVariant : inactiveVariant;
    final style = isActive ? activeButtonStyle : inactiveButtonStyle;

    return _joinClasses(<String>[
      'btn',
      _buttonVariantClass(variant, style),
      rounded ? 'rounded-pill' : '',
      option.iconClass.trim().isNotEmpty
          ? 'd-inline-flex align-items-center'
          : '',
      buttonClass,
    ]);
  }

  String resolvedIconClasses(LiButtonToggleOption option) {
    return _joinClasses(<String>[option.iconClass.trim(), 'me-2']);
  }

  String _buttonVariantClass(String variant, String style) {
    final normalizedVariant =
        variant.trim().isEmpty ? 'primary' : variant.trim().toLowerCase();
    final normalizedStyle = style.trim().toLowerCase();

    switch (normalizedStyle) {
      case 'outline':
        return 'btn-outline-$normalizedVariant';
      case 'flat':
        return 'btn-flat-$normalizedVariant';
      case 'link':
        return 'btn-link';
      default:
        return 'btn-$normalizedVariant';
    }
  }

  String _joinClasses(List<String> classNames) {
    return classNames
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }
}
