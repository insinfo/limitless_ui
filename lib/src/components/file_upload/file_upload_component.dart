// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:ngdart/angular.dart';
import 'package:ngdart/src/security/dom_sanitization_service.dart'
    show DomSanitizationService, SafeResourceUrl, SafeUrl;
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import '../../directives/li_form_directive.dart';
import '../modal_component/modal_component.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';
import 'file_drop_directive.dart';
import 'file_select_directive.dart';
import 'file_type.dart';

class LiFileUploadPreviewItem {
  const LiFileUploadPreviewItem({
    required this.file,
    required this.kind,
    required this.kindLabel,
    required this.sizeLabel,
    this.errorText = '',
    this.previewUrl,
    this.previewSafeUrl,
    this.previewResourceUrl,
  });

  final html.File file;
  final String kind;
  final String kindLabel;
  final String sizeLabel;
  final String errorText;
  final String? previewUrl;
  final SafeUrl? previewSafeUrl;
  final SafeResourceUrl? previewResourceUrl;

  bool get hasError => errorText.trim().isNotEmpty;

  bool get isImage => kind == 'image';

  bool get isPdf => kind == 'pdf';

  bool get canPreview => previewUrl != null;
}

@Component(
  selector: 'li-file-upload',
  templateUrl: 'file_upload_component.html',
  styleUrls: ['file_upload_component.css'],
  directives: [
    coreDirectives,
    LiFileDropDirective,
    LiFileSelectDirective,
    LiModalComponent,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiFileUploadComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiFileUploadComponent
    implements ControlValueAccessor<List<html.File>?>, AfterChanges, OnDestroy {
  static const num _minPreviewZoomLevel = 0.25;
  static const num _maxPreviewZoomLevel = 8;
  static const num _previewZoomFactor = 1.25;
  static const double _previewModalPaddingPx = 32;

  LiFileUploadComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]);

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  final DomSanitizationService _domSanitizationService =
      DomSanitizationService();
  final StreamController<List<html.File>> _filesChangeController =
      StreamController<List<html.File>>.broadcast();
  StreamSubscription<bool>? _formSubmissionSubscription;
    StreamSubscription<html.Event>? _fullscreenChangeSubscription;

  List<html.File> _files = <html.File>[];

  @Input()
  bool multiple = true;

  @Input()
  bool disabled = false;

  @Input()
  bool showPreview = true;

  @Input()
  String previewMode = 'compact';

  @Input()
  bool enablePreviewModal = true;

  @Input()
  bool enablePreviewZoom = true;

  @Input()
  int maxFiles = 0;

  @Input()
  String accept = '';

  @Input()
  String title = '';

  @Input()
  String subtitle = '';

  @Input()
  String browseLabel = '';

  @Input()
  String helperText = '';

  @Input()
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

  @Input()
  String locale = 'pt_BR';

  @Input()
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  bool required = false;

  @Input()
  String errorText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @Input()
  int maxSize = 0;

  @Input()
  List<String> allowedTypes = const <String>[];

  @Input()
  String dropzoneClass = '';

  @Input()
  String listClass = '';

  @Output()
  Stream<List<html.File>> get filesChange => _filesChangeController.stream;

  @ViewChild('fileInput')
  html.InputElement? fileInput;

  @ViewChild('previewModal')
  LiModalComponent? previewModal;

  @ViewChild('previewZoomBody')
  html.HtmlElement? previewZoomBodyElement;

  @ViewChild('previewImage')
  html.HtmlElement? previewImageElement;

  ChangeFunction<List<html.File>?> _onChange =
      (List<html.File>? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  bool isDragOver = false;
  List<LiFileUploadPreviewItem> previewItems =
      const <LiFileUploadPreviewItem>[];
  Map<String, String> fileErrors = const <String, String>{};
  LiFileUploadPreviewItem? activePreviewItem;
  num previewZoomLevel = 1;
  bool isPreviewFullscreen = false;
  bool isPreviewBorderless = false;
  int previewRotationQuarterTurns = 0;
  num _previewImageNaturalWidth = 0;
  num _previewImageNaturalHeight = 0;
  double? _previewRenderedWidth;
  double? _previewRenderedHeight;

  bool get hasFiles => _files.isNotEmpty;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get hasFileErrors => fileErrors.isNotEmpty;

  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    return _autoValidationIssue?.message ?? '';
  }

  bool get showErrorFeedback =>
      effectiveInvalid && effectiveErrorText.trim().isNotEmpty;

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get effectiveInvalid =>
      invalid || dataInvalid || hasFileErrors || effectiveAutoInvalid;

  bool get effectiveValid =>
      !effectiveInvalid &&
      (valid ||
          (_shouldShowValidation &&
              (_files.isNotEmpty || _effectiveRules.isNotEmpty) &&
              !hasFileErrors &&
              _autoValidationIssue == null));

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String get resolvedAccept => accept.trim();

  List<String> get resolvedAllowedTypes {
    if (allowedTypes.isNotEmpty) {
      return allowedTypes
          .map((type) => type.trim().toLowerCase())
          .where((type) => type.isNotEmpty)
          .toList(growable: false);
    }

    return accept
        .split(',')
        .map((type) => type.trim().toLowerCase())
        .where((type) => type.isNotEmpty)
        .toList(growable: false);
  }

  String get resolvedTitle => title.trim().isNotEmpty
      ? title
      : (isEnglishLocale ? 'Drop files here' : 'Arraste arquivos aqui');

  String get resolvedSubtitle => subtitle.trim().isNotEmpty
      ? subtitle
      : (isEnglishLocale
          ? 'Or choose files from your device'
          : 'Ou selecione arquivos do seu dispositivo');

  String get captionPlaceholder => multiple
      ? (isEnglishLocale ? 'Select files ...' : 'Selecionar arquivos ...')
      : (isEnglishLocale ? 'Select file ...' : 'Selecionar arquivo ...');

  String get captionValue =>
      hasFiles ? _files.map((file) => file.name).join(', ') : '';

  String get resolvedBrowseLabel => browseLabel.trim().isNotEmpty
      ? browseLabel
      : (isEnglishLocale ? 'Browse files' : 'Selecionar arquivos');

  String get selectedFilesTitle =>
      isEnglishLocale ? 'Selected files' : 'Arquivos selecionados';

  String get previewStatusText => '';

  String get clearLabel => isEnglishLocale ? 'Clear' : 'Limpar';

  String get uploadLabel => isEnglishLocale ? 'Upload' : 'Enviar';

  String get cancelLabel => isEnglishLocale ? 'Cancel' : 'Cancelar';

  String get previewLabel => isEnglishLocale ? 'Preview' : 'Visualizar';

  String get zoomInLabel => isEnglishLocale ? 'Zoom in' : 'Ampliar';

  String get zoomOutLabel => isEnglishLocale ? 'Zoom out' : 'Reduzir';

  String get zoomPreviewAriaLabel =>
      isEnglishLocale ? 'Open preview' : 'Abrir visualizacao';

  String get removePreviewAriaLabel =>
      isEnglishLocale ? 'Remove file' : 'Remover arquivo';

  String get resetZoomLabel => isEnglishLocale ? 'Reset zoom' : 'Resetar zoom';

  String get closePreviewLabel =>
      isEnglishLocale ? 'Close preview' : 'Fechar visualizacao';

  String get rotatePreviewLabel => isEnglishLocale
      ? 'Rotate 90 deg. clockwise'
      : 'Girar 90 graus no sentido horario';

  String get fullscreenPreviewLabel => isEnglishLocale
      ? (isPreviewFullscreen ? 'Exit full screen' : 'Toggle full screen')
      : (isPreviewFullscreen ? 'Sair da tela cheia' : 'Alternar tela cheia');

  String get borderlessPreviewLabel => isEnglishLocale
      ? (isPreviewBorderless ? 'Disable borderless mode' : 'Toggle borderless mode')
      : (isPreviewBorderless
            ? 'Desativar modo sem borda'
            : 'Alternar modo sem borda');

    String get previewModalSize =>
      isPreviewFullscreen || isPreviewBorderless ? 'modal-full' : 'large';

  bool get canRotateActivePreview => activePreviewItem?.isImage ?? false;

    bool get canZoomActivePreview => activePreviewItem?.isImage ?? false;

  String get previewImageTransform =>
      'rotate(${previewRotationQuarterTurns * 90}deg)';

  bool get previewShouldAllowScroll =>
      activePreviewItem?.isPdf == true ||
      previewRotationQuarterTurns.isOdd ||
      previewZoomLevel > 1;

    String? get previewImageWidthStyle =>
      _previewRenderedWidth == null
        ? null
        : '${_previewRenderedWidth!.toStringAsFixed(2)}px';

    String? get previewImageHeightStyle =>
      _previewRenderedHeight == null
        ? null
        : '${_previewRenderedHeight!.toStringAsFixed(2)}px';

  bool get isThumbnailPreviewMode => resolvedPreviewMode == 'thumbnails';

  bool get isLimitlessPreviewMode => resolvedPreviewMode == 'limitless';

  bool get isCardPreviewMode =>
      isThumbnailPreviewMode || isLimitlessPreviewMode;

  String get resolvedPreviewMode {
    final normalized = previewMode.trim().toLowerCase();
    if (normalized == 'thumbnails' || normalized == 'limitless') {
      return normalized;
    }
    return 'compact';
  }

  String get resolvedPreviewClass => _joinClasses(<String>[
        'li-file-upload__preview',
        isCardPreviewMode ? 'li-file-upload__preview--thumbnails' : '',
        isLimitlessPreviewMode ? 'li-file-upload__preview--limitless' : '',
      ]);

  num get initialPreviewZoomLevel => 1;

  String get activePreviewTitle =>
      activePreviewItem?.file.name ??
      (isEnglishLocale ? 'File preview' : 'Pre-visualizacao');

  String get resolvedRootClass => _joinClasses(<String>[
        'li-file-upload',
        'file-input',
        'file-input-ajax-new',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
        disabled ? 'is-disabled' : '',
      ]);

  String get browseAriaLabel =>
      isEnglishLocale ? 'Choose files' : 'Selecionar arquivos';

  String get resolvedDropzoneClass => _joinClasses(<String>[
        'li-file-upload__dropzone',
        'file-drop-zone',
        'clickable',
        'clearfix',
        isDragOver ? 'is-over' : '',
        disabled ? 'is-disabled' : '',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
        dropzoneClass,
      ]);

  String get resolvedListClass => _joinClasses(<String>[
        'list-group',
        'list-group-flush',
        listClass,
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );

  @override
  void ngAfterChanges() {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription ??=
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _markForCheck();
    });
    _fullscreenChangeSubscription ??=
        html.document.onFullscreenChange.listen((_) {
      final isBrowserFullscreen = html.document.fullscreenElement != null;
      if (!isBrowserFullscreen && isPreviewFullscreen) {
        isPreviewFullscreen = false;
      }
      _schedulePreviewLayoutUpdate();
      _markForCheck();
    });

    _effectiveRules = List<LiRule>.unmodifiable(<LiRule>[
      if (required) const LiRequiredRule(),
      ...liRules,
    ]);
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...liMessages,
    });
    _runAutoValidation();
    _markForCheck();
  }

  @HostBinding('class.d-block')
  bool get hostClass => true;

  void onDropzoneKeyDown(html.Event event) {
    if (event is! html.KeyboardEvent) {
      return;
    }

    if (disabled) {
      return;
    }

    if (event.key == 'Enter' || event.key == ' ') {
      event.preventDefault();
      openPicker();
    }
  }

  void onDropzoneClick(html.Event event) {
    if (disabled) {
      return;
    }

    final target = event.target;
    if (target is html.Element && _isInteractiveTarget(target)) {
      return;
    }

    openPicker();
  }

  void openPicker() {
    if (disabled) {
      return;
    }
    _markTouched();
    fileInput?.click();
  }

  void onFileOver(bool value) {
    isDragOver = value && !disabled;
    _markForCheck();
  }

  void onFilesSelected(List<html.File> files) {
    if (disabled) {
      return;
    }
    _consumeFiles(files);
  }

  void removeAt(int index) {
    if (disabled || index < 0 || index >= _files.length) {
      return;
    }
    final removedFile = _files[index];
    if (activePreviewItem != null &&
        identical(activePreviewItem!.file, removedFile)) {
      closePreview();
    }
    _dirty = true;
    final nextFiles = List<html.File>.from(_files)..removeAt(index);
    _setFiles(nextFiles, emitToForm: true);
  }

  void clear() {
    _dirty = true;
    closePreview();
    _setFiles(const <html.File>[], emitToForm: true);
  }

  @override
  void registerOnChange(ChangeFunction<List<html.File>?> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void writeValue(List<html.File>? value) {
    _setFiles(value ?? const <html.File>[], emitToForm: false);
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  Object trackByPreview(int index, dynamic item) {
    final preview = item as LiFileUploadPreviewItem;
    return '${preview.file.name}-${preview.file.size}-${preview.file.type}';
  }

  String kindClass(LiFileUploadPreviewItem item) {
    return _joinClasses(<String>[
      'li-file-upload__kind',
      'li-file-upload__kind-${item.kind}',
    ]);
  }

  bool canOpenPreview(LiFileUploadPreviewItem item) {
    return enablePreviewModal && item.canPreview;
  }

  void openPreview(LiFileUploadPreviewItem item) {
    if (!canOpenPreview(item)) {
      return;
    }
    activePreviewItem = item;
    isPreviewFullscreen = false;
    isPreviewBorderless = false;
    previewRotationQuarterTurns = 0;
    previewZoomLevel = initialPreviewZoomLevel;
    _clearPreviewImageLayout();
    _markForCheck();
    previewModal?.open();
    _schedulePreviewLayoutUpdate();
  }

  void closePreview() {
    _setBrowserFullscreen(false);
    activePreviewItem = null;
    isPreviewFullscreen = false;
    isPreviewBorderless = false;
    previewRotationQuarterTurns = 0;
    previewZoomLevel = initialPreviewZoomLevel;
    _clearPreviewImageLayout();
    previewModal?.close();
    _markForCheck();
  }

  void zoomInPreview() {
    if (!enablePreviewZoom || !canZoomActivePreview) {
      return;
    }
    if (previewZoomLevel >= _maxPreviewZoomLevel) {
      previewZoomLevel = _maxPreviewZoomLevel;
      _markForCheck();
      return;
    }
    previewZoomLevel =
        (previewZoomLevel * _previewZoomFactor)
            .clamp(_minPreviewZoomLevel, _maxPreviewZoomLevel);
    _refreshPreviewImageLayout();
  }

  void zoomOutPreview() {
    if (!enablePreviewZoom || !canZoomActivePreview) {
      return;
    }
    if (previewZoomLevel <= _minPreviewZoomLevel) {
      previewZoomLevel = _minPreviewZoomLevel;
      _markForCheck();
      return;
    }
    previewZoomLevel =
        (previewZoomLevel / _previewZoomFactor)
            .clamp(_minPreviewZoomLevel, _maxPreviewZoomLevel);
    _refreshPreviewImageLayout();
  }

  void resetPreviewZoom() {
    if (!canZoomActivePreview) {
      return;
    }
    previewZoomLevel = initialPreviewZoomLevel;
    _refreshPreviewImageLayout();
  }

  void togglePreviewFullscreen() {
    if (activePreviewItem == null) {
      return;
    }
    isPreviewFullscreen = !isPreviewFullscreen;
    if (isPreviewFullscreen) {
      isPreviewBorderless = false;
    }
    _setBrowserFullscreen(isPreviewFullscreen);
    _schedulePreviewLayoutUpdate();
    _markForCheck();
  }

  void togglePreviewBorderless() {
    if (activePreviewItem == null) {
      return;
    }
    isPreviewBorderless = !isPreviewBorderless;
    if (isPreviewBorderless) {
      _setBrowserFullscreen(false);
      isPreviewFullscreen = false;
    }
    _schedulePreviewLayoutUpdate();
    _markForCheck();
  }

  void rotatePreviewClockwise() {
    if (!canRotateActivePreview) {
      return;
    }
    previewRotationQuarterTurns = (previewRotationQuarterTurns + 1) % 4;
    _refreshPreviewImageLayout();
  }

  void onPreviewImageLoad(html.Event event) {
    final target = event.target;
    if (target is html.ImageElement) {
      _previewImageNaturalWidth = target.naturalWidth;
      _previewImageNaturalHeight = target.naturalHeight;
    }
    _refreshPreviewImageLayout();
  }

  void _consumeFiles(List<html.File> incoming) {
    _markTouched();
    if (incoming.isEmpty) {
      return;
    }

    _dirty = true;

    final normalizedIncoming =
        multiple ? _mergeFiles(_files, incoming) : <html.File>[incoming.first];

    _setFiles(
      _applyMaxFiles(normalizedIncoming),
      emitToForm: true,
      validationErrors: _collectFileErrors(normalizedIncoming),
    );
    if (fileInput != null) {
      fileInput!.value = '';
    }
  }

  List<html.File> _mergeFiles(
    List<html.File> current,
    List<html.File> incoming,
  ) {
    final next = List<html.File>.from(current);
    for (final file in incoming) {
      final alreadyExists = next.any((existing) =>
          existing.name == file.name &&
          existing.size == file.size &&
          existing.type == file.type);
      if (!alreadyExists) {
        next.add(file);
      }
    }
    return next;
  }

  List<html.File> _applyMaxFiles(List<html.File> files) {
    if (maxFiles <= 0 || files.length <= maxFiles) {
      return files;
    }
    return files.take(maxFiles).toList(growable: false);
  }

  void _setFiles(
    List<html.File> value, {
    required bool emitToForm,
    Map<String, String>? validationErrors,
  }) {
    final resolvedErrors = validationErrors ?? _collectFileErrors(value);
    _disposePreviewUrls();
    _files = List<html.File>.from(value);
    fileErrors = Map<String, String>.unmodifiable(resolvedErrors);
    previewItems = _files.map((file) {
      final kind = LiFileType.getMimeClass(file);
      final fileKey = _fileKey(file);
      final previewUrl = _createPreviewUrl(file, kind);
      return LiFileUploadPreviewItem(
        file: file,
        kind: kind,
        kindLabel: _kindLabel(kind),
        sizeLabel: _formatBytes(file.size),
        errorText: resolvedErrors[fileKey] ?? '',
        previewUrl: previewUrl,
        previewSafeUrl: _createPreviewSafeUrl(previewUrl, kind),
        previewResourceUrl: _createPreviewResourceUrl(previewUrl, kind),
      );
    }).toList(growable: false);

    if (activePreviewItem != null) {
      final activeKey = _fileKey(activePreviewItem!.file);
      activePreviewItem =
          previewItems.cast<LiFileUploadPreviewItem?>().firstWhere(
                (item) => item != null && _fileKey(item.file) == activeKey,
                orElse: () => null,
              );
    }

    if (emitToForm) {
      final payload = List<html.File>.unmodifiable(_files);
      _filesChangeController.add(payload);
      _onChange(payload, rawValue: _files.length.toString());
      _markTouched();
    }
    _runAutoValidation();
    _markForCheck();
  }

  Map<String, String> _collectFileErrors(List<html.File> files) {
    final errors = <String, String>{};
    for (final file in files) {
      final error = _validateFile(file);
      if (error != null) {
        errors[_fileKey(file)] = error;
      }
    }
    return errors;
  }

  String? _validateFile(html.File file) {
    if (maxSize > 0 && file.size > maxSize) {
      return isEnglishLocale
          ? 'File exceeds the maximum size of ${_formatBytes(maxSize)}.'
          : 'Arquivo excede o tamanho maximo de ${_formatBytes(maxSize)}.';
    }

    final allowed = resolvedAllowedTypes;
    if (allowed.isEmpty) {
      return null;
    }

    final mime = file.type.toLowerCase();
    final extension = _fileExtension(file.name);
    final extensionWithDot =
        extension.isEmpty ? '' : '.${extension.toLowerCase()}';
    final mimeClass = LiFileType.getMimeClass(file).toLowerCase();

    final isAllowed = allowed.any((type) {
      if (type == mimeClass) {
        return true;
      }
      if (type.startsWith('.')) {
        return type == extensionWithDot;
      }
      if (type.endsWith('/*')) {
        final prefix = type.substring(0, type.length - 1);
        return mime.startsWith(prefix);
      }
      return type == mime || type == extension;
    });

    if (isAllowed) {
      return null;
    }

    return isEnglishLocale
        ? 'File type not allowed.'
        : 'Tipo de arquivo nao permitido.';
  }

  String _fileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex < 0 || lastDotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1);
  }

  String _fileKey(html.File file) => '${file.name}-${file.size}-${file.type}';

  String _kindLabel(String kind) {
    switch (kind) {
      case 'image':
        return 'IMG';
      case 'video':
        return 'VID';
      case 'audio':
        return 'AUD';
      case 'pdf':
        return 'PDF';
      case 'compress':
        return 'ZIP';
      case 'doc':
        return 'DOC';
      case 'xls':
        return 'XLS';
      case 'ppt':
        return 'PPT';
      default:
        return 'FILE';
    }
  }

  bool _isInteractiveTarget(html.Element target) {
    return target.closest('button') != null ||
        target.closest('label') != null ||
        target.closest('input') != null ||
        target.closest('iframe') != null;
  }

  void _setBrowserFullscreen(bool enable) {
    final root = html.document.documentElement;
    if (root == null) {
      return;
    }

    if (enable) {
      if (html.document.fullscreenElement == null) {
        unawaited(root.requestFullscreen());
      }
      return;
    }

    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen();
    }
  }

  void _clearPreviewImageLayout() {
    _previewImageNaturalWidth = 0;
    _previewImageNaturalHeight = 0;
    _previewRenderedWidth = null;
    _previewRenderedHeight = null;
  }

  void _schedulePreviewLayoutUpdate() {
    Future<void>.delayed(const Duration(milliseconds: 16), () {
      if (activePreviewItem == null || !canZoomActivePreview) {
        return;
      }
      _refreshPreviewImageLayout();
    });
  }

  void _refreshPreviewImageLayout() {
    if (!canZoomActivePreview) {
      return;
    }

    final body = previewZoomBodyElement;
    final image = previewImageElement;
    if (body == null || image == null || image is! html.ImageElement) {
      return;
    }

    final naturalWidth =
        _previewImageNaturalWidth > 0 ? _previewImageNaturalWidth : image.naturalWidth;
    final naturalHeight =
        _previewImageNaturalHeight > 0 ? _previewImageNaturalHeight : image.naturalHeight;
    if (naturalWidth <= 0 || naturalHeight <= 0) {
      return;
    }

    final viewportWidth = body.clientWidth.toDouble();
    final viewportHeight = body.clientHeight.toDouble();
    if (viewportWidth <= 0 || viewportHeight <= 0) {
      return;
    }

    final rotatedWidth = previewRotationQuarterTurns.isOdd
        ? naturalHeight.toDouble()
        : naturalWidth.toDouble();
    final rotatedHeight = previewRotationQuarterTurns.isOdd
        ? naturalWidth.toDouble()
        : naturalHeight.toDouble();
    final availableWidth = math.max(1, viewportWidth - _previewModalPaddingPx);
    final availableHeight = math.max(1, viewportHeight - _previewModalPaddingPx);
    final fittedScale = math.min(
      1,
      math.min(availableWidth / rotatedWidth, availableHeight / rotatedHeight),
    );

    _previewRenderedWidth =
      naturalWidth.toDouble() * fittedScale * previewZoomLevel.toDouble();
    _previewRenderedHeight =
      naturalHeight.toDouble() * fittedScale * previewZoomLevel.toDouble();
    _markForCheck();
  }

  String? _createPreviewUrl(html.File file, String kind) {
    if (kind != 'image' && kind != 'pdf') {
      return null;
    }
    return html.Url.createObjectUrl(file);
  }

  SafeUrl? _createPreviewSafeUrl(String? previewUrl, String kind) {
    if (kind != 'image' || previewUrl == null) {
      return null;
    }
    return _domSanitizationService.bypassSecurityTrustUrl(previewUrl);
  }

  SafeResourceUrl? _createPreviewResourceUrl(String? previewUrl, String kind) {
    if (kind != 'pdf' || previewUrl == null) {
      return null;
    }
    return _domSanitizationService.bypassSecurityTrustResourceUrl(previewUrl);
  }

  void _disposePreviewUrls() {
    for (final item in previewItems) {
      final previewUrl = item.previewUrl;
      if (previewUrl != null && previewUrl.isNotEmpty) {
        html.Url.revokeObjectUrl(previewUrl);
      }
    }
  }

  String _formatBytes(num bytes) {
    const units = <String>['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    final precision = value >= 100 || unitIndex == 0 ? 0 : 1;
    return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
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

  void _markTouched() {
    if (_touched) {
      _onTouched();
      if (_shouldShowValidation || _autoValidationIssue != null) {
        _runAutoValidation();
      }
      return;
    }
    _touched = true;
    _onTouched();
    _runAutoValidation();
  }

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      return;
    }

    _autoValidationIssue = liValidateValue(
      value: _files,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: resolvedTitle,
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
  }

  @override
  void ngOnDestroy() {
    _disposePreviewUrls();
    _formSubmissionSubscription?.cancel();
    _fullscreenChangeSubscription?.cancel();
    _filesChangeController.close();
  }
}
