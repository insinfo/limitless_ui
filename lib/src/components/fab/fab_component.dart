import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

const liFabDirectives = <Object>[
  LiFabComponent,
  LiFabTriggerDirective,
  LiFabActionDirective,
];

class LiFabShortcut {
  const LiFabShortcut({
    required this.key,
    this.alt = false,
    this.ctrl = false,
    this.meta = false,
    this.shift = false,
    this.label = '',
  });

  final String key;
  final bool alt;
  final bool ctrl;
  final bool meta;
  final bool shift;
  final String label;

  bool matches(html.KeyboardEvent event) {
    final normalizedKey = key.trim().toLowerCase();
    final matchesKey = (event.key ?? '').toLowerCase() == normalizedKey ||
        (normalizedKey.length == 1 &&
            event.keyCode == normalizedKey.toUpperCase().codeUnitAt(0));

    return matchesKey &&
        event.altKey == alt &&
        event.ctrlKey == ctrl &&
        event.metaKey == meta &&
        event.shiftKey == shift;
  }

  String get resolvedLabel {
    if (label.trim().isNotEmpty) {
      return label.trim();
    }

    final parts = <String>[];
    if (ctrl) {
      parts.add('Ctrl');
    }
    if (alt) {
      parts.add('Alt');
    }
    if (shift) {
      parts.add('Shift');
    }
    if (meta) {
      parts.add('Meta');
    }
    parts.add(key.trim().toUpperCase());
    return parts.join('+');
  }
}

class LiFabAction {
  const LiFabAction({
    required this.iconClass,
    this.label = '',
    this.value,
    this.variant = 'light',
    this.buttonStyle = 'solid',
    this.buttonClass = '',
    this.disabled = false,
    this.href = '',
    this.target = '',
    this.rel = '',
    this.shortcut,
    this.lightLabel = false,
    this.labelAtEnd = false,
    this.alwaysShowLabel = false,
  });

  final String iconClass;
  final String label;
  final Object? value;
  final String variant;
  final String buttonStyle;
  final String buttonClass;
  final bool disabled;
  final String href;
  final String target;
  final String rel;
  final LiFabShortcut? shortcut;
  final bool lightLabel;
  final bool labelAtEnd;
  final bool alwaysShowLabel;
}

@Directive(selector: 'template[liFabTrigger]')
class LiFabTriggerDirective {
  LiFabTriggerDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liFabAction]')
class LiFabActionDirective {
  LiFabActionDirective(this.templateRef);

  final TemplateRef templateRef;
}

class LiFabTriggerTemplateContext {
  LiFabTriggerTemplateContext(this.fab);

  final LiFabComponent fab;

  bool get expanded => fab.isExpanded;

  bool get disabled => fab.disabled;

  bool get hasActions => fab.hasActions;

  String get label => fab.label;

  String get iconClass => fab.iconClass;

  String get openIconClass => fab.openIconClass;

  String get toggleMode => fab.resolvedToggleMode;

  void toggle() => fab.handleTriggerClick();

  void close() => fab.close();
}

class LiFabActionTemplateContext {
  LiFabActionTemplateContext(this.fab, this.action);

  final LiFabComponent fab;
  final LiFabAction action;

  bool get expanded => fab.isExpanded;

  bool get disabled => action.disabled;

  bool get isLink => fab.isLinkAction(action);

  Object? get value => action.value;

  String get label => action.label;

  String get iconClass => action.iconClass;

  String get shortcutLabel => fab.resolvedShortcutLabel(action);

  String get title => fab.resolvedActionTitle(action);

  String get tooltip => fab.resolvedActionTooltip(action);

  String get buttonClass => fab.resolvedActionClass(action);

  String get containerClass => fab.resolvedActionContainerClass(action);

  String? get href => fab.resolvedActionHref(action);

  String? get target => fab.resolvedActionTarget(action);

  String? get rel => fab.resolvedActionRel(action);

  void select([dynamic event]) => fab.handleActionClick(action, event);
}

