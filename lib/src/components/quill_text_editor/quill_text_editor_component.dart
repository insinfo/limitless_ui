import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import 'quill_interop.dart' as quill;
import 'quill_text_editor_bridge.dart';

typedef LiQuillToolbarActionCallback = FutureOr<void> Function(
  LiQuillToolbarActionEvent event,
);

enum LiQuillToolbarActionPlacement {
  leading,
  trailing,
}

class LiQuillToolbarOption {
  const LiQuillToolbarOption({
    required this.label,
    required this.value,
    this.selected = false,
  });

  final String label;
  final String value;
  final bool selected;
}

class LiQuillToolbarItem {
  const LiQuillToolbarItem.button({
    required this.id,
    required this.quillClass,
    this.title = '',
    this.label = '',
    this.iconClass = '',
    this.value = '',
    this.buttonClass = '',
  })  : isButton = true,
        isSelect = false,
        selectClass = '',
        options = const <LiQuillToolbarOption>[];

  const LiQuillToolbarItem.select({
    required this.id,
    required this.quillClass,
    this.title = '',
    this.selectClass = '',
    this.options = const <LiQuillToolbarOption>[],
  })  : isButton = false,
        isSelect = true,
        label = '',
        iconClass = '',
        value = '',
        buttonClass = '';

  final String id;
  final bool isButton;
  final bool isSelect;
  final String quillClass;
  final String title;
  final String label;
  final String iconClass;
  final String value;
  final String buttonClass;
  final String selectClass;
  final List<LiQuillToolbarOption> options;
}

class LiQuillToolbarAction {
  const LiQuillToolbarAction({
    required this.id,
    this.iconClass = '',
    this.label = '',
    this.title = '',
    this.buttonClass = '',
    this.placement = LiQuillToolbarActionPlacement.trailing,
    this.disabled = false,
    this.onPressed,
  });

  final String id;
  final String iconClass;
  final String label;
  final String title;
  final String buttonClass;
  final LiQuillToolbarActionPlacement placement;
  final bool disabled;
  final LiQuillToolbarActionCallback? onPressed;
}

class LiQuillToolbarActionEvent {
  const LiQuillToolbarActionEvent({
    required this.editor,
    required this.action,
  });

  final LiQuillTextEditorComponent editor;
  final LiQuillToolbarAction action;
}

class LiQuillTextEditorSelection {
  const LiQuillTextEditorSelection({
    required this.index,
    required this.length,
  });

  final int index;
  final int length;
}

class LiQuillTextEditorTemplateContext {
  LiQuillTextEditorTemplateContext(this.editor);

  final LiQuillTextEditorComponent editor;

  bool get isReady => editor.isReady;

  String get htmlValue => editor.getHtml();

  String get plainText => editor.getPlainText();

  String get deltaJson => editor.getDeltaJson();

  void focus() => editor.focus();

  void blur() => editor.blur();

  void clear() => editor.clear();

  Future<void> setDeltaJson(String value) => editor.setDeltaJson(value);
}

@Directive(selector: 'template[liQuillTextEditorToolbarActions]')
class LiQuillTextEditorToolbarActionsDirective {
  LiQuillTextEditorToolbarActionsDirective(this.templateRef);

  final TemplateRef templateRef;
}

class LiQuillTextEditorLabels {
  const LiQuillTextEditorLabels({
    this.bold = 'Bold',
    this.italic = 'Italic',
    this.underline = 'Underline',
    this.strike = 'Strikethrough',
    this.orderedList = 'Ordered list',
    this.bulletList = 'Bullet list',
    this.alignLeft = 'Align left',
    this.alignCenter = 'Align center',
    this.alignRight = 'Align right',
    this.alignJustify = 'Justify',
    this.blockType = 'Block type',
    this.fontSize = 'Font size',
    this.fontColor = 'Text color',
    this.backgroundColor = 'Background color',
    this.insertLink = 'Insert link',
    this.clearFormatting = 'Clear formatting',
    this.table = 'Table',
    this.normal = 'Normal',
    this.heading1 = 'Heading 1',
    this.heading2 = 'Heading 2',
    this.heading3 = 'Heading 3',
    this.defaultFontSize = 'Default',
    this.quillUnavailable = 'Quill 2.0.3 is not available on window.Quill.',
    this.initializationErrorPrefix =
        'Unable to initialize the Quill editor:',
    this.editorNotReady = 'The Quill editor is not initialized yet.',
    this.invalidDelta = 'Invalid delta: the "ops" key is required.',
  });

