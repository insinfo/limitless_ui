import 'dart:async';

import 'package:ngdart/angular.dart';

import '../../directives/css_style_directive.dart';
import 'tag_models.dart';

class LiTagEditorPresetColorView {
  const LiTagEditorPresetColorView({
    required this.color,
    required this.swatchStyle,
  });

  final String color;
  final String swatchStyle;
}

@Component(
  selector: 'li-tag-editor',
  templateUrl: 'tag_editor_component.html',
  styleUrls: ['tag_editor_component.css'],
  directives: [coreDirectives, CssStyleDirective],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTagEditorComponent implements OnDestroy {
  LiTagEditorComponent(this._changeDetectorRef) {
    _applyPresetColors(liDefaultTagPalette);
    _applyValue(null, emitValueChange: false);
  }

  final ChangeDetectorRef _changeDetectorRef;

  final StreamController<Map<String, dynamic>> _valueChangeController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _saveController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<void> _cancelController =
      StreamController<void>.broadcast();

  Map<String, dynamic> _baseValue = <String, dynamic>{};
  List<LiTagEditorPresetColorView> presetColorViews =
      const <LiTagEditorPresetColorView>[];

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String locale = 'pt_BR';

  @Input()
  String labelKey = 'label';

  @Input()
  String colorKey = 'color';

  @Input()
  String nameLabel = 'Nome da etiqueta';

  @Input()
  String namePlaceholder = '';

  @Input()
  String colorLabel = 'Cor';

  @Input()
  String colorPlaceholder = '#6c757d';

  @Input()
  String emptyPreviewLabel = 'Etiqueta';

  @Input()
  String saveButtonText = 'Salvar';

  @Input()
  String cancelButtonText = 'Cancelar';

  @Input()
  bool showCancelButton = true;

  @Input()
  set presetColors(List<String>? value) {
    _applyPresetColors(
        value == null || value.isEmpty ? liDefaultTagPalette : value);
  }

  @Input()
  set value(Map<String, dynamic>? value) {
    _applyValue(value, emitValueChange: false);
  }

  @Output('valueChange')
  Stream<Map<String, dynamic>> get onValueChange =>
      _valueChangeController.stream;

  @Output('save')
  Stream<Map<String, dynamic>> get onSave => _saveController.stream;

  @Output('cancel')
  Stream<void> get onCancel => _cancelController.stream;

  String draftName = '';
  String draftColorInput = liDefaultTagColor;
  String normalizedColor = liDefaultTagColor;
  String previewBadgeStyle = '';
  String previewSwatchStyle = '';

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  String get resolvedNamePlaceholder {
    final value = namePlaceholder.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Tag name' : 'Nome da etiqueta';
  }

  String get resolvedColorPlaceholder {
    final value = colorPlaceholder.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return liDefaultTagColor;
  }

  String get resolvedPreviewText {
    final label = draftName.trim();
    if (label.isNotEmpty) {
      return label;
    }
    final fallback = emptyPreviewLabel.trim();
    if (fallback.isNotEmpty) {
      return fallback;
    }
    return _isEnglishLocale ? 'Tag' : 'Etiqueta';
  }

  String get resolvedSaveButtonText {
    final value = saveButtonText.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Save' : 'Salvar';
  }

  String get resolvedCancelButtonText {
    final value = cancelButtonText.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Cancel' : 'Cancelar';
  }

  bool get canSave => !isDisabled && draftName.trim().isNotEmpty;

  void onNameInput(String? value) {
    draftName = value?.trim() ?? '';
    _syncDraft(emitValueChange: true);
  }

  void onColorInput(String? value) {
    draftColorInput = value?.trim() ?? '';
    _syncDraft(emitValueChange: true);
  }

  void selectPresetColor(String color) {
    if (isDisabled) {
      return;
    }
    draftColorInput = color;
    _syncDraft(emitValueChange: true);
  }

  bool isSelectedPreset(String color) => normalizedColor == color;

  void save() {
    if (!canSave) {
      return;
    }
    _saveController
        .add(Map<String, dynamic>.unmodifiable(_buildCurrentValue()));
  }

  void cancel() {
    _cancelController.add(null);
  }

  @override
  void ngOnDestroy() {
    _valueChangeController.close();
    _saveController.close();
    _cancelController.close();
  }

  void _applyValue(
    Map<String, dynamic>? value, {
    required bool emitValueChange,
  }) {
    _baseValue = Map<String, dynamic>.from(value ?? const <String, dynamic>{});
    draftName = (_baseValue[labelKey] ?? '').toString().trim();
    draftColorInput =
        (_baseValue[colorKey] ?? liDefaultTagColor).toString().trim();
    _syncDraft(emitValueChange: emitValueChange);
  }

  void _applyPresetColors(List<String> colors) {
    final nextPresetColors = <LiTagEditorPresetColorView>[];
    for (final color in colors) {
      final normalized = _normalizeColor(color);
      nextPresetColors.add(
        LiTagEditorPresetColorView(
          color: normalized,
          swatchStyle: _buildSwatchStyle(normalized),
        ),
      );
    }
    presetColorViews = nextPresetColors;
    _changeDetectorRef.markForCheck();
  }

  void _syncDraft({required bool emitValueChange}) {
    normalizedColor = _normalizeColor(draftColorInput);
    previewBadgeStyle = _buildBadgeStyle(normalizedColor);
    previewSwatchStyle = _buildSwatchStyle(normalizedColor);

    if (emitValueChange) {
      _valueChangeController.add(
        Map<String, dynamic>.unmodifiable(_buildCurrentValue()),
      );
    }

    _changeDetectorRef.markForCheck();
  }

  Map<String, dynamic> _buildCurrentValue() {
    final nextValue = Map<String, dynamic>.from(_baseValue);
    nextValue[labelKey] = draftName.trim();
    nextValue[colorKey] = normalizedColor;
    return nextValue;
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
    return 'background-color: $color;';
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