@Component(
  selector: 'li-fab',
  templateUrl: 'fab_component.html',
  styleUrls: ['fab_component.css'],
  directives: [coreDirectives, LiFabTriggerDirective, LiFabActionDirective],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiFabComponent implements OnDestroy {
  LiFabComponent(this._changeDetectorRef) {
    _keyboardSubscription = html.window.onKeyDown.listen(_handleWindowKeyDown);
  }

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<LiFabAction> _actionSelectedController =
      StreamController<LiFabAction>.broadcast();
  final StreamController<bool> _expandedChangeController =
      StreamController<bool>.broadcast();
  late final LiFabTriggerTemplateContext triggerTemplateContext =
      LiFabTriggerTemplateContext(this);
  StreamSubscription<html.KeyboardEvent>? _keyboardSubscription;

  List<LiFabAction> _actions = const <LiFabAction>[];
  Map<LiFabAction, LiFabActionTemplateContext> _actionTemplateContexts =
      Map<LiFabAction, LiFabActionTemplateContext>.identity();
  bool _expanded = false;

  @ContentChild(LiFabTriggerDirective)
  LiFabTriggerDirective? projectedTriggerTemplate;

  @ContentChild(LiFabActionDirective)
  LiFabActionDirective? projectedActionTemplate;

  @Input()
  TemplateRef? triggerTemplate;

  @Input()
  TemplateRef? actionTemplate;

  @Input()
  set actions(List<LiFabAction>? value) {
    _actions = value ?? const <LiFabAction>[];
    _rebuildActionTemplateContexts();
  }

  List<LiFabAction> get actions => _actions;

  @Input()
  String label = '';

  @Input()
  bool showTriggerLabel = false;

  @Input()
  String iconClass = 'ph-plus';

  @Input()
  String openIconClass = 'ph-x';

  @Input()
  String variant = 'primary';

  @Input()
  String buttonStyle = 'solid';

  @Input()
  String size = '';

  @Input()
  String toggleMode = 'click';

  @Input()
  String direction = 'up';

  @Input()
  String position = 'bottom-end';

  @Input()
  String fabClass = '';

  @Input()
  bool fixed = true;

  @Input()
  bool backdrop = false;

  @Input()
  bool closeOnAction = true;

  @Input()
  bool enableKeyboardShortcuts = true;

  @Input()
  bool disabled = false;

  @Input()
  set expanded(bool value) {
    _expanded = value;
  }

  bool get expanded => _expanded;

  @Output()
  Stream<LiFabAction> get actionSelected => _actionSelectedController.stream;

  @Output()
  Stream<bool> get expandedChange => _expandedChangeController.stream;

  @HostBinding('class.li-fab-host')
  bool get hostClass => true;

  bool get hasActions => _actions.isNotEmpty;

  bool get isExpanded => _expanded && hasActions;

  bool get hasTriggerLabel => label.trim().isNotEmpty;

  bool get showTextLabel => showTriggerLabel && hasTriggerLabel;

  String get resolvedWrapperClass => _joinClasses(<String>[
        'fab-menu',
        fixed ? 'fab-menu-fixed' : '',
        _resolvedDirectionClass,
        fixed ? _resolvedPositionClass : '',
        _resolvedHorizontalDirectionClass,
        fabClass,
      ]);

  String get resolvedFabState => isExpanded ? 'open' : 'closed';

  String get resolvedToggleMode =>
      toggleMode.trim().toLowerCase() == 'hover' ? 'hover' : 'click';

  bool get usesHoverToggle => resolvedToggleMode == 'hover';

  TemplateRef? get resolvedTriggerTemplate =>
      triggerTemplate ?? projectedTriggerTemplate?.templateRef;

  TemplateRef? get resolvedActionTemplate =>
      actionTemplate ?? projectedActionTemplate?.templateRef;

  bool get usesCustomTriggerTemplate => resolvedTriggerTemplate != null;

  bool get usesCustomActionTemplate => resolvedActionTemplate != null;

  String get resolvedTriggerClass => _joinClasses(<String>[
        usesCustomTriggerTemplate ? 'li-fab__trigger' : 'fab-menu-btn',
        'btn',
        _buttonColorClass(variant, buttonStyle),
        _buttonSizeClass(size),
        'rounded-pill',
        usesCustomTriggerTemplate ? 'li-fab__trigger--template' : '',
        showTextLabel || usesCustomTriggerTemplate
            ? 'li-fab__trigger--extended'
            : 'btn-icon',
      ]);

  String? get resolvedTriggerLabel {
    final trimmedLabel = label.trim();
    return trimmedLabel.isEmpty ? null : trimmedLabel;
  }

  String resolvedActionClass(LiFabAction action) {
    return _joinClasses(<String>[
      'btn',
      _buttonColorClass(action.variant, action.buttonStyle),
      usesCustomActionTemplate ? '' : 'btn-icon',
      usesCustomActionTemplate ? 'li-fab__action--template' : '',
      'rounded-pill',
      action.buttonClass,
    ]);
  }

  String resolvedActionContainerClass(LiFabAction action) {
    return _joinClasses(<String>[
      action.alwaysShowLabel ? 'fab-label-visible' : '',
      action.lightLabel ? 'fab-label-light' : '',
      action.labelAtEnd ? 'fab-label-end' : '',
    ]);
  }

  bool isLinkAction(LiFabAction action) => action.href.trim().isNotEmpty;

  bool hasActionLabel(LiFabAction action) => action.label.trim().isNotEmpty;

  bool hasActionShortcut(LiFabAction action) => action.shortcut != null;

  String resolvedShortcutLabel(LiFabAction action) {
    return action.shortcut?.resolvedLabel ?? '';
  }

  String resolvedActionTitle(LiFabAction action) {
    final parts = <String>[];
    if (hasActionLabel(action)) {
      parts.add(action.label.trim());
    }
    if (hasActionShortcut(action)) {
      parts.add(resolvedShortcutLabel(action));
    }
    return parts.join(' - ');
  }

  String resolvedActionTooltip(LiFabAction action) {
    final parts = <String>[];
    if (hasActionLabel(action)) {
      parts.add(action.label.trim());
    }
    if (hasActionShortcut(action)) {
      parts.add(resolvedShortcutLabel(action));
    }
    return parts.join(' • ');
  }

  String? resolvedActionHref(LiFabAction action) {
    final href = action.href.trim();
    return href.isEmpty ? null : href;
  }

  String? resolvedActionTarget(LiFabAction action) {
    final target = action.target.trim();
    return target.isEmpty ? null : target;
  }

  String? resolvedActionRel(LiFabAction action) {
    final rel = action.rel.trim();
    if (rel.isNotEmpty) {
      return rel;
    }

    return resolvedActionTarget(action) == '_blank'
        ? 'noopener noreferrer'
        : null;
  }

  String? resolvedShortcutAriaKey(LiFabAction action) {
    final shortcut = action.shortcut;
    if (shortcut == null) {
      return null;
    }

    final parts = <String>[];
    if (shortcut.ctrl) {
      parts.add('Control');
    }
    if (shortcut.alt) {
      parts.add('Alt');
    }
    if (shortcut.shift) {
      parts.add('Shift');
    }
    if (shortcut.meta) {
      parts.add('Meta');
    }
    parts.add(shortcut.key.trim().toUpperCase());
    return parts.join('+');
  }

  Object? trackByAction(int index, dynamic action) {
    final resolvedAction = action as LiFabAction;
    return '${resolvedAction.iconClass}|${resolvedAction.label}|${resolvedAction.href}|$index';
  }

  LiFabActionTemplateContext actionTemplateContext(LiFabAction action) {
    return _actionTemplateContexts.putIfAbsent(
      action,
      () => LiFabActionTemplateContext(this, action),
    );
  }

  void handleTriggerClick() {
    if (disabled || !hasActions) {
      return;
    }

    if (usesHoverToggle && !html.window.matchMedia('(hover: none)').matches) {
      return;
    }

    _setExpanded(!isExpanded);
  }

  void handleMouseEnter() {
    if (!usesHoverToggle || disabled || !hasActions) {
      return;
    }

    _setExpanded(true);
  }

  void handleMouseLeave() {
    if (!usesHoverToggle || disabled) {
      return;
    }

    _setExpanded(false);
  }

  void handleActionClick(LiFabAction action, [dynamic event]) {
    if (action.disabled) {
      event?.preventDefault();
      return;
    }

    _actionSelectedController.add(action);
    if (closeOnAction) {
      _setExpanded(false);
    }
  }

  void close() {
    _setExpanded(false);
  }

  void _rebuildActionTemplateContexts() {
    final updated = Map<LiFabAction, LiFabActionTemplateContext>.identity();
    for (final action in _actions) {
      updated[action] = _actionTemplateContexts[action] ??
          LiFabActionTemplateContext(this, action);
    }
    _actionTemplateContexts = updated;
  }

  String _buttonColorClass(String variant, String style) {
    final normalizedVariant =
        variant.trim().isEmpty ? 'primary' : variant.trim();
    switch (style.trim().toLowerCase()) {
      case 'outline':
        return 'btn-outline-$normalizedVariant';
      case 'flat':
        return 'btn-flat-$normalizedVariant';
      case 'link':
        return 'btn-link';
      case 'solid':
      default:
        return 'btn-$normalizedVariant';
    }
  }

  String _buttonSizeClass(String value) {
    switch (value.trim().toLowerCase()) {
      case 'sm':
        return 'btn-sm';
      case 'lg':
        return 'btn-lg';
      default:
        return '';
    }
  }

  String get _resolvedDirection {
    switch (direction.trim().toLowerCase()) {
      case 'down':
      case 'left':
      case 'right':
        return direction.trim().toLowerCase();
      case 'up':
      default:
        return 'up';
    }
  }

  String get _resolvedDirectionClass {
    switch (_resolvedDirection) {
      case 'down':
        return 'fab-menu-top';
      case 'up':
      default:
        return 'fab-menu-bottom';
    }
  }

  String get _resolvedHorizontalDirectionClass {
    switch (_resolvedDirection) {
      case 'left':
        return 'li-fab--dir-left';
      case 'right':
        return 'li-fab--dir-right';
      default:
        return '';
    }
  }

  String get _resolvedPositionClass {
    switch (position.trim().toLowerCase()) {
      case 'bottom-start':
      case 'bottomstart':
        return 'li-fab--bottom-start';
      case 'top-start':
      case 'topstart':
        return 'li-fab--top-start';
      case 'top-end':
      case 'topend':
        return 'li-fab--top-end';
      case 'bottom-end':
      case 'bottomend':
      default:
        return 'li-fab--bottom-end';
    }
  }

  void _handleWindowKeyDown(html.KeyboardEvent event) {
    if (!enableKeyboardShortcuts || disabled) {
      return;
    }

    final target = event.target;
    if (target is html.InputElement ||
        target is html.TextAreaElement ||
        target is html.SelectElement ||
        target is html.Element && target.isContentEditable == true) {
      return;
    }

    if (triggerShortcut(
      key: event.key ?? '',
      alt: event.altKey,
      ctrl: event.ctrlKey,
      meta: event.metaKey,
      shift: event.shiftKey,
      keyCode: event.keyCode,
    )) {
      event.preventDefault();
    }
  }

  bool triggerShortcut({
    required String key,
    bool alt = false,
    bool ctrl = false,
    bool meta = false,
    bool shift = false,
    int? keyCode,
  }) {
    if (!enableKeyboardShortcuts || disabled) {
      return false;
    }

    final normalizedKey = key.trim().toLowerCase();
    for (final action in _actions) {
      final shortcut = action.shortcut;
      if (shortcut == null) {
        continue;
      }

      final shortcutKey = shortcut.key.trim().toLowerCase();
      final matchesKey = normalizedKey == shortcutKey ||
          (shortcutKey.length == 1 &&
              keyCode == shortcutKey.toUpperCase().codeUnitAt(0));
      if (!matchesKey ||
          shortcut.alt != alt ||
          shortcut.ctrl != ctrl ||
          shortcut.meta != meta ||
          shortcut.shift != shift) {
        continue;
      }

      handleActionClick(action);
      _navigateIfNeeded(action);
      return true;
    }

    return false;
  }

  void _navigateIfNeeded(LiFabAction action) {
    final href = resolvedActionHref(action);
    if (href == null) {
      return;
    }

    final target = resolvedActionTarget(action);
    if (href.startsWith('#')) {
      html.window.location.hash = href.substring(1);
      return;
    }

    if (target == '_blank') {
      html.window.open(href, '_blank');
      return;
    }

    html.window.location.assign(href);
  }

  void _setExpanded(bool value) {
    if (_expanded == value) {
      return;
    }

    _expanded = value;
    _expandedChangeController.add(_expanded);
    _changeDetectorRef.markForCheck();
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  @override
  void ngOnDestroy() {
    _keyboardSubscription?.cancel();
    _actionSelectedController.close();
    _expandedChangeController.close();
  }
}