  static const LiQuillTextEditorLabels english = LiQuillTextEditorLabels();

  static const LiQuillTextEditorLabels portuguese = LiQuillTextEditorLabels(
    bold: 'Negrito',
    italic: 'Itálico',
    underline: 'Sublinhado',
    strike: 'Tachado',
    orderedList: 'Lista ordenada',
    bulletList: 'Lista com marcadores',
    alignLeft: 'Alinhar à esquerda',
    alignCenter: 'Centralizar',
    alignRight: 'Alinhar à direita',
    alignJustify: 'Justificar',
    blockType: 'Tipo de bloco',
    fontSize: 'Tamanho da fonte',
    fontColor: 'Cor da fonte',
    backgroundColor: 'Cor de fundo',
    insertLink: 'Inserir link',
    clearFormatting: 'Limpar formatação',
    table: 'Tabela',
    normal: 'Normal',
    heading1: 'Título 1',
    heading2: 'Título 2',
    heading3: 'Título 3',
    defaultFontSize: 'Padrão',
    quillUnavailable: 'Quill 2.0.3 não está disponível em window.Quill.',
    initializationErrorPrefix: 'Falha ao inicializar o editor Quill:',
    editorNotReady: 'O editor Quill ainda não foi inicializado.',
    invalidDelta: 'Delta inválido: a chave "ops" é obrigatória.',
  );

  final String bold;
  final String italic;
  final String underline;
  final String strike;
  final String orderedList;
  final String bulletList;
  final String alignLeft;
  final String alignCenter;
  final String alignRight;
  final String alignJustify;
  final String blockType;
  final String fontSize;
  final String fontColor;
  final String backgroundColor;
  final String insertLink;
  final String clearFormatting;
  final String table;
  final String normal;
  final String heading1;
  final String heading2;
  final String heading3;
  final String defaultFontSize;
  final String quillUnavailable;
  final String initializationErrorPrefix;
  final String editorNotReady;
  final String invalidDelta;
}

List<LiQuillToolbarOption> buildDefaultLiQuillHeaderOptions(
  LiQuillTextEditorLabels labels,
) {
  return List<LiQuillToolbarOption>.unmodifiable(<LiQuillToolbarOption>[
    LiQuillToolbarOption(label: labels.normal, value: '', selected: true),
    LiQuillToolbarOption(label: labels.heading1, value: '1'),
    LiQuillToolbarOption(label: labels.heading2, value: '2'),
    LiQuillToolbarOption(label: labels.heading3, value: '3'),
  ]);
}

List<LiQuillToolbarOption> buildDefaultLiQuillFontSizeOptions(
  LiQuillTextEditorLabels labels,
) {
  return List<LiQuillToolbarOption>.unmodifiable(<LiQuillToolbarOption>[
    LiQuillToolbarOption(
      label: labels.defaultFontSize,
      value: '',
      selected: true,
    ),
    const LiQuillToolbarOption(label: '8', value: '8pt'),
    const LiQuillToolbarOption(label: '9', value: '9pt'),
    const LiQuillToolbarOption(label: '10', value: '10pt'),
    const LiQuillToolbarOption(label: '11', value: '11pt'),
    const LiQuillToolbarOption(label: '12', value: '12pt'),
    const LiQuillToolbarOption(label: '13', value: '13pt'),
    const LiQuillToolbarOption(label: '14', value: '14pt'),
    const LiQuillToolbarOption(label: '16', value: '16pt'),
    const LiQuillToolbarOption(label: '18', value: '18pt'),
    const LiQuillToolbarOption(label: '20', value: '20pt'),
    const LiQuillToolbarOption(label: '22', value: '22pt'),
    const LiQuillToolbarOption(label: '24', value: '24pt'),
    const LiQuillToolbarOption(label: '26', value: '26pt'),
    const LiQuillToolbarOption(label: '28', value: '28pt'),
    const LiQuillToolbarOption(label: '36', value: '36pt'),
    const LiQuillToolbarOption(label: '48', value: '48pt'),
    const LiQuillToolbarOption(label: '72', value: '72pt'),
  ]);
}

