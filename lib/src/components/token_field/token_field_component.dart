import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import '../dropdown_menu/dropdown_menu_component.dart';

class LiTokenFieldItemView {
  LiTokenFieldItemView({
    required this.value,
    this.selected = false,
  });

  final String value;
  bool selected;
}

@Component(
  selector: 'li-token-field',
  changeDetection: ChangeDetectionStrategy.onPush,
  templateUrl: 'token_field_component.html',
  styleUrls: ['token_field_component.css'],
  directives: [
    coreDirectives,
    LiDropdownMenuComponent,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiTokenFieldComponent),
  ],
)
class LiTokenFieldComponent
    implements ControlValueAccessor<List<String>>, AfterChanges, OnDestroy {
  LiTokenFieldComponent(this._changeDetectorRef) {
    _rebuildActionMenuOptions();
  }

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<List<String>> _changeController =
      StreamController<List<String>>.broadcast();
  final StreamController<void> _copyActionController =
      StreamController<void>.broadcast();
  final StreamController<void> _pasteActionController =
      StreamController<void>.broadcast();
  final StreamController<void> _clearActionController =
      StreamController<void>.broadcast();

  ChangeFunction<List<String>>? _onChange;
  TouchFunction _onTouched = () {};
  bool _touched = false;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String placeholder = '';

  @Input()
  String locale = 'pt_BR';

  @Input()
  String patternAllowed = '';

  @Input()
  String patternToken = r'[^,;\n]+';

  @Input()
  String separatorPattern = r'[,;\n]+';

  @Input()
  bool filterInput = false;

  @Input()
  bool allowDuplicates = false;

  @Input()
  int? maxTokens;

  @Input()
  bool showActionMenu = true;

  @Input()
  bool showCopyAction = true;

  @Input()
  bool showPasteAction = true;

  @Input()
  bool showClearAction = true;

  @Input()
  bool showRemoveButton = true;

  @Input()
  String copyButtonLabel = '';

  @Input()
  String pasteButtonLabel = '';

  @Input()
  String clearButtonLabel = '';

  @Input()
  String actionMenuTriggerClass = 'btn btn-light btn-sm btn-icon rounded-pill';

  @Input()
  String actionMenuTriggerIconClass = 'ph ph-caret-down ph-sm';

  @Input()
  String copySeparator = ',';

  @ViewChild('inputToken')
  html.InputElement? inputToken;

  List<LiTokenFieldItemView> items = <LiTokenFieldItemView>[];
  List<LiDropdownMenuOption> actionMenuOptions = const <LiDropdownMenuOption>[];

  bool isFocused = false;

  @Output()
  Stream<List<String>> get onChange => _changeController.stream;

  @Output('currentValueChange')
  Stream<List<String>> get onValueChange => _changeController.stream;

  @Output('modelChange')
  Stream<List<String>> get onModelChange => _changeController.stream;

  @Output('copyAction')
  Stream<void> get onCopyAction => _copyActionController.stream;

  @Output('pasteAction')
  Stream<void> get onPasteAction => _pasteActionController.stream;

  @Output('clearAction')
  Stream<void> get onClearAction => _clearActionController.stream;

  List<String> get tokens =>
      items.map((LiTokenFieldItemView item) => item.value).toList();

  bool get hasSelectedItems =>
      items.any((LiTokenFieldItemView item) => item.selected);

  bool get hasActionMenuOptions => actionMenuOptions.isNotEmpty;

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  String get resolvedPlaceholder {
    final value = placeholder.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale
        ? 'Type a value and press enter.'
        : 'Digite um valor e pressione enter.';
  }

  String get resolvedCopyButtonLabel {
    final value = copyButtonLabel.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Copy' : 'Copiar';
  }

  String get resolvedPasteButtonLabel {
    final value = pasteButtonLabel.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Paste' : 'Colar';
  }

  String get resolvedClearButtonLabel {
    final value = clearButtonLabel.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Clear' : 'Limpar';
  }

  String get resolvedContainerClass => _joinClasses(<String>[
        'tokenfield',
        'tokenfield-mode-tokens',
        'li-token-field',
        showActionMenu && hasActionMenuOptions ? 'li-token-field--with-menu' : '',
        isFocused ? 'focused' : '',
        isDisabled ? 'li-token-field--disabled' : '',
      ]);

  @override
  void ngAfterChanges() {
    _rebuildActionMenuOptions();
    _markForCheck();
  }

  @override
  void writeValue(List<String>? newVal) {
    items = (newVal ?? const <String>[])
        .map((String value) => LiTokenFieldItemView(value: value))
        .toList(growable: true);
    _markForCheck();
  }

  @override
  void registerOnChange(ChangeFunction<List<String>> callback) {
    _onChange = callback;
  }

  @override
  void registerOnTouched(TouchFunction callback) {
    _onTouched = callback;
  }

  @override
  void onDisabledChanged(bool state) {
    isDisabled = state;
    _markForCheck();
  }

  void addToken() {
    if (isDisabled) {
      return;
    }

    final text = inputToken?.value?.trim() ?? '';
    if (text.isEmpty) {
      return;
    }

    processInput(text);
    if (inputToken != null) {
      inputToken!.value = '';
    }
  }

  void inputKeypressHandle(html.KeyboardEvent event) {
    if (isDisabled || !filterInput) {
      return;
    }

    final allowedPattern = patternAllowed.trim();
    if (allowedPattern.isEmpty) {
      return;
    }

    final key = event.key ?? '';
    if (key.length != 1) {
      return;
    }

    if (!RegExp(allowedPattern).hasMatch(key)) {
      event.preventDefault();
    }
  }

  void inputKeydownHandle(html.KeyboardEvent event) {
    if (isDisabled) {
      return;
    }

    final key = event.key ?? '';
    final isModifierPressed = event.ctrlKey || event.metaKey;
    if (isModifierPressed && key.toLowerCase() == 'a') {
      event.preventDefault();
      selectAll();
      return;
    }

    if (isModifierPressed && key.toLowerCase() == 'c') {
      event.preventDefault();
      copyTokens();
      return;
    }

    final canRemoveSelected =
        hasSelectedItems && (key == 'Delete' || key == 'Backspace');
    if (canRemoveSelected) {
      event.preventDefault();
      removeSelected();
      return;
    }

    final shouldSelectLastToken =
        key == 'Backspace' && (inputToken?.value?.isEmpty ?? true);
    if (shouldSelectLastToken && items.isNotEmpty) {
      _clearItemSelection();
      items.last.selected = true;
      _markForCheck();
    }
  }

  void inputKeyupHandle(html.KeyboardEvent event) {
    if (isDisabled) {
      return;
    }

    final key = event.key ?? '';
    if (key == 'Enter' || key == ',' || key == ';') {
      event.preventDefault();
      addToken();
    }
  }

  void onPasteHandle(html.ClipboardEvent event) {
    if (isDisabled) {
      return;
    }

    final text = event.clipboardData?.getData('text/plain') ??
        event.clipboardData?.getData('text') ??
        '';
    if (text.isEmpty) {
      return;
    }

    event.preventDefault();
    processInput(text);
  }

  void toggleItemSelection(
    LiTokenFieldItemView item,
    html.MouseEvent event,
  ) {
    event.stopPropagation();
    if (isDisabled) {
      return;
    }

    final keepExistingSelection = event.ctrlKey || event.metaKey;
    if (!keepExistingSelection) {
      final nextSelection = !item.selected;
      _clearItemSelection();
      item.selected = nextSelection;
      _markForCheck();
      return;
    }

    item.selected = !item.selected;
    _markForCheck();
  }

  void removeToken(LiTokenFieldItemView item, [html.Event? event]) {
    event?.preventDefault();
    event?.stopPropagation();
    if (isDisabled) {
      return;
    }

    items.remove(item);
    _emitChange();
  }

  void selectAll() {
    for (final item in items) {
      item.selected = true;
    }
    _markForCheck();
  }

  void unSelectAll() {
    _clearItemSelection();
    _markForCheck();
  }

  void containerClickHandle() {
    if (isDisabled) {
      return;
    }

    inputToken?.focus();
    unSelectAll();
  }

  void onInputFocus() {
    isFocused = true;
    _markForCheck();
  }

  void onInputBlur() {
    isFocused = false;
    _markTouched();
    _markForCheck();
  }

  Future<void> copyTokens() async {
    final textToCopy = (hasSelectedItems
            ? items
                .where((LiTokenFieldItemView item) => item.selected)
                .map((LiTokenFieldItemView item) => item.value)
                .toList(growable: false)
            : tokens)
        .join(copySeparator);

    if (textToCopy.trim().isEmpty) {
      return;
    }

    final clipboard = html.window.navigator.clipboard;
    if (clipboard != null) {
      try {
        await clipboard.writeText(textToCopy);
        _copyActionController.add(null);
        return;
      } catch (_) {}
    }

    _fallbackCopyToClipboard(textToCopy);
    _copyActionController.add(null);
  }

  Future<void> pasteTokens() async {
    if (isDisabled) {
      return;
    }

    String text = '';
    try {
      await html.window.navigator.permissions?.query(<String, String>{
        'name': 'clipboard-read',
      });
      text = await html.window.navigator.clipboard?.readText() ?? '';
    } catch (_) {
      text = '';
    }

    if (text.trim().isEmpty) {
      return;
    }

    processInput(text);
    inputToken?.focus();
    _pasteActionController.add(null);
  }

  void clear() {
    if (isDisabled || items.isEmpty) {
      return;
    }

    items.clear();
    _emitChange();
    _clearActionController.add(null);
  }

  void removeSelected() {
    if (isDisabled || !hasSelectedItems) {
      return;
    }

    items.removeWhere((LiTokenFieldItemView item) => item.selected);
    _emitChange();
  }

  void processInput(String text) {
    final extractedTokens = _extractTokens(text);
    if (extractedTokens.isEmpty) {
      return;
    }

    var didChange = false;
    for (final token in extractedTokens) {
      if (!allowDuplicates &&
          items.any((LiTokenFieldItemView item) => item.value == token)) {
        continue;
      }
      if (maxTokens != null && items.length >= maxTokens!) {
        break;
      }

      items.add(LiTokenFieldItemView(value: token));
      didChange = true;
    }

    if (!didChange) {
      return;
    }

    _clearItemSelection();
    _emitChange();
  }

  void onActionSelected(String value) {
    switch (value) {
      case 'copy':
        copyTokens();
        break;
      case 'paste':
        pasteTokens();
        break;
      case 'clear':
        clear();
        break;
    }
  }

  @override
  void ngOnDestroy() {
    _changeController.close();
    _copyActionController.close();
    _pasteActionController.close();
    _clearActionController.close();
  }

  List<String> _extractTokens(String text) {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      return const <String>[];
    }

    final tokenPattern = patternToken.trim();
    if (tokenPattern.isNotEmpty) {
      final matches = RegExp(tokenPattern, multiLine: true)
          .allMatches(normalizedText)
          .map((RegExpMatch match) => match.group(0)?.trim() ?? '')
          .where((String token) => token.isNotEmpty)
          .toList(growable: false);

      if (matches.isNotEmpty) {
        return matches;
      }
    }

    return normalizedText
        .split(RegExp(separatorPattern))
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
  }

  void _fallbackCopyToClipboard(String text) {
    final helper = html.TextAreaElement()
      ..value = text
      ..style.position = 'fixed'
      ..style.opacity = '0'
      ..style.left = '-9999px'
      ..style.top = '-9999px';
    html.document.body?.append(helper);
    helper.select();
    html.document.execCommand('copy');
    helper.remove();
  }

  void _emitChange() {
    final emittedTokens = List<String>.unmodifiable(tokens);
    _changeController.add(emittedTokens);
    _onChange?.call(emittedTokens);
    _markTouched();
    _markForCheck();
  }

  void _clearItemSelection() {
    for (final item in items) {
      item.selected = false;
    }
  }

  void _rebuildActionMenuOptions() {
    actionMenuOptions = <LiDropdownMenuOption>[
      if (showCopyAction)
        LiDropdownMenuOption(
          value: 'copy',
          label: resolvedCopyButtonLabel,
          iconClass: 'ph ph-copy',
        ),
      if (showPasteAction)
        LiDropdownMenuOption(
          value: 'paste',
          label: resolvedPasteButtonLabel,
          iconClass: 'ph ph-clipboard-text',
        ),
      if (showClearAction)
        LiDropdownMenuOption(
          value: 'clear',
          label: resolvedClearButtonLabel,
          iconClass: 'ph ph-broom',
        ),
    ];
  }

  void _markTouched() {
    if (_touched) {
      return;
    }
    _touched = true;
    _onTouched();
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  String _joinClasses(List<String> classes) {
    return classes
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .join(' ');
  }
}
