import 'dart:async';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';

import '../../directives/css_style_directive.dart';
import 'tag_editor_component.dart';
import 'tag_models.dart';

class LiTagManagerOptionView {
  LiTagManagerOptionView({
    required this.label,
    required this.value,
    required this.color,
    required this.model,
    required this.sourceMap,
    required this.badgeStyle,
    required this.swatchStyle,
    this.disabled = false,
  });

  final String label;
  final dynamic value;
  final String color;
  final dynamic model;
  final Map<String, dynamic> sourceMap;
  final String badgeStyle;
  final String swatchStyle;
  bool disabled;
  bool selected = false;
  bool visible = true;
}

@Component(
  selector: 'li-tag-manager',
  templateUrl: 'tag_manager_component.html',
  styleUrls: ['tag_manager_component.css'],
  directives: [
    coreDirectives,
    CssStyleDirective,
    LiTagEditorComponent,
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTagManagerComponent implements OnDestroy {
  LiTagManagerComponent(this._changeDetectorRef);

  final ChangeDetectorRef _changeDetectorRef;

  final StreamController<List<dynamic>> _valueChangeController =
      StreamController<List<dynamic>>.broadcast();
  final StreamController<List<dynamic>> _modelChangeController =
      StreamController<List<dynamic>>.broadcast();
  final StreamController<LiTagSelectionChange> _selectionChangeController =
      StreamController<LiTagSelectionChange>.broadcast();
  final StreamController<LiTagSelectionChange> _applySelectionController =
      StreamController<LiTagSelectionChange>.broadcast();
  final StreamController<LiTagSaveRequest> _createRequestController =
      StreamController<LiTagSaveRequest>.broadcast();
  final StreamController<LiTagSaveRequest> _updateRequestController =
      StreamController<LiTagSaveRequest>.broadcast();
  final StreamController<LiTagDeleteRequest> _deleteRequestController =
      StreamController<LiTagDeleteRequest>.broadcast();
  final StreamController<void> _reloadRequestController =
      StreamController<void>.broadcast();

  List<dynamic> _boundSelectedValues = <dynamic>[];
  String _searchQuery = '';
  dynamic _editingOriginalValue;
  bool _editingExistingItem = false;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String locale = 'pt_BR';

  @Input()
  String labelKey = 'label';

  @Input()
  String valueKey = 'value';

  @Input()
  String colorKey = 'color';

  @Input()
  String disabledKey = 'disabled';

  @Input()
  String headerText = 'Etiquetas';

  @Input()
  String createHeaderText = 'Criar etiqueta';

  @Input()
  String editHeaderText = 'Editar etiqueta';

  @Input()
  String searchPlaceholder = '';

  @Input()
  String emptyText = '';

  @Input()
  String applyButtonText = 'Aplicar';

  @Input()
  String createButtonText = 'Criar nova etiqueta';

  @Input()
  bool searchable = true;

  @Input()
  bool allowSelection = true;

  @Input()
  bool allowCreate = true;

  @Input()
  bool allowEdit = true;

  @Input()
  bool allowDelete = true;

  @Input()
  bool showApplyButton = true;

  @Input()
  bool showReloadButton = false;

  @Input()
  set selectedValues(List<dynamic>? value) {
    _boundSelectedValues = List<dynamic>.from(value ?? const <dynamic>[]);
    _applySelection(_boundSelectedValues, emit: false);
  }

  @Input()
  set presetColors(List<String>? value) {
    editorPresetColors = List<String>.from(
      value == null || value.isEmpty ? liDefaultTagPalette : value,
    );
    _changeDetectorRef.markForCheck();
  }

  @Input()
  set dataSource(dynamic value) {
    _applyDataSource(_buildOptions(value));
  }

  @Output('currentValueChange')
  Stream<List<dynamic>> get onValueChange => _valueChangeController.stream;

  @Output('modelChange')
  Stream<List<dynamic>> get onModelChange => _modelChangeController.stream;

  @Output('selectionChange')
  Stream<LiTagSelectionChange> get onSelectionChange =>
      _selectionChangeController.stream;

  @Output('applySelection')
  Stream<LiTagSelectionChange> get onApplySelection =>
      _applySelectionController.stream;

  @Output('createRequest')
  Stream<LiTagSaveRequest> get onCreateRequest =>
      _createRequestController.stream;

  @Output('updateRequest')
  Stream<LiTagSaveRequest> get onUpdateRequest =>
      _updateRequestController.stream;

  @Output('deleteRequest')
  Stream<LiTagDeleteRequest> get onDeleteRequest =>
      _deleteRequestController.stream;

  @Output('reloadRequest')
  Stream<void> get onReloadRequest => _reloadRequestController.stream;

  List<LiTagManagerOptionView> options = <LiTagManagerOptionView>[];
  List<dynamic> _selectedValues = <dynamic>[];
  List<dynamic> _selectedModels = <dynamic>[];
  List<String> editorPresetColors = List<String>.from(liDefaultTagPalette);
  Map<String, dynamic> editorValue = <String, dynamic>{
    'label': '',
    'color': liDefaultTagColor,
  };
  int visibleOptionCount = 0;
  bool isEditing = false;

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  String get resolvedHeaderText {
    if (!isEditing) {
      final value = headerText.trim();
      return value.isNotEmpty
          ? value
          : (_isEnglishLocale ? 'Tags' : 'Etiquetas');
    }
    final value =
        (_editingExistingItem ? editHeaderText : createHeaderText).trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _editingExistingItem
        ? (_isEnglishLocale ? 'Edit tag' : 'Editar etiqueta')
        : (_isEnglishLocale ? 'Create tag' : 'Criar etiqueta');
  }

  String get resolvedSearchPlaceholder {
    final value = searchPlaceholder.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Search tags...' : 'Buscar etiquetas...';
  }

  String get resolvedEmptyText {
    final value = emptyText.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'No tags found.' : 'Nenhuma etiqueta encontrada.';
  }

  String get resolvedApplyButtonText {
    final value = applyButtonText.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Apply' : 'Aplicar';
  }

  String get resolvedCreateButtonText {
    final value = createButtonText.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Create new tag' : 'Criar nova etiqueta';
  }

  void onSearchInput(String? value) {
    _searchQuery = value?.trim() ?? '';
    _applySearchQuery(_searchQuery);
  }

  void toggleSelection(LiTagManagerOptionView option) {
    if (isDisabled || option.disabled || !allowSelection) {
      return;
    }

    option.selected = !option.selected;
    _rebuildSelectionState(emit: true);
  }

  void startCreate() {
    if (isDisabled || !allowCreate) {
      return;
    }

    isEditing = true;
    _editingExistingItem = false;
    _editingOriginalValue = null;
    editorValue = <String, dynamic>{
      labelKey: '',
      colorKey: liDefaultTagColor,
    };
    _changeDetectorRef.markForCheck();
  }

  void startEdit(LiTagManagerOptionView option, html.Event event) {
    event.preventDefault();
    event.stopPropagation();
    if (isDisabled || !allowEdit) {
      return;
    }

    isEditing = true;
    _editingExistingItem = true;
    _editingOriginalValue = option.model;
    editorValue = Map<String, dynamic>.from(option.sourceMap)
      ..[labelKey] = option.label
      ..[colorKey] = option.color;
    _changeDetectorRef.markForCheck();
  }

  void cancelEditing() {
    isEditing = false;
    _changeDetectorRef.markForCheck();
  }

  void requestDelete(LiTagManagerOptionView option, html.Event event) {
    event.preventDefault();
    event.stopPropagation();
    if (isDisabled || !allowDelete) {
      return;
    }

    final request = LiTagDeleteRequest(
      value: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(option.sourceMap)
          ..[labelKey] = option.label
          ..[colorKey] = option.color,
      ),
      originalValue: option.model,
    );
    _deleteRequestController.add(request);
  }

  void requestReload() {
    if (isDisabled) {
      return;
    }
    _reloadRequestController.add(null);
  }

  void applySelection() {
    if (isDisabled || !allowSelection) {
      return;
    }

    _applySelectionController.add(
      LiTagSelectionChange(
        values: List<dynamic>.unmodifiable(_selectedValues),
        models: List<dynamic>.unmodifiable(_selectedModels),
      ),
    );
  }

  void handleEditorSave(Map<String, dynamic> value) {
    final request = LiTagSaveRequest(
      value: Map<String, dynamic>.unmodifiable(_normalizeEditorValue(value)),
      originalValue: _editingOriginalValue,
      isEditing: _editingExistingItem,
    );

    if (_editingExistingItem) {
      _updateRequestController.add(request);
    } else {
      _createRequestController.add(request);
    }

    isEditing = false;
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngOnDestroy() {
    _valueChangeController.close();
    _modelChangeController.close();
    _selectionChangeController.close();
    _applySelectionController.close();
    _createRequestController.close();
    _updateRequestController.close();
    _deleteRequestController.close();
    _reloadRequestController.close();
  }

  void _applyDataSource(List<LiTagManagerOptionView> nextOptions) {
    options = nextOptions;
    _applySelection(_boundSelectedValues, emit: false);
    _applySearchQuery(_searchQuery);
    _changeDetectorRef.markForCheck();
  }

  List<LiTagManagerOptionView> _buildOptions(dynamic source) {
    final nextOptions = <LiTagManagerOptionView>[];

    if (source == null) {
      return nextOptions;
    }

    if (source is DataFrame) {
      final itemsAsMap = source.itemsAsMap;
      for (var index = 0; index < source.length; index++) {
        final model = source[index];
        nextOptions.add(_buildOption(model, _coerceMap(itemsAsMap[index])));
      }
      return nextOptions;
    }

    if (source is List) {
      for (final item in source) {
        if (item is Map) {
          nextOptions.add(_buildOption(item, _coerceMap(item)));
          continue;
        }

        nextOptions.add(
          _buildOption(
            item,
            <String, dynamic>{
              labelKey: item?.toString() ?? '',
              valueKey: item,
              colorKey: liDefaultTagColor,
            },
          ),
        );
      }
    }

    return nextOptions;
  }

  LiTagManagerOptionView _buildOption(
    dynamic model,
    Map<String, dynamic> sourceMap,
  ) {
    final rawLabel = sourceMap[labelKey] ?? model;
    final rawValue =
        sourceMap.containsKey(valueKey) ? sourceMap[valueKey] : model;
    final color = _normalizeColor(sourceMap[colorKey]?.toString());
    final disabled = _parseBool(sourceMap[disabledKey]);
    final label = rawLabel?.toString().trim() ?? '';

    return LiTagManagerOptionView(
      label: label.isNotEmpty ? label : rawValue?.toString() ?? '',
      value: rawValue,
      color: color,
      model: model,
      sourceMap: sourceMap,
      badgeStyle: _buildBadgeStyle(color),
      swatchStyle: _buildSwatchStyle(color),
      disabled: disabled,
    );
  }

  Map<String, dynamic> _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    return <String, dynamic>{};
  }

  void _applySelection(List<dynamic> selectedValues, {required bool emit}) {
    for (final option in options) {
      option.selected = selectedValues.contains(option.value);
    }
    _rebuildSelectionState(emit: emit);
  }

  void _rebuildSelectionState({required bool emit}) {
    final nextSelectedValues = <dynamic>[];
    final nextSelectedModels = <dynamic>[];

    for (final option in options) {
      if (!option.selected) {
        continue;
      }
      nextSelectedValues.add(option.value);
      nextSelectedModels.add(option.model);
    }

    _selectedValues = nextSelectedValues;
    _selectedModels = nextSelectedModels;
    _boundSelectedValues = List<dynamic>.from(nextSelectedValues);

    if (emit) {
      final emittedValues = List<dynamic>.unmodifiable(_selectedValues);
      final emittedModels = List<dynamic>.unmodifiable(_selectedModels);
      _valueChangeController.add(emittedValues);
      _modelChangeController.add(emittedModels);
      _selectionChangeController.add(
        LiTagSelectionChange(values: emittedValues, models: emittedModels),
      );
    }

    _changeDetectorRef.markForCheck();
  }

  void _applySearchQuery(String query) {
    if (query.isEmpty) {
      for (final option in options) {
        option.visible = true;
      }
    } else {
      for (final option in options) {
        option.visible = option.label.containsIgnoreAccents(query) ||
            (option.value?.toString() ?? '').containsIgnoreAccents(query);
      }
    }

    visibleOptionCount = 0;
    for (final option in options) {
      if (option.visible) {
        visibleOptionCount++;
      }
    }
  }

  Map<String, dynamic> _normalizeEditorValue(Map<String, dynamic> value) {
    final nextValue = Map<String, dynamic>.from(value);
    nextValue[labelKey] = (nextValue[labelKey] ?? '').toString().trim();
    nextValue[colorKey] = _normalizeColor(nextValue[colorKey]?.toString());
    return nextValue;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  String _normalizeColor(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return liDefaultTagColor;
    }
    if (trimmed.startsWith('#') || trimmed.startsWith('rgb')) {
      return trimmed;
    }
    return '#$trimmed';
  }

  String _buildBadgeStyle(String color) {
    final textColor = _resolveContrastColor(color);
    return 'background-color: $color; color: $textColor;';
  }

  String _buildSwatchStyle(String color) {
    final borderColor = 'color-mix(in srgb, $color 72%, #111827 28%)';
    return 'background-color: $color; box-shadow: inset 0 0 0 1px $borderColor;';
  }

  String _resolveContrastColor(String color) {
    final hex = color.trim();
    if (!hex.startsWith('#')) {
      return '#ffffff';
    }

    final normalized = hex.length == 4
        ? '#${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}'
        : hex;
    if (normalized.length != 7) {
      return '#ffffff';
    }

    final red = int.tryParse(normalized.substring(1, 3), radix: 16);
    final green = int.tryParse(normalized.substring(3, 5), radix: 16);
    final blue = int.tryParse(normalized.substring(5, 7), radix: 16);
    if (red == null || green == null || blue == null) {
      return '#ffffff';
    }

    final luminance = ((red * 299) + (green * 587) + (blue * 114)) / 1000;
    return luminance >= 160 ? '#111827' : '#ffffff';
  }
}