class LiQuillToolbarItems {
  static const LiQuillToolbarItem bold = LiQuillToolbarItem.button(
    id: 'bold',
    quillClass: 'ql-bold',
    title: 'Bold',
    iconClass: 'ph ph-text-b',
  );

  static const LiQuillToolbarItem italic = LiQuillToolbarItem.button(
    id: 'italic',
    quillClass: 'ql-italic',
    title: 'Italic',
    iconClass: 'ph ph-text-italic',
  );

  static const LiQuillToolbarItem underline = LiQuillToolbarItem.button(
    id: 'underline',
    quillClass: 'ql-underline',
    title: 'Underline',
    iconClass: 'ph ph-text-underline',
  );

  static const LiQuillToolbarItem strike = LiQuillToolbarItem.button(
    id: 'strike',
    quillClass: 'ql-strike',
    title: 'Strikethrough',
    iconClass: 'ph ph-text-strikethrough',
  );

  static const LiQuillToolbarItem orderedList = LiQuillToolbarItem.button(
    id: 'ordered',
    quillClass: 'ql-list',
    value: 'ordered',
    title: 'Ordered list',
    iconClass: 'ph ph-list-numbers',
  );

  static const LiQuillToolbarItem bulletList = LiQuillToolbarItem.button(
    id: 'bullet',
    quillClass: 'ql-list',
    value: 'bullet',
    title: 'Bullet list',
    iconClass: 'ph ph-list-bullets',
  );

  static const LiQuillToolbarItem alignLeft = LiQuillToolbarItem.button(
    id: 'align-left',
    quillClass: 'ql-align',
    title: 'Align left',
    iconClass: 'ph ph-text-align-left',
  );

  static const LiQuillToolbarItem alignCenter = LiQuillToolbarItem.button(
    id: 'align-center',
    quillClass: 'ql-align',
    value: 'center',
    title: 'Align center',
    iconClass: 'ph ph-text-align-center',
  );

  static const LiQuillToolbarItem alignRight = LiQuillToolbarItem.button(
    id: 'align-right',
    quillClass: 'ql-align',
    value: 'right',
    title: 'Align right',
    iconClass: 'ph ph-text-align-right',
  );

  static const LiQuillToolbarItem alignJustify = LiQuillToolbarItem.button(
    id: 'align-justify',
    quillClass: 'ql-align',
    value: 'justify',
    title: 'Justify',
    iconClass: 'ph ph-text-align-justify',
  );

  static const LiQuillToolbarItem link = LiQuillToolbarItem.button(
    id: 'link',
    quillClass: 'ql-link',
    title: 'Insert link',
    iconClass: 'ph ph-link',
  );

  static const LiQuillToolbarItem clear = LiQuillToolbarItem.button(
    id: 'clean',
    quillClass: 'ql-clean',
    title: 'Clear formatting',
    iconClass: 'ph ph-broom',
  );

  static const LiQuillToolbarItem color = LiQuillToolbarItem.select(
    id: 'color',
    quillClass: 'ql-color',
    title: 'Text color',
  );

  static const LiQuillToolbarItem background = LiQuillToolbarItem.select(
    id: 'background',
    quillClass: 'ql-background',
    title: 'Background color',
  );

  static const LiQuillToolbarItem table = LiQuillToolbarItem.button(
    id: 'table',
    quillClass: 'ql-table-better',
    title: 'Table',
    iconClass: 'ph ph-table',
  );

