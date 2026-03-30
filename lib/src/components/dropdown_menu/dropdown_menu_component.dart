import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';

/// Public directives used by the dropdown menu component.
const liDropdownMenuDirectives = <Object>[
  LiDropdownMenuComponent,
];

class LiDropdownMenuOption {
  const LiDropdownMenuOption({
    this.value = '',
    this.label = '',
    this.iconClass = '',
    this.description = '',
    this.disabled = false,
    this.divider = false,
  });

  final String value;
  final String label;
  final String iconClass;
  final String description;
  final bool disabled;
  final bool divider;
}

@Component(
  selector: 'li-dropdown-menu',
  templateUrl: 'dropdown_menu_component.html',
  styleUrls: ['dropdown_menu_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiDropdownMenuComponent implements OnDestroy {
  LiDropdownMenuComponent(this._rootElement, this._changeDetectorRef) {
    _documentClickSubscription = document.onClick.listen(_handleDocumentClick);
    _documentKeySubscription = document.onKeyDown.listen(_handleDocumentKeyDown);
  }

  final Element _rootElement;
  final ChangeDetectorRef _changeDetectorRef;

  StreamSubscription<Event>? _documentClickSubscription;
  StreamSubscription<KeyboardEvent>? _documentKeySubscription;

  @Input()
  List<LiDropdownMenuOption> options = const <LiDropdownMenuOption>[];

  @Input()
  String value = '';

  @Input()
  String ariaLabel = '';

  @Input()
  String triggerLabel = '';

  @Input()
  String triggerIconClass = '';

  @Input()
  String triggerClass = 'btn btn-outline-primary btn-sm';

  @Input()
  String menuClass = 'dropdown-menu-end';

  /// Dropdown direction: dropdown, dropup, dropstart, or dropend.
  @Input()
  String placement = 'dropdown';

  @Input()
  bool showCaret = true;

  @Input()
  bool rounded = false;

  @Input()
  bool closeOnSelect = true;

  @Output()
  Stream<String> get valueChange => _valueChange.stream;

  final _valueChange = StreamController<String>.broadcast();

  bool isOpen = false;

  String get resolvedHostClasses {
    final normalizedPlacement = placement.trim().toLowerCase();
    final placementClass = switch (normalizedPlacement) {
      'dropup' => 'dropup',
      'dropstart' => 'dropstart',
      'dropend' => 'dropend',
      _ => 'dropdown',
    };

    return _joinClasses(<String>[
      placementClass,
      isOpen ? 'show' : '',
    ]);
  }

  String get resolvedTriggerClasses {
    return _joinClasses(<String>[
      triggerClass,
      usesNavbarTrigger ? 'li-dropdown-trigger-reset' : '',
      showCaret ? 'dropdown-toggle' : '',
      rounded ? 'rounded-pill' : '',
      triggerIconClass.trim().isNotEmpty ? 'd-inline-flex align-items-center' : '',
    ]);
  }

  String get resolvedTriggerIconClasses {
    return _joinClasses(<String>[
      triggerIconClass.trim(),
      triggerLabel.trim().isNotEmpty ? 'me-2' : '',
    ]);
  }

  String get resolvedMenuClasses {
    return _joinClasses(<String>[
      'dropdown-menu',
      menuClass,
      isOpen ? 'show' : '',
    ]);
  }

  bool get usesNavbarTrigger => triggerClass.contains('navbar-nav-link');

  bool isSelected(LiDropdownMenuOption option) => option.value == value;

  String resolvedItemClasses(LiDropdownMenuOption option) {
    return _joinClasses(<String>[
      'dropdown-item',
      option.description.isNotEmpty || option.iconClass.trim().isNotEmpty
          ? 'd-flex align-items-start'
          : '',
      isSelected(option) ? 'active' : '',
    ]);
  }

  String resolvedItemIconClasses(LiDropdownMenuOption option) {
    return _joinClasses(<String>[option.iconClass.trim(), 'me-2 mt-1']);
  }

  void toggleDropdown(MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();
    isOpen = !isOpen;
    _changeDetectorRef.markForCheck();
  }

  void selectOption(LiDropdownMenuOption option, MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();

    if (option.disabled || option.divider) {
      return;
    }

    _valueChange.add(option.value);

    if (closeOnSelect) {
      isOpen = false;
      _changeDetectorRef.markForCheck();
    }
  }

  void _handleDocumentClick(Event event) {
    final target = event.target;
    if (!isOpen || target is! Node) {
      return;
    }

    if (_rootElement.contains(target)) {
      return;
    }

    isOpen = false;
    _changeDetectorRef.markForCheck();
  }

  void _handleDocumentKeyDown(KeyboardEvent event) {
    if (!isOpen || event.key != 'Escape') {
      return;
    }

    isOpen = false;
    _changeDetectorRef.markForCheck();
  }

  String _joinClasses(List<String> classNames) {
    return classNames
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  @override
  void ngOnDestroy() {
    _documentClickSubscription?.cancel();
    _documentKeySubscription?.cancel();
    _valueChange.close();
  }
}