  static List<LiQuillToolbarItem> defaultItems({
    required LiQuillTextEditorLabels labels,
    required List<LiQuillToolbarOption> headerOptions,
    required List<LiQuillToolbarOption> fontSizeOptions,
    required bool enableTableButton,
  }) {
    return List<LiQuillToolbarItem>.unmodifiable(<LiQuillToolbarItem>[
      LiQuillToolbarItem.button(
        id: 'bold',
        quillClass: 'ql-bold',
        title: labels.bold,
        iconClass: 'ph ph-text-b',
      ),
      LiQuillToolbarItem.button(
        id: 'italic',
        quillClass: 'ql-italic',
        title: labels.italic,
        iconClass: 'ph ph-text-italic',
      ),
      LiQuillToolbarItem.button(
        id: 'underline',
        quillClass: 'ql-underline',
        title: labels.underline,
        iconClass: 'ph ph-text-underline',
      ),
      LiQuillToolbarItem.button(
        id: 'strike',
        quillClass: 'ql-strike',
        title: labels.strike,
        iconClass: 'ph ph-text-strikethrough',
      ),
      LiQuillToolbarItem.button(
        id: 'ordered',
        quillClass: 'ql-list',
        value: 'ordered',
        title: labels.orderedList,
        iconClass: 'ph ph-list-numbers',
      ),
      LiQuillToolbarItem.button(
        id: 'bullet',
        quillClass: 'ql-list',
        value: 'bullet',
        title: labels.bulletList,
        iconClass: 'ph ph-list-bullets',
      ),
      LiQuillToolbarItem.button(
        id: 'align-left',
        quillClass: 'ql-align',
        title: labels.alignLeft,
        iconClass: 'ph ph-text-align-left',
      ),
      LiQuillToolbarItem.button(
        id: 'align-center',
        quillClass: 'ql-align',
        value: 'center',
        title: labels.alignCenter,
        iconClass: 'ph ph-text-align-center',
      ),
      LiQuillToolbarItem.button(
        id: 'align-right',
        quillClass: 'ql-align',
        value: 'right',
        title: labels.alignRight,
        iconClass: 'ph ph-text-align-right',
      ),
      LiQuillToolbarItem.button(
        id: 'align-justify',
        quillClass: 'ql-align',
        value: 'justify',
        title: labels.alignJustify,
        iconClass: 'ph ph-text-align-justify',
      ),
      LiQuillToolbarItem.select(
        id: 'header',
        quillClass: 'ql-header',
        title: labels.blockType,
        options: headerOptions,
      ),
      LiQuillToolbarItem.select(
        id: 'size',
        quillClass: 'ql-size',
        title: labels.fontSize,
        options: fontSizeOptions,
      ),
      LiQuillToolbarItem.select(
        id: 'color',
        quillClass: 'ql-color',
        title: labels.fontColor,
      ),
      LiQuillToolbarItem.select(
        id: 'background',
        quillClass: 'ql-background',
        title: labels.backgroundColor,
      ),
      LiQuillToolbarItem.button(
        id: 'link',
        quillClass: 'ql-link',
        title: labels.insertLink,
        iconClass: 'ph ph-link',
      ),
      if (enableTableButton)
        LiQuillToolbarItem.button(
          id: 'table',
          quillClass: 'ql-table-better',
          title: labels.table,
          iconClass: 'ph ph-table',
        ),
      LiQuillToolbarItem.button(
        id: 'clean',
        quillClass: 'ql-clean',
        title: labels.clearFormatting,
        iconClass: 'ph ph-broom',
      ),
    ]);
  }
}

const defaultLiQuillHeaderOptions = <LiQuillToolbarOption>[
  LiQuillToolbarOption(label: 'Normal', value: '', selected: true),
  LiQuillToolbarOption(label: 'Heading 1', value: '1'),
  LiQuillToolbarOption(label: 'Heading 2', value: '2'),
  LiQuillToolbarOption(label: 'Heading 3', value: '3'),
];

const defaultLiQuillFontSizeOptions = <LiQuillToolbarOption>[
  LiQuillToolbarOption(label: 'Default', value: '', selected: true),
  LiQuillToolbarOption(label: '8', value: '8pt'),
  LiQuillToolbarOption(label: '9', value: '9pt'),
  LiQuillToolbarOption(label: '10', value: '10pt'),
  LiQuillToolbarOption(label: '11', value: '11pt'),
  LiQuillToolbarOption(label: '12', value: '12pt'),
  LiQuillToolbarOption(label: '13', value: '13pt'),
  LiQuillToolbarOption(label: '14', value: '14pt'),
  LiQuillToolbarOption(label: '16', value: '16pt'),
  LiQuillToolbarOption(label: '18', value: '18pt'),
  LiQuillToolbarOption(label: '20', value: '20pt'),
  LiQuillToolbarOption(label: '22', value: '22pt'),
  LiQuillToolbarOption(label: '24', value: '24pt'),
  LiQuillToolbarOption(label: '26', value: '26pt'),
  LiQuillToolbarOption(label: '28', value: '28pt'),
  LiQuillToolbarOption(label: '36', value: '36pt'),
  LiQuillToolbarOption(label: '48', value: '48pt'),
  LiQuillToolbarOption(label: '72', value: '72pt'),
];

final List<LiQuillToolbarOption> defaultLiQuillHeaderOptionsPt =
    buildDefaultLiQuillHeaderOptions(LiQuillTextEditorLabels.portuguese);

final List<LiQuillToolbarOption> defaultLiQuillFontSizeOptionsPt =
    buildDefaultLiQuillFontSizeOptions(LiQuillTextEditorLabels.portuguese);

const defaultLiQuillTableMenus = <String>[
  'column',
  'row',
  'merge',
  'table',
  'copy',
  'delete',
];

const liQuillTextEditorDirectives = <Object>[
  LiQuillTextEditorComponent,
  LiQuillTextEditorToolbarActionsDirective,
];

@Component(
  selector: 'li-quill-text-editor',
  templateUrl: 'quill_text_editor_component.html',
  styleUrls: ['quill_text_editor_component.css'],
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiQuillTextEditorComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiQuillTextEditorComponent
    implements
        ControlValueAccessor<String?>,
        OnInit,
        AfterChanges,
        AfterViewInit,
        OnDestroy {
  LiQuillTextEditorComponent(this._changeDetectorRef, this._hostElement);

  final ChangeDetectorRef _changeDetectorRef;
  final html.HtmlElement _hostElement;
  final StreamController<String> _valueController =
      StreamController<String>.broadcast();
  final StreamController<String> _textController =
      StreamController<String>.broadcast();
  final StreamController<String> _deltaJsonController =
      StreamController<String>.broadcast();
  final StreamController<LiQuillTextEditorSelection?> _selectionController =
      StreamController<LiQuillTextEditorSelection?>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<LiQuillToolbarActionEvent> _toolbarActionController =
      StreamController<LiQuillToolbarActionEvent>.broadcast();
  final StreamController<LiQuillTextEditorComponent> _readyController =
      StreamController<LiQuillTextEditorComponent>.broadcast();

  void Function(String?)? _onChange;
  TouchFunction? _onTouched;
    LiQuillTextEditorHandle? _quill;
  String? _pendingHtmlValue;
  bool _initialized = false;
    bool _hasPendingUserChange = false;
  LiQuillTextEditorSelection? _lastSelection;
  List<LiQuillToolbarItem>? _toolbarItemsInput;
    List<LiQuillToolbarOption>? _headerOptionsInput;
    List<LiQuillToolbarOption>? _fontSizeOptionsInput;
  List<LiQuillToolbarAction> _toolbarActions =
      const <LiQuillToolbarAction>[];
    LiQuillTextEditorLabels _labels = LiQuillTextEditorLabels.english;

  late final LiQuillTextEditorTemplateContext templateContext =
      LiQuillTextEditorTemplateContext(this);

  @Input()
  String theme = 'snow';

  @Input()
  String placeholder = '';

  @Input()
  bool readOnly = false;

  @Input()
  bool toolbarVisible = true;

  @Input()
  bool updateModelOnBlur = false;

  @Input()
  bool enableTableSupport = false;

  @Input()
  bool enableTableButton = false;

  @Input()
  String minHeight = '16rem';

  @Input()
  String containerClass = '';

  @Input()
  String toolbarClass = '';

  @Input()
  String editorClass = '';

  @Input()
  set labels(LiQuillTextEditorLabels? value) {
    _labels = value ?? LiQuillTextEditorLabels.english;
    _syncToolbarItems();
  }

  LiQuillTextEditorLabels get labels => _labels;

  @Input()
  set headerOptions(List<LiQuillToolbarOption>? value) {
    _headerOptionsInput = value == null
        ? null
        : List<LiQuillToolbarOption>.unmodifiable(value);
    _syncToolbarItems();
  }

  @Input()
  set fontSizeOptions(List<LiQuillToolbarOption>? value) {
    _fontSizeOptionsInput = value == null
        ? null
        : List<LiQuillToolbarOption>.unmodifiable(value);
    _syncToolbarItems();
  }

  @Input()
  List<String> tableMenus = defaultLiQuillTableMenus;

  @Input()
  set toolbarItems(List<LiQuillToolbarItem>? value) {
    _toolbarItemsInput =
        value == null ? null : List<LiQuillToolbarItem>.unmodifiable(value);
    _syncToolbarItems();
  }

  @Input()
  set toolbarActions(List<LiQuillToolbarAction>? value) {
    _toolbarActions = List<LiQuillToolbarAction>.unmodifiable(
      value ?? const <LiQuillToolbarAction>[],
    );
    _syncToolbarActions();
  }

  List<LiQuillToolbarAction> get toolbarActions => _toolbarActions;

  @Input()
  TemplateRef? toolbarActionsTemplate;

  @ViewChild('editorContainer')
  html.DivElement? editorContainer;

  @ViewChild('toolbar')
  html.DivElement? toolbar;

  @ContentChild(LiQuillTextEditorToolbarActionsDirective)
  LiQuillTextEditorToolbarActionsDirective? projectedToolbarActionsTemplate;

  List<LiQuillToolbarItem> resolvedToolbarItems =
      const <LiQuillToolbarItem>[];
    List<LiQuillToolbarOption> resolvedHeaderOptions =
      defaultLiQuillHeaderOptions;
    List<LiQuillToolbarOption> resolvedFontSizeOptions =
      defaultLiQuillFontSizeOptions;
  List<LiQuillToolbarAction> leadingToolbarActions =
      const <LiQuillToolbarAction>[];
  List<LiQuillToolbarAction> trailingToolbarActions =
      const <LiQuillToolbarAction>[];

  String? errorMessage;

  quill.Quill? get quillInstance {
    final rawInstance = _quill?.rawInstance;
    return rawInstance is quill.Quill ? rawInstance : null;
  }

  bool get isReady => _quill != null;

  TemplateRef? get resolvedToolbarActionsTemplate =>
      toolbarActionsTemplate ?? projectedToolbarActionsTemplate?.templateRef;

  bool get hasToolbarActionsTemplate => resolvedToolbarActionsTemplate != null;

  Stream<String> get valueChange => _valueController.stream;

  Stream<String> get textChange => _textController.stream;

  Stream<String> get deltaJsonChange => _deltaJsonController.stream;

  Stream<LiQuillTextEditorSelection?> get selectionChange =>
      _selectionController.stream;

  Stream<String> get error => _errorController.stream;

  Stream<LiQuillToolbarActionEvent> get toolbarAction =>
      _toolbarActionController.stream;

  Stream<LiQuillTextEditorComponent> get ready => _readyController.stream;

  @override
  void ngOnInit() {
    _syncToolbarItems();
    _syncToolbarActions();
  }

  @override
  void ngAfterChanges() {
    if (_initialized) {
      _quill?.enable(!readOnly);
      _syncToolbarItems();
      _syncToolbarActions();
      if (!updateModelOnBlur && _hasPendingUserChange) {
        _emitUserChange();
      }
      _changeDetectorRef.markForCheck();
    }
  }

  @override
  void ngAfterViewInit() {
    scheduleMicrotask(_initializeQuill);
  }

  void _initializeQuill() {
    if (_initialized || editorContainer == null) {
      return;
    }
    if (!liQuillTextEditorBridge.isQuillAvailable) {
      _setError(labels.quillUnavailable);
      return;
    }

    _registerSizeWhitelist();

    final modules = <String, dynamic>{};
    if (toolbar != null) {
      modules['toolbar'] = <String, dynamic>{
        'container': toolbar,
      };
    }
    if (enableTableSupport && liQuillTextEditorBridge.isTableBetterAvailable) {
      final keyboardBindings =
          liQuillTextEditorBridge.getTableBetterKeyboardBindings();
      modules['table'] = false;
      modules['table-better'] = <String, dynamic>{
        'toolbarTable': true,
        'menus': tableMenus,
      };
      if (keyboardBindings != null) {
        modules['keyboard'] = <String, dynamic>{
          'bindings': keyboardBindings,
        };
      }
    }

    try {
      _quill = liQuillTextEditorBridge.createEditor(
        container: editorContainer!,
        bounds: _hostElement,
        theme: theme.trim().isEmpty ? 'snow' : theme.trim(),
        modules: modules,
        placeholder: placeholder.trim().isEmpty ? null : placeholder.trim(),
        readOnly: readOnly,
      );
      _initialized = true;
      _wireEditorEvents();
      _applyPendingHtmlValue();
      _readyController.add(this);
      _changeDetectorRef.markForCheck();
    } catch (error) {
      _setError('${labels.initializationErrorPrefix} $error');
    }
  }

  void _wireEditorEvents() {
    final editor = _quill;
    if (editor == null) {
      return;
    }

    editor.onTextChange((String source) {
      if (source == 'user') {
        _handleUserTextChange();
      }
    });

    editor.onSelectionChange((LiQuillBridgeSelection? range) {
      if (range == null) {
        _flushPendingUserChange();
        _lastSelection = null;
        _selectionController.add(null);
        _onTouched?.call();
        return;
      }

      final selection = LiQuillTextEditorSelection(
        index: range.index,
        length: range.length,
      );
      _lastSelection = selection;
      _selectionController.add(selection);
    });
  }

  void _registerSizeWhitelist() {
    final values = resolvedFontSizeOptions
        .map((option) => option.value)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    liQuillTextEditorBridge.registerSizeWhitelist(values);
  }

  void _emitUserChange() {
    _hasPendingUserChange = false;
    final htmlValue = getHtml();
    _valueController.add(htmlValue);
    _textController.add(getPlainText());
    _deltaJsonController.add(getDeltaJson());
    _onChange?.call(htmlValue);
    _changeDetectorRef.markForCheck();
  }

  void _handleUserTextChange() {
    if (updateModelOnBlur) {
      _hasPendingUserChange = true;
      _changeDetectorRef.markForCheck();
      return;
    }
    _emitUserChange();
  }

  void _flushPendingUserChange() {
    if (_hasPendingUserChange) {
      _emitUserChange();
    }
  }

  void _applyPendingHtmlValue() {
    final editor = _quill;
    final pendingHtmlValue = _pendingHtmlValue;
    if (editor == null || pendingHtmlValue == null) {
      return;
    }
    _pendingHtmlValue = null;
    if (pendingHtmlValue.trim().isEmpty) {
      editor.setContentsDart(<String, dynamic>{
        'ops': <Map<String, String>>[
          <String, String>{'insert': '\n'},
        ],
      }, 'silent');
      return;
    }
    final delta = editor.convertHtml(pendingHtmlValue);
    editor.setContents(delta, 'silent');
  }

  void _syncToolbarItems() {
    resolvedHeaderOptions = _headerOptionsInput ??
        buildDefaultLiQuillHeaderOptions(labels);
    resolvedFontSizeOptions = _fontSizeOptionsInput ??
        buildDefaultLiQuillFontSizeOptions(labels);
    resolvedToolbarItems = _toolbarItemsInput ??
        LiQuillToolbarItems.defaultItems(
          labels: labels,
          headerOptions: resolvedHeaderOptions,
          fontSizeOptions: resolvedFontSizeOptions,
          enableTableButton: enableTableButton,
        );
  }

  void _syncToolbarActions() {
    final leading = <LiQuillToolbarAction>[];
    final trailing = <LiQuillToolbarAction>[];
    for (final action in toolbarActions) {
      switch (action.placement) {
        case LiQuillToolbarActionPlacement.leading:
          leading.add(action);
          break;
        case LiQuillToolbarActionPlacement.trailing:
          trailing.add(action);
          break;
      }
    }
    leadingToolbarActions = List<LiQuillToolbarAction>.unmodifiable(leading);
    trailingToolbarActions = List<LiQuillToolbarAction>.unmodifiable(trailing);
  }

  void onToolbarActionClick(LiQuillToolbarAction action) {
    final event = LiQuillToolbarActionEvent(editor: this, action: action);
    _toolbarActionController.add(event);
    action.onPressed?.call(event);
  }

  String getHtml() {
    final editor = _quill;
    return editor?.getSemanticHtml() ?? '';
  }

  String getPlainText() {
    final editor = _quill;
    return (editor?.getText() ?? '').trimRight();
  }

  List<Map<String, dynamic>> getDeltaOps() {
    final editor = _quill;
    return editor?.getContentsAsDart() ?? const <Map<String, dynamic>>[];
  }

  String getDeltaJson() {
    return jsonEncode(<String, dynamic>{'ops': getDeltaOps()});
  }

  Future<void> setDeltaJson(String deltaJson) async {
    final editor = _quill;
    if (editor == null) {
      throw StateError(labels.editorNotReady);
    }
    final decoded = jsonDecode(deltaJson);
    if (decoded is! Map || !decoded.containsKey('ops')) {
      throw FormatException(labels.invalidDelta);
    }
    editor.setContentsDart(Map<String, dynamic>.from(decoded), 'api');
    _changeDetectorRef.markForCheck();
  }

  void clear() {
    final editor = _quill;
    if (editor == null) {
      return;
    }
    editor.setContentsDart(<String, dynamic>{
      'ops': <Map<String, String>>[
        <String, String>{'insert': '\n'},
      ],
    }, 'user');
  }

  void focus() => _quill?.focus();

  void blur() {
    _flushPendingUserChange();
    _quill?.blur();
  }

  void commitPendingModelUpdate() => _flushPendingUserChange();

  void format(String name, dynamic value, [String source = 'user']) {
    _quill?.format(name, value, source);
  }

  void insertTextAtSelection(String text, {String source = 'user'}) {
    final editor = _quill;
    if (editor == null) {
      return;
    }
    final range = editor.getSelection(focus: true) ??
        (_lastSelection == null
            ? null
            : LiQuillBridgeSelection(
                index: _lastSelection!.index,
                length: _lastSelection!.length,
              ));
    final index = range?.index ?? 0;
    final length = range?.length ?? 0;
    if (length > 0) {
      editor.deleteText(index, length, source);
    }
    editor.insertText(index, text, source);
    editor.setSelection(index + text.length, 0, 'silent');
  }

  @override
  void writeValue(String? value) {
    _pendingHtmlValue = value ?? '';
    _hasPendingUserChange = false;
    if (_initialized) {
      _applyPendingHtmlValue();
    }
  }

  @override
  void registerOnChange(ChangeFunction<String?> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    readOnly = isDisabled;
    _quill?.enable(!isDisabled);
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngOnDestroy() {
    _valueController.close();
    _textController.close();
    _deltaJsonController.close();
    _selectionController.close();
    _errorController.close();
    _toolbarActionController.close();
    _readyController.close();
  }

  void _setError(String message) {
    errorMessage = message;
    _errorController.add(message);
    _changeDetectorRef.markForCheck();
  }
}
